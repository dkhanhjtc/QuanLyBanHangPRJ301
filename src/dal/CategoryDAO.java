package dal;

import model.Category;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class CategoryDAO extends DBContext {

    /**
     * Lấy danh sách toàn bộ danh mục kèm số lượng sản phẩm liên kết
     */
    public List<Category> getAllCategories() {
        List<Category> list = new ArrayList<>();
        String sql = "SELECT c.category_id, c.category_name, c.description, " +
                     "       COUNT(p.product_id) AS product_count " +
                     "FROM Categories c " +
                     "LEFT JOIN Products p ON c.category_id = p.category_id AND p.status = 'ACTIVE' " +
                     "GROUP BY c.category_id, c.category_name, c.description " +
                     "ORDER BY c.category_id ASC";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(new Category(
                    rs.getInt("category_id"),
                    rs.getString("category_name"),
                    rs.getString("description"),
                    rs.getInt("product_count")
                ));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lấy thông tin danh mục theo ID
     */
    public Category getCategoryById(int id) {
        String sql = "SELECT category_id, category_name, description FROM Categories WHERE category_id = ?";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new Category(
                        rs.getInt("category_id"),
                        rs.getString("category_name"),
                        rs.getString("description")
                    );
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Thêm mới danh mục nhóm hàng
     */
    public boolean insertCategory(Category c) {
        String sql = "INSERT INTO Categories (category_name, description) VALUES (?, ?)";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, c.getCategoryName());
            ps.setString(2, c.getDescription());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Cập nhật tên và mô tả danh mục
     */
    public boolean updateCategory(Category c) {
        String sql = "UPDATE Categories SET category_name = ?, description = ? WHERE category_id = ?";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, c.getCategoryName());
            ps.setString(2, c.getDescription());
            ps.setInt(3, c.getCategoryId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Xóa danh mục (Tự động chuyển các sản phẩm thuộc danh mục này về danh mục mặc định #1 trước khi xóa)
     */
    public boolean deleteCategory(int id) {
        if (id == 1) {
            // Không cho phép xóa danh mục mặc định số 1
            return false;
        }

        String reassignProductsSql = "UPDATE Products SET category_id = 1 WHERE category_id = ?";
        String reassignStocktakesSql = "UPDATE Stocktakes SET category_id = 1 WHERE category_id = ?";
        String reassignAssignmentsSql = "UPDATE StocktakeAssignments SET category_id = 1 WHERE category_id = ?";
        String deleteSql = "DELETE FROM Categories WHERE category_id = ?";

        Connection con = null;
        try {
            con = getConnection();
            con.setAutoCommit(false);

            try (PreparedStatement psP = con.prepareStatement(reassignProductsSql)) {
                psP.setInt(1, id);
                psP.executeUpdate();
            }

            try (PreparedStatement psS = con.prepareStatement(reassignStocktakesSql)) {
                psS.setInt(1, id);
                psS.executeUpdate();
            }

            try (PreparedStatement psA = con.prepareStatement(reassignAssignmentsSql)) {
                psA.setInt(1, id);
                psA.executeUpdate();
            }

            try (PreparedStatement psD = con.prepareStatement(deleteSql)) {
                psD.setInt(1, id);
                psD.executeUpdate();
            }

            con.commit();
            return true;
        } catch (Exception e) {
            if (con != null) {
                try { con.rollback(); } catch (Exception ignored) {}
            }
            e.printStackTrace();
        }
        return false;
    }
}

