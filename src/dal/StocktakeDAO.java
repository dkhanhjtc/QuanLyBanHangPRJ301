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
        String sql = "SELECT id, code, title, assignedTo, status, totalVariance, createdAt " +
                     "FROM Stocktakes ORDER BY createdAt DESC";

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
        String sql = "SELECT id, code, title, assignedTo, status, totalVariance, createdAt " +
                     "FROM Stocktakes WHERE id = ?";

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
        String sql = "SELECT id, code, title, assignedTo, status, totalVariance, createdAt " +
                     "FROM Stocktakes WHERE code = ?";

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
        String sql = "SELECT si.id, si.stocktakeId, si.productId, si.productName, si.systemStock, " +
                     "       si.actualStock, si.variance, si.note, p.costPrice, p.imageUrl, p.spec " +
                     "FROM StocktakeItems si " +
                     "JOIN Products p ON si.productId = p.id " +
                     "WHERE si.stocktakeId = ? " +
                     "ORDER BY si.id ASC";

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
     * 1. Cập nhật tồn kho sản phẩm trong bảng Products bằng số lượng thực đếm (actualStock)
     * 2. Đổi trạng thái phiếu kiểm kê thành 'COMPLETED'
     * 3. Commit Transaction
     * @param stocktakeId ID của đợt kiểm kê
     * @return true nếu duyệt và cân bằng kho thành công, ngược lại rollback và trả về false
     */
    public boolean approveStocktake(int stocktakeId) {
        String getItemsSql = "SELECT productId, actualStock FROM StocktakeItems WHERE stocktakeId = ?";
        String updateStockSql = "UPDATE Products SET stockQuantity = ? WHERE id = ?";
        String updateStatusSql = "UPDATE Stocktakes SET status = 'COMPLETED' WHERE id = ?";

        Connection con = null;
        try {
            con = getConnection();
            con.setAutoCommit(false); // Bắt đầu Transaction

            // 1. Cập nhật tồn kho từng sản phẩm theo số thực đếm
            try (PreparedStatement psGet = con.prepareStatement(getItemsSql);
                 PreparedStatement psUpdate = con.prepareStatement(updateStockSql)) {

                psGet.setInt(1, stocktakeId);
                try (ResultSet rs = psGet.executeQuery()) {
                    while (rs.next()) {
                        String prodId = rs.getString("productId");
                        int actualStock = rs.getInt("actualStock");

                        psUpdate.setInt(1, actualStock);
                        psUpdate.setString(2, prodId);
                        psUpdate.addBatch();
                    }
                }
                psUpdate.executeBatch();
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

