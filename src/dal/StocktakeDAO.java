package dal;

import model.Stocktake;
import model.StocktakeItem;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class StocktakeDAO extends DBContext {

    /**
     * Lấy danh sách toàn bộ các đợt kiểm kê định kỳ
     * @return List<Stocktake> danh sách phân công kiểm kê
     */
    public List<Stocktake> getAllStocktakes() {
        List<Stocktake> list = new ArrayList<>();
        String sql = "SELECT s.stocktake_id AS id, " +
                     "       s.stocktake_code AS code, " +
                     "       s.title, " +
                     "       ISNULL(u.full_name, N'Nhân viên') AS assignedTo, " +
                     "       s.status, " +
                     "       ISNULL((SELECT SUM(d.discrepancy) FROM StocktakeDetails d WHERE d.stocktake_id = s.stocktake_id), 0) AS totalVariance, " +
                     "       s.created_at AS createdAt " +
                     "FROM Stocktakes s " +
                     "LEFT JOIN Users u ON s.assigned_staff_id = u.user_id " +
                     "ORDER BY s.created_at DESC";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Stocktake st = mapStocktake(rs);
                st.setItems(getStocktakeItems(st.getId()));
                list.add(st);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lấy danh sách các đợt kiểm kê được phân công riêng cho một nhân viên thu ngân
     */
    public List<Stocktake> getStocktakesByStaff(int staffId, String staffName) {
        List<Stocktake> list = new ArrayList<>();
        String sql = "SELECT s.stocktake_id AS id, " +
                     "       s.stocktake_code AS code, " +
                     "       s.title, " +
                     "       ISNULL(u.full_name, N'Nhân viên') AS assignedTo, " +
                     "       s.status, " +
                     "       ISNULL((SELECT SUM(d.discrepancy) FROM StocktakeDetails d WHERE d.stocktake_id = s.stocktake_id), 0) AS totalVariance, " +
                     "       s.created_at AS createdAt " +
                     "FROM Stocktakes s " +
                     "LEFT JOIN Users u ON s.assigned_staff_id = u.user_id " +
                     "WHERE s.assigned_staff_id = ? OR (? IS NOT NULL AND u.full_name = ?) " +
                     "ORDER BY s.created_at DESC";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, staffId);
            ps.setString(2, staffName);
            ps.setString(3, staffName);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Stocktake st = mapStocktake(rs);
                    st.setItems(getStocktakeItems(st.getId()));
                    list.add(st);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lấy thông tin đợt kiểm kê theo ID
     */
    public Stocktake getStocktakeById(int id) {
        String sql = "SELECT s.stocktake_id AS id, " +
                     "       s.stocktake_code AS code, " +
                     "       s.title, " +
                     "       ISNULL(u.full_name, N'Nhân viên') AS assignedTo, " +
                     "       s.status, " +
                     "       ISNULL((SELECT SUM(d.discrepancy) FROM StocktakeDetails d WHERE d.stocktake_id = s.stocktake_id), 0) AS totalVariance, " +
                     "       s.created_at AS createdAt " +
                     "FROM Stocktakes s " +
                     "LEFT JOIN Users u ON s.assigned_staff_id = u.user_id " +
                     "WHERE s.stocktake_id = ?";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Stocktake st = mapStocktake(rs);
                    st.setItems(getStocktakeItems(st.getId()));
                    return st;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Lấy thông tin đợt kiểm kê theo mã phiếu (ví dụ: "KK-101")
     */
    public Stocktake getStocktakeByCode(String code) {
        String sql = "SELECT s.stocktake_id AS id, " +
                     "       s.stocktake_code AS code, " +
                     "       s.title, " +
                     "       ISNULL(u.full_name, N'Nhân viên') AS assignedTo, " +
                     "       s.status, " +
                     "       ISNULL((SELECT SUM(d.discrepancy) FROM StocktakeDetails d WHERE d.stocktake_id = s.stocktake_id), 0) AS totalVariance, " +
                     "       s.created_at AS createdAt " +
                     "FROM Stocktakes s " +
                     "LEFT JOIN Users u ON s.assigned_staff_id = u.user_id " +
                     "WHERE s.stocktake_code = ?";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, code);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Stocktake st = mapStocktake(rs);
                    st.setItems(getStocktakeItems(st.getId()));
                    return st;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Lấy danh sách các mặt hàng được kiểm kê trong phiếu kèm số đếm thực tế và sai lệch
     */
    public List<StocktakeItem> getStocktakeItems(int stocktakeId) {
        List<StocktakeItem> list = new ArrayList<>();
        String sql = "SELECT d.item_id AS id, " +
                     "       d.stocktake_id AS stocktakeId, " +
                     "       CAST(p.product_id AS VARCHAR(50)) AS productId, " +
                     "       p.product_name AS productName, " +
                     "       d.system_qty AS systemStock, " +
                     "       d.actual_qty AS actualStock, " +
                     "       d.discrepancy AS variance, " +
                     "       d.note, " +
                     "       p.cost_price AS costPrice, " +
                     "       p.image_url AS imageUrl, " +
                     "       (ISNULL(p.size, '') + ' · ' + ISNULL(p.color, '')) AS spec " +
                     "FROM StocktakeDetails d " +
                     "JOIN Products p ON d.product_id = p.product_id " +
                     "WHERE d.stocktake_id = ? " +
                     "ORDER BY d.item_id ASC";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, stocktakeId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new StocktakeItem(
                        rs.getInt("id"),
                        rs.getInt("stocktakeId"),
                        rs.getString("productId"),
                        rs.getString("productName"),
                        rs.getInt("systemStock"),
                        rs.getInt("actualStock"),
                        rs.getInt("variance"),
                        rs.getString("note"),
                        rs.getDouble("costPrice"),
                        rs.getString("imageUrl"),
                        rs.getString("spec")
                    ));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Quản lý tạo phân công kiểm kê mới
     */
    public boolean createStocktake(String code, String title, int staffId) {
        return createStocktake(code, title, staffId, 2, null);
    }

    public boolean createStocktake(String code, String title, int staffId, int managerId, Integer categoryId) {
        String sql = "INSERT INTO Stocktakes (stocktake_code, title, assigned_staff_id, manager_id, category_id, status, created_at) " +
                     "VALUES (?, ?, ?, ?, ?, 'ASSIGNED', GETDATE())";

        String insertDetailsSql = "INSERT INTO StocktakeDetails (stocktake_id, product_id, system_qty, actual_qty, note) " +
                                  "SELECT ?, product_id, stock_qty, stock_qty, N'Chờ nhân viên kiểm đếm' " +
                                  "FROM Products " +
                                  "WHERE (? IS NULL OR ? = 0 OR category_id = ?) AND status = 'ACTIVE'";

        Connection con = null;
        try {
            con = getConnection();
            con.setAutoCommit(false);

            int newStocktakeId = 0;
            try (PreparedStatement ps = con.prepareStatement(sql, java.sql.Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, code);
                ps.setString(2, title);
                ps.setInt(3, staffId);
                ps.setInt(4, managerId > 0 ? managerId : 2);
                if (categoryId != null && categoryId > 0) {
                    ps.setInt(5, categoryId);
                } else {
                    ps.setNull(5, java.sql.Types.INTEGER);
                }
                ps.executeUpdate();
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        newStocktakeId = rs.getInt(1);
                    }
                }
            }

            if (newStocktakeId > 0) {
                try (PreparedStatement psDetails = con.prepareStatement(insertDetailsSql)) {
                    psDetails.setInt(1, newStocktakeId);
                    if (categoryId != null && categoryId > 0) {
                        psDetails.setInt(2, categoryId);
                        psDetails.setInt(3, categoryId);
                        psDetails.setInt(4, categoryId);
                    } else {
                        psDetails.setNull(2, java.sql.Types.INTEGER);
                        psDetails.setInt(3, 0);
                        psDetails.setInt(4, 0);
                    }
                    psDetails.executeUpdate();
                }
            }

            con.commit();
            return true;
        } catch (Exception e) {
            if (con != null) {
                try { con.rollback(); } catch (Exception ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
        } finally {
            if (con != null) {
                try { con.setAutoCommit(true); con.close(); } catch (Exception ignored) {}
            }
        }
        return false;
    }

    /**
     * Nhân viên cập nhật số thực đếm và gửi kết quả lên hệ thống để chờ quản lý đối soát
     */
    public boolean submitStaffCount(int itemId, int actualQty, String note) {
        String sql = "UPDATE StocktakeDetails SET actual_qty = ?, note = ? WHERE item_id = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, actualQty);
            ps.setString(2, note);
            ps.setInt(3, itemId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean markStocktakeAsCounted(int stocktakeId) {
        String sql = "UPDATE Stocktakes SET status = 'COUNTED' WHERE stocktake_id = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, stocktakeId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Duyệt kết quả đối soát kiểm kê.
     * Sử dụng Transaction:
     * 1. Cập nhật tồn kho sản phẩm trong bảng Products bằng số lượng thực đếm (actual_qty)
     * 2. Đổi trạng thái phiếu kiểm kê thành 'APPROVED'
     * 3. Commit Transaction
     */
    public boolean approveStocktake(int stocktakeId) {
        String updateStockSql = "UPDATE p " +
                                "SET p.stock_qty = d.actual_qty " +
                                "FROM Products p " +
                                "JOIN StocktakeDetails d ON p.product_id = d.product_id " +
                                "WHERE d.stocktake_id = ?";
        String updateStatusSql = "UPDATE Stocktakes SET status = 'APPROVED' WHERE stocktake_id = ?";

        Connection con = null;
        try {
            con = getConnection();
            con.setAutoCommit(false); // Bắt đầu Transaction

            // 1. Cập nhật tồn kho từng sản phẩm theo số thực đếm
            try (PreparedStatement psStock = con.prepareStatement(updateStockSql)) {
                psStock.setInt(1, stocktakeId);
                psStock.executeUpdate();
            }

            // 2. Đổi trạng thái phiếu kiểm kê
            try (PreparedStatement psStatus = con.prepareStatement(updateStatusSql)) {
                psStatus.setInt(1, stocktakeId);
                psStatus.executeUpdate();
            }

            con.commit(); // Transaction hoàn tất
            return true;
        } catch (Exception e) {
            if (con != null) {
                try { con.rollback(); } catch (Exception ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
        } finally {
            if (con != null) {
                try { con.setAutoCommit(true); con.close(); } catch (Exception e) { e.printStackTrace(); }
            }
        }
        return false;
    }

    private Stocktake mapStocktake(ResultSet rs) throws Exception {
        int id = rs.getInt("id");
        String code = rs.getString("code");
        String title = rs.getString("title");
        String assignedTo = rs.getString("assignedTo");
        String status = rs.getString("status");
        int totalVariance = rs.getInt("totalVariance");
        Timestamp createdAt = rs.getTimestamp("createdAt");

        return new Stocktake(id, code, title, assignedTo, status, totalVariance, createdAt);
    }
}
