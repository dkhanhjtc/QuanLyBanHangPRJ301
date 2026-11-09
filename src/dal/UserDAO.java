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
     * Xác thực thông tin đăng nhập theo số điện thoại và passcode.
     * Tương thích hoàn toàn với schema mới QuanLyBanHangThoiTrang (user_id, phone, passcode, full_name, role, status).
     */
    public User login(String loginCodeOrPhone, String password) {
        String sql = "SELECT user_id, phone, full_name, passcode, role, status, created_at " +
                     "FROM Users " +
                     "WHERE (phone = ? OR REPLACE(phone, ' ', '') = ?) " +
                     "  AND passcode = ? " +
                     "  AND status = 'ACTIVE'";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            String cleanPhone = loginCodeOrPhone != null ? loginCodeOrPhone.replace(" ", "") : "";
            ps.setString(1, loginCodeOrPhone);
            ps.setString(2, cleanPhone);
            ps.setString(3, password);

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
        String sql = "SELECT user_id, phone, full_name, passcode, role, status, created_at " +
                     "FROM Users ORDER BY user_id ASC";

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
        String sql = "SELECT user_id, phone, full_name, passcode, role, status, created_at " +
                     "FROM Users WHERE user_id = ?";

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
     * Khóa hoặc mở khóa tài khoản
     */
    public boolean toggleUserStatus(int userId) {
        String sql = "UPDATE Users SET status = CASE WHEN status = 'ACTIVE' THEN 'REVOKED' ELSE 'ACTIVE' END WHERE user_id = ?";

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
     */
    public boolean updateRole(int userId, String role) {
        String sql = "UPDATE Users SET role = ? WHERE user_id = ?";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, role != null ? role.toUpperCase() : "STAFF");
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Thêm tài khoản người dùng mới
     */
    public boolean addUser(User u) {
        String sql = "INSERT INTO Users (phone, passcode, full_name, role, status, created_at) " +
                     "VALUES (?, ?, ?, ?, ?, GETDATE())";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, u.getPhone());
            ps.setString(2, u.getPassword());
            ps.setString(3, u.getFullName());
            ps.setString(4, u.getRole() != null ? u.getRole().toUpperCase() : "STAFF");
            ps.setString(5, u.isIsActive() ? "ACTIVE" : "REVOKED");
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    private User mapUser(ResultSet rs) throws Exception {
        int id = rs.getInt("user_id");
        String phone = rs.getString("phone");
        String fullName = rs.getString("full_name");
        String password = rs.getString("passcode");
        String role = rs.getString("role");
        String status = rs.getString("status");
        boolean isActive = "ACTIVE".equalsIgnoreCase(status);
        Timestamp createdAt = rs.getTimestamp("created_at");
        return new User(id, phone, phone, fullName, password, role, isActive, createdAt);
    }
}
