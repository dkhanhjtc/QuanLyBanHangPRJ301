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
                list.add(mapStocktake(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lấy thông tin đợt kiểm kê theo ID
     * @param id ID đợt kiểm kê
     * @return Stocktake đối tượng kiểm kê hoặc null
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
     * @param code Mã phiếu kiểm kê
     * @return Stocktake đối tượng kiểm kê kèm danh sách chi tiết mặt hàng
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
     * @param stocktakeId ID của đợt kiểm kê
     * @return List<StocktakeItem> danh sách chi tiết kiểm kê
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
     * Duyệt kết quả đối soát kiểm kê.
     * Sử dụng Transaction:
     * 1. Cập nhật tồn kho sản phẩm trong bảng Products bằng số lượng thực đếm (actual_qty)
     * 2. Đổi trạng thái phiếu kiểm kê thành 'APPROVED'
     * 3. Commit Transaction
     * @param stocktakeId ID của đợt kiểm kê
     * @return true nếu duyệt và cân bằng kho thành công, ngược lại rollback và trả về false
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

    public List<model.StocktakeAssignment> getAssignmentsByStaff(int staffId) {
        List<model.StocktakeAssignment> list = new ArrayList<>();
        String sql = "SELECT sa.assignment_id, sa.stocktake_id, s.stocktake_code, sa.staff_id, u.full_name AS staffName, " +
                     "       sa.category_id, c.category_name AS categoryName, sa.assigned_date, sa.deadline, sa.status " +
                     "FROM StocktakeAssignments sa " +
                     "JOIN Stocktakes s ON sa.stocktake_id = s.stocktake_id " +
                     "JOIN Users u ON sa.staff_id = u.user_id " +
                     "JOIN Categories c ON sa.category_id = c.category_id " +
                     "WHERE sa.staff_id = ? ORDER BY sa.assigned_date DESC";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, staffId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int aId = rs.getInt("assignment_id");
                    int sId = rs.getInt("stocktake_id");
                    String sCode = rs.getString("stocktake_code");
                    int stId = rs.getInt("staff_id");
                    String stName = rs.getString("staffName");
                    int cId = rs.getInt("category_id");
                    String cName = rs.getString("categoryName");
                    Timestamp aDate = rs.getTimestamp("assigned_date");
                    Timestamp dead = rs.getTimestamp("deadline");
                    String stat = rs.getString("status");

                    list.add(new model.StocktakeAssignment(aId, sId, sCode, stId, stName, cId, cName, aDate, dead, stat));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean createAssignment(int stocktakeId, int staffId, int categoryId, Timestamp deadline) {
        String sql = "INSERT INTO StocktakeAssignments (stocktake_id, staff_id, category_id, assigned_date, deadline, status) " +
                     "VALUES (?, ?, ?, GETDATE(), ?, 'PENDING')";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, stocktakeId);
            ps.setInt(2, staffId);
            ps.setInt(3, categoryId);
            ps.setTimestamp(4, deadline);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
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

