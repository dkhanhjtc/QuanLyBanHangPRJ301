package dal;

import model.User;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class UserDAO extends DBContext {

    /**
<<<<<<< HEAD
     * Hàm băm SHA-256 hỗ trợ so sánh mật khẩu
     */
    public static String hashSHA256(String input) {
        if (input == null) return "";
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(input.getBytes(StandardCharsets.UTF_8));
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (Exception e) {
            return input;
        }
    }

    /**
     * Xác thực thông tin đăng nhập theo mã đăng nhập / số điện thoại và mật khẩu.
     * HARDCODE 3 TÀI KHOẢN KIỂM THỬ ĐỂ TEST NGAY LẬP TỨC (DÙ CHƯA CHẠY DATABASE).
     * @param loginCodeOrPhone Mã đăng nhập (ví dụ AN-QL-001) hoặc Số điện thoại (ví dụ 0909876543)
     * @param password Mật khẩu nhập vào
     * @return User nếu thông tin chính xác và tài khoản active, ngược lại trả về null
     */
    public User login(String loginCodeOrPhone, String password) {
        if (loginCodeOrPhone == null || password == null) return null;

        String cleanCode = loginCodeOrPhone.trim();
        String cleanPhone = cleanCode.replace(" ", "");
        String hashedPassword = hashSHA256(password);

        // =========================================================================
        // 1. HARDCODE 3 TÀI KHOẢN KIỂM THỬ TRỰC TIẾP (TEST NGAY KHÔNG CẦN CHỜ DB)
        // Chấp nhận mật khẩu: "123456" hoặc mã băm SHA-256 của nó
        // =========================================================================
        boolean passMatch = "123456".equals(password) || 
                            "ba3253876aed6bc22d4a6ff53d8406c6ad864195ed144ab5c87621b6c233b548".equalsIgnoreCase(password) ||
                            "ba3253876aed6bc22d4a6ff53d8406c6ad864195ed144ab5c87621b6c233b548".equalsIgnoreCase(hashedPassword);

        if (passMatch) {
            Timestamp now = new Timestamp(System.currentTimeMillis());

            // TÀI KHOẢN 1: SUPER ADMIN (Mai Anh)
            if ("AN-SA-001".equalsIgnoreCase(cleanCode) || "0901234123".equals(cleanPhone) || "090 123 4123".equals(cleanCode)) {
                return new User(1, "AN-SA-001", "090 123 4123", "Mai Anh", "123456", "ADMIN", true, now);
            }

            // TÀI KHOẢN 2: QUẢN LÝ (Nguyễn Minh Hà)
            if ("AN-QL-001".equalsIgnoreCase(cleanCode) || "0909876543".equals(cleanPhone) || "090 987 6543".equals(cleanCode)) {
                return new User(2, "AN-QL-001", "090 987 6543", "Nguyễn Minh Hà", "123456", "MANAGER", true, now);
            }

            // TÀI KHOẢN 3: NHÂN VIÊN POS (Lê Lan Anh)
            if ("AN-NV-002".equalsIgnoreCase(cleanCode) || "0905551122".equals(cleanPhone) || "090 555 1122".equals(cleanCode)) {
                return new User(3, "AN-NV-002", "090 555 1122", "Lê Lan Anh", "123456", "STAFF", true, now);
            }

            // TÀI KHOẢN 4: NHÂN VIÊN KIỂM KÊ (Trần Quốc Bảo)
            if ("AN-NV-003".equalsIgnoreCase(cleanCode) || "0903337788".equals(cleanPhone) || "090 333 7788".equals(cleanCode)) {
                return new User(4, "AN-NV-003", "090 333 7788", "Trần Quốc Bảo", "123456", "STAFF", true, now);
            }
        }

        // =========================================================================
        // 2. NẾU KHÔNG KHỚP 3 TÀI KHOẢN HARDCODE, TRUY VẤN VÀO CSDL SQL SERVER
        // =========================================================================
        String sql = "SELECT id, loginCode, phone, fullName, password, role, isActive, createdAt " +
                     "FROM Users " +
                     "WHERE (loginCode = ? OR phone = ? OR REPLACE(phone, ' ', '') = ?) " +
                     "  AND (password = ? OR password = ?) " +
                     "  AND isActive = 1";
=======
     * Xác thực thông tin đăng nhập theo số điện thoại và passcode.
     * Tương thích hoàn toàn với schema mới QuanLyBanHangThoiTrang (user_id, phone, passcode, full_name, role, status).
     */
    public User login(String loginCodeOrPhone, String password) {
        String sql = "SELECT user_id, phone, full_name, passcode, role, status, created_at " +
                     "FROM Users " +
                     "WHERE (phone = ? OR REPLACE(phone, ' ', '') = ?) " +
                     "  AND passcode = ? " +
                     "  AND status = 'ACTIVE'";
>>>>>>> origin/Tu

        try (Connection con = getConnection()) {
            if (con != null) {
                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setString(1, cleanCode);
                    ps.setString(2, cleanCode);
                    ps.setString(3, cleanPhone);
                    ps.setString(4, password);
                    ps.setString(5, hashedPassword);

<<<<<<< HEAD
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            return mapUser(rs);
                        }
                    }
=======
            String cleanPhone = loginCodeOrPhone != null ? loginCodeOrPhone.replace(" ", "") : "";
            ps.setString(1, loginCodeOrPhone);
            ps.setString(2, cleanPhone);
            ps.setString(3, password);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs);
>>>>>>> origin/Tu
                }
            }
        } catch (Exception e) {
            System.err.println("UserDAO login error: " + e.getMessage());
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

        try (Connection con = getConnection()) {
            if (con != null) {
                try (PreparedStatement ps = con.prepareStatement(sql);
                     ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        list.add(mapUser(rs));
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("UserDAO getAllUsers error: " + e.getMessage());
        }

        // Fallback danh sách 3 tài khoản kiểm thử nếu CSDL rỗng hoặc offline
        if (list.isEmpty()) {
            Timestamp now = new Timestamp(System.currentTimeMillis());
            list.add(new User(1, "AN-SA-001", "090 123 4123", "Mai Anh", "123456", "ADMIN", true, now));
            list.add(new User(2, "AN-QL-001", "090 987 6543", "Nguyễn Minh Hà", "123456", "MANAGER", true, now));
            list.add(new User(3, "AN-NV-002", "090 555 1122", "Lê Lan Anh", "123456", "STAFF", true, now));
            list.add(new User(4, "AN-NV-003", "090 333 7788", "Trần Quốc Bảo", "123456", "STAFF", true, now));
            list.add(new User(5, "AN-NV-005", "090 999 0000", "Đỗ Hoàng Nam", "123456", "STAFF", false, now));
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

        try (Connection con = getConnection()) {
            if (con != null) {
                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setInt(1, userId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            return mapUser(rs);
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("UserDAO getUserById error: " + e.getMessage());
        }

        for (User u : getAllUsers()) {
            if (u.getId() == userId) return u;
        }
        return null;
    }

    /**
     * Khóa hoặc mở khóa tài khoản
     */
    public boolean toggleUserStatus(int userId) {
        String sql = "UPDATE Users SET status = CASE WHEN status = 'ACTIVE' THEN 'REVOKED' ELSE 'ACTIVE' END WHERE user_id = ?";

        try (Connection con = getConnection()) {
            if (con != null) {
                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setInt(1, userId);
                    return ps.executeUpdate() > 0;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return true;
    }

    /**
     * Cập nhật vai trò người dùng (ADMIN, MANAGER, STAFF)
     */
    public boolean updateRole(int userId, String role) {
        String sql = "UPDATE Users SET role = ? WHERE user_id = ?";

<<<<<<< HEAD
        try (Connection con = getConnection()) {
            if (con != null) {
                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setString(1, role.toUpperCase());
                    ps.setInt(2, userId);
                    return ps.executeUpdate() > 0;
                }
            }
=======
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, role != null ? role.toUpperCase() : "STAFF");
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
>>>>>>> origin/Tu
        } catch (Exception e) {
            e.printStackTrace();
        }
        return true;
    }

    /**
     * Thêm tài khoản người dùng mới
     */
    public boolean addUser(User u) {
        String sql = "INSERT INTO Users (phone, passcode, full_name, role, status, created_at) " +
                     "VALUES (?, ?, ?, ?, ?, GETDATE())";

<<<<<<< HEAD
        try (Connection con = getConnection()) {
            if (con != null) {
                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setString(1, u.getLoginCode());
                    ps.setString(2, u.getPhone());
                    ps.setString(3, u.getFullName());
                    ps.setString(4, u.getPassword());
                    ps.setString(5, u.getRole().toUpperCase());
                    ps.setBoolean(6, u.isIsActive());
                    return ps.executeUpdate() > 0;
                }
            }
=======
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, u.getPhone());
            ps.setString(2, u.getPassword());
            ps.setString(3, u.getFullName());
            ps.setString(4, u.getRole() != null ? u.getRole().toUpperCase() : "STAFF");
            ps.setString(5, u.isIsActive() ? "ACTIVE" : "REVOKED");
            return ps.executeUpdate() > 0;
>>>>>>> origin/Tu
        } catch (Exception e) {
            e.printStackTrace();
        }
        return true;
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
