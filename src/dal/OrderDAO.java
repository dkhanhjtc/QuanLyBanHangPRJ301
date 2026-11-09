package dal;

import model.Order;
import model.OrderDetail;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class OrderDAO extends DBContext {

    /**
     * Tạo đơn hàng mới sử dụng JDBC Transaction.
     * Quy trình:
     * 1. Kiểm tra tồn kho của từng sản phẩm trong giỏ hàng (nếu mua > tồn thì hủy giao dịch)
     * 2. Insert vào bảng Orders lấy ID vừa tạo
     * 3. Insert danh sách vào OrderDetails
     * 4. Trừ tồn kho stock_qty trong bảng Products
     * 5. Cập nhật doanh số ca WorkShifts nếu có shiftId
     * 6. Commit Transaction
     */
    public boolean createOrder(Order order, List<OrderDetail> details) {
        if (details == null || details.isEmpty()) {
            return false;
        }

        String checkStockSql = "SELECT product_id, stock_qty, product_name FROM Products WHERE product_code = ? OR CAST(product_id AS VARCHAR(50)) = ?";
        String insertOrderSql = "INSERT INTO Orders (order_code, staff_id, shift_id, total_amount, payment_method, status, created_at) "
                + "VALUES (?, ?, ?, ?, ?, ?, GETDATE())";
        String insertDetailSql = "INSERT INTO OrderDetails (order_id, product_id, quantity, unit_price, subtotal) "
                + "VALUES (?, ?, ?, ?, ?)";
        String updateStockSql = "UPDATE Products SET stock_qty = stock_qty - ? WHERE product_id = ?";
        String updateShiftSalesSql = "UPDATE WorkShifts SET total_sales = total_sales + ? WHERE shift_id = ?";

        Connection con = null;
        try {
            con = getConnection();
            con.setAutoCommit(false); // Bắt đầu Transaction an toàn

            Map<String, Integer> productDbIdMap = new HashMap<>();

            // 1. Kiểm tra tồn kho của tất cả sản phẩm trong giỏ
            try (PreparedStatement psCheck = con.prepareStatement(checkStockSql)) {
                for (OrderDetail d : details) {
                    psCheck.setString(1, d.getProductId());
                    psCheck.setString(2, d.getProductId());
                    try (ResultSet rs = psCheck.executeQuery()) {
                        if (rs.next()) {
                            int currentStock = rs.getInt("stock_qty");
                            int dbProdId = rs.getInt("product_id");
                            productDbIdMap.put(d.getProductId(), dbProdId);

                            if (currentStock < d.getQuantity()) {
                                // Tồn kho không đủ -> Rollback ngay lập tức
                                con.rollback();
                                return false;
                            }
                        } else {
                            con.rollback();
                            return false;
                        }
                    }
                }
            }

            // 2. Insert đơn hàng Orders
            int orderId = 0;
            try (PreparedStatement psOrder = con.prepareStatement(insertOrderSql, Statement.RETURN_GENERATED_KEYS)) {
                psOrder.setString(1, order.getCode());
                psOrder.setInt(2, order.getCreatedBy());
                if (order.getShiftId() != null && order.getShiftId() > 0) {
                    psOrder.setInt(3, order.getShiftId());
                } else {
                    psOrder.setNull(3, java.sql.Types.INTEGER);
                }
                psOrder.setDouble(4, order.getTotalAmount());
                psOrder.setString(5, order.getPaymentMethod());
                psOrder.setString(6, order.getStatus() != null ? order.getStatus() : "Đã thanh toán");
                psOrder.executeUpdate();

                try (ResultSet generatedKeys = psOrder.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        orderId = generatedKeys.getInt(1);
                        order.setId(orderId);
                    } else {
                        con.rollback();
                        return false;
                    }
                }
            }

            // 3. Insert OrderDetails
            try (PreparedStatement psDetail = con.prepareStatement(insertDetailSql)) {
                for (OrderDetail d : details) {
                    int dbProdId = productDbIdMap.getOrDefault(d.getProductId(), 1);
                    psDetail.setInt(1, orderId);
                    psDetail.setInt(2, dbProdId);
                    psDetail.setInt(3, d.getQuantity());
                    psDetail.setDouble(4, d.getUnitPrice());
                    psDetail.setDouble(5, d.getSubtotal());
                    psDetail.addBatch();
                }
                psDetail.executeBatch();
            }

            // 4. Trừ kho sản phẩm
            try (PreparedStatement psStock = con.prepareStatement(updateStockSql)) {
                for (OrderDetail d : details) {
                    int dbProdId = productDbIdMap.getOrDefault(d.getProductId(), 1);
                    psStock.setInt(1, d.getQuantity());
                    psStock.setInt(2, dbProdId);
                    psStock.addBatch();
                }
                psStock.executeBatch();
            }

            // 5. Cập nhật doanh số ca nếu có
            if (order.getShiftId() != null && order.getShiftId() > 0) {
                try (PreparedStatement psShift = con.prepareStatement(updateShiftSalesSql)) {
                    psShift.setDouble(1, order.getTotalAmount());
                    psShift.setInt(2, order.getShiftId());
                    psShift.executeUpdate();
                }
            }

            con.commit(); // Transaction thành công mỹ mãn!
            return true;

        } catch (Exception e) {
            if (con != null) {
                try {
                    con.rollback(); // Rollback nếu có lỗi
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
        } finally {
            if (con != null) {
                try {
                    con.setAutoCommit(true);
                    con.close();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
        return false;
    }

    /**
     * Lấy danh sách các đơn hàng đã tạo trong ngày hôm nay
     */
    public List<Order> getTodayOrders() {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT o.order_id AS id, o.order_code AS code, o.staff_id AS createdBy, " +
                "       ISNULL(u.full_name, N'Thu ngân') AS staffName, o.total_amount AS totalAmount, " +
                "       o.payment_method AS paymentMethod, o.status, o.created_at AS createdAt " +
                "FROM Orders o " +
                "LEFT JOIN Users u ON o.staff_id = u.user_id " +
                "WHERE CAST(o.created_at AS DATE) = CAST(GETDATE() AS DATE) " +
                "ORDER BY o.created_at DESC";

        try (Connection con = getConnection();
                PreparedStatement ps = con.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapOrder(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lấy danh sách đơn hàng gần đây với số lượng giới hạn
     */
    public List<Order> getRecentOrders(int limit) {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT TOP (?) o.order_id AS id, o.order_code AS code, o.staff_id AS createdBy, " +
                "       ISNULL(u.full_name, N'Thu ngân') AS staffName, o.total_amount AS totalAmount, " +
                "       o.payment_method AS paymentMethod, o.status, o.created_at AS createdAt " +
                "FROM Orders o " +
                "LEFT JOIN Users u ON o.staff_id = u.user_id " +
                "ORDER BY o.created_at DESC";

        try (Connection con = getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapOrder(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Tính tổng kết số liệu doanh thu và tồn kho cho Dashboard KPI
     */
    public Map<String, Object> getRevenueSummary() {
        Map<String, Object> summary = new HashMap<>();
        summary.put("todayRevenue", 0.0);
        summary.put("totalInventoryValue", 0.0);
        summary.put("lowStockCount", 0);
        summary.put("totalUnits", 0);

        String sqlRevenue = "SELECT COALESCE(SUM(total_amount), 0) AS todayRev FROM Orders " +
                "WHERE CAST(created_at AS DATE) = CAST(GETDATE() AS DATE)";
        String sqlStock = "SELECT COALESCE(SUM(stock_qty * cost_price), 0) AS totalCost, " +
                "       COALESCE(SUM(stock_qty), 0) AS totalUnits, " +
                "       COALESCE(SUM(CASE WHEN stock_qty <= min_stock_alert THEN 1 ELSE 0 END), 0) AS lowStock " +
                "FROM Products WHERE status = 'ACTIVE'";

        try (Connection con = getConnection()) {
            try (PreparedStatement psRev = con.prepareStatement(sqlRevenue);
                    ResultSet rsRev = psRev.executeQuery()) {
                if (rsRev.next()) {
                    summary.put("todayRevenue", rsRev.getDouble("todayRev"));
                }
            }

            try (PreparedStatement psStock = con.prepareStatement(sqlStock);
                    ResultSet rsStock = psStock.executeQuery()) {
                if (rsStock.next()) {
                    summary.put("totalInventoryValue", rsStock.getDouble("totalCost"));
                    summary.put("totalUnits", rsStock.getInt("totalUnits"));
                    summary.put("lowStockCount", rsStock.getInt("lowStock"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return summary;
    }

    /**
     * Lấy chi tiết đơn hàng theo orderId
     */
    public List<OrderDetail> getOrderDetails(int orderId) {
        List<OrderDetail> list = new ArrayList<>();
        String sql = "SELECT d.order_detail_id AS id, d.order_id AS orderId, CAST(d.product_id AS VARCHAR(50)) AS productId, " +
                "       ISNULL(p.product_name, N'Sản phẩm') AS productName, d.quantity, d.unit_price AS unitPrice, d.subtotal " +
                "FROM OrderDetails d " +
                "LEFT JOIN Products p ON d.product_id = p.product_id " +
                "WHERE d.order_id = ? ORDER BY d.order_detail_id ASC";

        try (Connection con = getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new OrderDetail(
                            rs.getInt("id"),
                            rs.getInt("orderId"),
                            rs.getString("productId"),
                            rs.getString("productName"),
                            rs.getInt("quantity"),
                            rs.getDouble("unitPrice"),
                            rs.getDouble("subtotal")));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    private Order mapOrder(ResultSet rs) throws Exception {
        int id = rs.getInt("id");
        String code = rs.getString("code");
        int createdBy = rs.getInt("createdBy");
        String staffName = rs.getString("staffName");
        double totalAmount = rs.getDouble("totalAmount");
        String paymentMethod = rs.getString("paymentMethod");
        String status = rs.getString("status");
        Timestamp createdAt = rs.getTimestamp("createdAt");

        return new Order(id, code, createdBy, staffName, totalAmount, paymentMethod, status, createdAt);
    }
}
