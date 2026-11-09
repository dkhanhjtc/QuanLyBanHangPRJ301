package dal;

import model.StockTransaction;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class StockTransactionDAO extends DBContext {

    public List<StockTransaction> getRecentTransactions(int limit) {
        List<StockTransaction> list = new ArrayList<>();
        String sql = "SELECT TOP (?) st.transaction_id, st.product_id, p.product_code, p.product_name, " +
                "       st.change_qty, st.stock_before, st.stock_after, st.transaction_type, " +
                "       st.reference_code, st.created_by, u.full_name AS createdByName, st.created_at, st.note " +
                "FROM StockTransactions st " +
                "JOIN Products p ON st.product_id = p.product_id " +
                "JOIN Users u ON st.created_by = u.user_id " +
                "ORDER BY st.created_at DESC";

        try (Connection con = getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapTransaction(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<StockTransaction> getTransactionsByProduct(int productId) {
        List<StockTransaction> list = new ArrayList<>();
        String sql = "SELECT st.transaction_id, st.product_id, p.product_code, p.product_name, " +
                "       st.change_qty, st.stock_before, st.stock_after, st.transaction_type, " +
                "       st.reference_code, st.created_by, u.full_name AS createdByName, st.created_at, st.note " +
                "FROM StockTransactions st " +
                "JOIN Products p ON st.product_id = p.product_id " +
                "JOIN Users u ON st.created_by = u.user_id " +
                "WHERE st.product_id = ? " +
                "ORDER BY st.created_at DESC";

        try (Connection con = getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapTransaction(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean logTransaction(int productId, int changeQty, int stockBefore, int stockAfter, String type,
            String refCode, int userId, String note) {
        String sql = "INSERT INTO StockTransactions (product_id, change_qty, stock_before, stock_after, transaction_type, reference_code, created_by, created_at, note) "
                +
                "VALUES (?, ?, ?, ?, ?, ?, ?, GETDATE(), ?)";

        try (Connection con = getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, productId);
            ps.setInt(2, changeQty);
            ps.setInt(3, stockBefore);
            ps.setInt(4, stockAfter);
            ps.setString(5, type);
            ps.setString(6, refCode);
            ps.setInt(7, userId);
            ps.setString(8, note);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    private StockTransaction mapTransaction(ResultSet rs) throws Exception {
        long id = rs.getLong("transaction_id");
        int prodId = rs.getInt("product_id");
        String code = rs.getString("product_code");
        String name = rs.getString("product_name");
        int change = rs.getInt("change_qty");
        int before = rs.getInt("stock_before");
        int after = rs.getInt("stock_after");
        String type = rs.getString("transaction_type");
        String refCode = rs.getString("reference_code");
        int userId = rs.getInt("created_by");
        String userName = rs.getString("createdByName");
        Timestamp createdAt = rs.getTimestamp("created_at");
        String note = rs.getString("note");

        return new StockTransaction(id, prodId, code, name, change, before, after, type, refCode, userId, userName,
                createdAt, note);
    }
}
