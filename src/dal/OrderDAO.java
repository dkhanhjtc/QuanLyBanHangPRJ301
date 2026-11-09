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
     * 1. Kiểm tra tồn kho của từng sản phẩm trong giỏ hàng (nếu mua > tồn thì hủy
     * giao dịch)
     * 2. Insert vào bảng Orders lấy ID vừa tạo
     * 3. Insert danh sách vào OrderDetails
     * 4. Trừ tồn kho stockQuantity trong bảng Products
     * 5. Commit Transaction
     * 
     * @param order   Đối tượng đơn hàng
     * @param details Danh sách chi tiết đơn hàng
     * @return true nếu tạo đơn và trừ kho thành công, ngược lại rollback và trả về
     *         false
     */
    public boolean createOrder(Order order, List<OrderDetail> details) {
        if (details == null || details.isEmpty()) {
            return false;
        }

        String checkStockSql = "SELECT stockQuantity, name FROM Products WHERE id = ?";
        String insertOrderSql = "INSERT INTO Orders (code, createdBy, shift_id, totalAmount, paymentMethod, status, createdAt) "
                +
                "VALUES (?, ?, ?, ?, ?, ?, GETDATE())";
        String insertDetailSql = "INSERT INTO OrderDetails (orderId, productId, productName, quantity, unitPrice, subtotal) "
                +
                "VALUES (?, ?, ?, ?, ?, ?)";
        String updateStockSql = "UPDATE Products SET stockQuantity = stockQuantity - ? WHERE id = ?";
        String updateShiftSalesSql = "UPDATE WorkShifts SET total_sales = total_sales + ? WHERE shift_id = ?";

        Connection con = null;
        try {
            con = getConnection();
            con.setAutoCommit(false); // Bắt đầu Transaction an toàn

            // 1. Kiểm tra tồn kho của tất cả sản phẩm trong giỏ
            try (PreparedStatement psCheck = con.prepareStatement(checkStockSql)) {
                for (OrderDetail d : details) {
                    psCheck.setString(1, d.getProductId());
                    try (ResultSet rs = psCheck.executeQuery()) {
                        if (rs.next()) {
                            int currentStock = rs.getInt("stockQuantity");
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
                    psDetail.setInt(1, orderId);
                    psDetail.setString(2, d.getProductId());
                    psDetail.setString(3, d.getProductName());
                    psDetail.setInt(4, d.getQuantity());
                    psDetail.setDouble(5, d.getUnitPrice());
                    psDetail.setDouble(6, d.getSubtotal());
                    psDetail.addBatch();
                }
                psDetail.executeBatch();
            }

            // 4. Trừ tồn kho Products
            try (PreparedStatement psStock = con.prepareStatement(updateStockSql)) {
                for (OrderDetail d : details) {
                    psStock.setInt(1, d.getQuantity());
                    psStock.setString(2, d.getProductId());
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

            con.commit(); // Transaction hoàn thành thành công
            return true;
        } catch (Exception e) {
            if (con != null) {
                try {
                    con.rollback();
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
     * 
     * @return List<Order> danh sách đơn hàng hôm nay
     */
    public List<Order> getTodayOrders() {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT o.id, o.code, o.createdBy, u.fullName AS staffName, o.totalAmount, " +
                "       o.paymentMethod, o.status, o.createdAt " +
                "FROM Orders o " +
                "JOIN Users u ON o.createdBy = u.id " +
                "WHERE CAST(o.createdAt AS DATE) = CAST(GETDATE() AS DATE) " +
                "ORDER BY o.createdAt DESC";

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
     * 
     * @param limit Số lượng đơn tối đa cần lấy
     * @return List<Order> danh sách đơn hàng
     */
    public List<Order> getRecentOrders(int limit) {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT TOP (?) o.id, o.code, o.createdBy, u.fullName AS staffName, o.totalAmount, " +
                "       o.paymentMethod, o.status, o.createdAt " +
                "FROM Orders o " +
                "JOIN Users u ON o.createdBy = u.id " +
                "ORDER BY o.createdAt DESC";

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
     * 
     * @return Map chứa các chỉ số: todayRevenue, totalInventoryValue,
     *         lowStockCount, totalUnits
     */
    public Map<String, Object> getRevenueSummary() {
        Map<String, Object> summary = new HashMap<>();
        summary.put("todayRevenue", 0.0);
        summary.put("totalInventoryValue", 0.0);
        summary.put("lowStockCount", 0);
        summary.put("totalUnits", 0);

        String sqlRevenue = "SELECT COALESCE(SUM(totalAmount), 0) AS todayRev FROM Orders " +
                "WHERE CAST(createdAt AS DATE) = CAST(GETDATE() AS DATE)";
        String sqlStock = "SELECT COALESCE(SUM(stockQuantity * costPrice), 0) AS totalCost, " +
                "       COALESCE(SUM(stockQuantity), 0) AS totalUnits, " +
                "       COALESCE(SUM(CASE WHEN stockQuantity <= minStock THEN 1 ELSE 0 END), 0) AS lowStock " +
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
        String sql = "SELECT id, orderId, productId, productName, quantity, unitPrice, subtotal " +
                "FROM OrderDetails WHERE orderId = ? ORDER BY id ASC";

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
