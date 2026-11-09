package dal;

import model.User;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class UserDAO extends DBContext {

    /**
     * Xác thực thông tin đăng nhập theo mã đăng nhập (hoặc số điện thoại) và mật khẩu plain-text.
     * Chỉ cho phép đăng nhập nếu tài khoản đang kích hoạt (isActive = 1).
     * @param loginCodeOrPhone Mã đăng nhập (ví dụ AN-QL-001) hoặc Số điện thoại (ví dụ 0909876543)
     * @param password Mật khẩu chuỗi thông thường (plain text)
     * @return User nếu thông tin chính xác và tài khoản active, ngược lại trả về null
     */
    public User login(String loginCodeOrPhone, String password) {
        String sql = "SELECT id, loginCode, phone, fullName, password, role, isActive, createdAt " +
                     "FROM Users " +
                     "WHERE (loginCode = ? OR phone = ? OR REPLACE(phone, ' ', '') = ?) " +
                     "  AND password = ? " +
                     "  AND isActive = 1";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            String cleanPhone = loginCodeOrPhone != null ? loginCodeOrPhone.replace(" ", "") : "";
            ps.setString(1, loginCodeOrPhone);
            ps.setString(2, loginCodeOrPhone);
            ps.setString(3, cleanPhone);
            ps.setString(4, password);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Lấy toàn bộ danh sách tài khoản người dùng trong hệ thống
     * @return List<User> danh sách người dùng
     */
    public List<User> getAllUsers() {
        List<User> list = new ArrayList<>();
        String sql = "SELECT id, loginCode, phone, fullName, password, role, isActive, createdAt " +
                     "FROM Users ORDER BY id ASC";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapUser(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lấy thông tin người dùng theo ID
     * @param userId ID người dùng
     * @return User đối tượng người dùng hoặc null
     */
    public User getUserById(int userId) {
        String sql = "SELECT id, loginCode, phone, fullName, password, role, isActive, createdAt " +
                     "FROM Users WHERE id = ?";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Chuyển đổi trạng thái hoạt động của người dùng (kích hoạt <-> thu hồi)
     * @param userId ID người dùng cần đổi trạng thái
     * @return true nếu cập nhật thành công, false nếu thất bại
     */
    public boolean toggleUserStatus(int userId) {
        String sql = "UPDATE Users SET isActive = CASE WHEN isActive = 1 THEN 0 ELSE 1 END WHERE id = ?";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Cập nhật vai trò người dùng (ADMIN, MANAGER, STAFF)
     * @param userId ID người dùng
     * @param role Vai trò mới
     * @return true nếu cập nhật thành công, false nếu thất bại
     */
    public boolean updateRole(int userId, String role) {
        String sql = "UPDATE Users SET role = ? WHERE id = ?";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, role.toUpperCase());
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Thêm tài khoản người dùng mới
     * @param u Đối tượng người dùng
     * @return true nếu thêm thành công, false nếu thất bại
     */
    public boolean addUser(User u) {
        String sql = "INSERT INTO Users (loginCode, phone, fullName, password, role, isActive, createdAt) " +
                     "VALUES (?, ?, ?, ?, ?, ?, GETDATE())";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, u.getLoginCode());
            ps.setString(2, u.getPhone());
            ps.setString(3, u.getFullName());
            ps.setString(4, u.getPassword());
            ps.setString(5, u.getRole().toUpperCase());
            ps.setBoolean(6, u.isIsActive());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    private User mapUser(ResultSet rs) throws Exception {
        int id = rs.getInt("id");
        String loginCode = rs.getString("loginCode");
        String phone = rs.getString("phone");
        String fullName = rs.getString("fullName");
        String password = rs.getString("password");
        String role = rs.getString("role");
        boolean isActive = rs.getBoolean("isActive");
        Timestamp createdAt = rs.getTimestamp("createdAt");
        return new User(id, loginCode, phone, fullName, password, role, isActive, createdAt);
    }
}

