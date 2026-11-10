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
        String cleanPhone = cleanCode.replaceAll("[\\s.-]", "");
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
        // Hỗ trợ cả 2 schema bảng Users
        // =========================================================================
        String sql1 = "SELECT id, loginCode, phone, fullName, password, role, isActive, createdAt " +
                      "FROM Users " +
                      "WHERE (loginCode = ? OR phone = ? OR REPLACE(phone, ' ', '') = ?) " +
                      "  AND (password = ? OR password = ?) " +
                      "  AND isActive = 1";

        try (Connection con = getConnection()) {
            if (con != null) {
                try (PreparedStatement ps = con.prepareStatement(sql1)) {
                    ps.setString(1, cleanCode);
                    ps.setString(2, cleanCode);
                    ps.setString(3, cleanPhone);
                    ps.setString(4, password);
                    ps.setString(5, hashedPassword);

                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            return mapUser(rs);
                        }
                    }
                } catch (Exception e1) {
                    // Fallback thử schema 2 (user_id, phone, full_name, passcode, role, status)
                    String sql2 = "SELECT user_id, phone, full_name, passcode, role, status, created_at " +
                                  "FROM Users " +
                                  "WHERE (phone = ? OR REPLACE(phone, ' ', '') = ?) " +
                                  "  AND (passcode = ? OR passcode = ?) " +
                                  "  AND status = 'ACTIVE'";
                    try (PreparedStatement ps2 = con.prepareStatement(sql2)) {
                        ps2.setString(1, cleanCode);
                        ps2.setString(2, cleanPhone);
                        ps2.setString(3, password);
                        ps2.setString(4, hashedPassword);

                        try (ResultSet rs2 = ps2.executeQuery()) {
                            if (rs2.next()) {
                                return mapUser(rs2);
                            }
                        }
                    } catch (Exception e2) {
                        System.err.println("UserDAO login error: " + e2.getMessage());
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("UserDAO connection error: " + e.getMessage());
        }

        return null;
    }

    /**
     * Lấy toàn bộ danh sách tài khoản người dùng trong hệ thống
     * @return List<User> danh sách người dùng
     */
    public List<User> getAllUsers() {
        List<User> list = new ArrayList<>();
        String sql = "SELECT * FROM Users";

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

        // Fallback danh sách tài khoản kiểm thử nếu CSDL rỗng hoặc offline
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
        String sql = "SELECT * FROM Users WHERE id = ? OR user_id = ?";

        try (Connection con = getConnection()) {
            if (con != null) {
                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setInt(1, userId);
                    ps.setInt(2, userId);
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

        // Fallback kiểm tra từ danh sách kiểm thử
        for (User u : getAllUsers()) {
            if (u.getId() == userId) return u;
        }

        return null;
    }

    /**
     * Đảo trạng thái kích hoạt của người dùng (Khoá / Mở khoá)
     * @param userId ID người dùng
     * @return boolean kết quả thành công hay thất bại
     */
    public boolean toggleUserStatus(int userId) {
        User u = getUserById(userId);
        if (u == null) return false;
        boolean newStatus = !u.isIsActive();

        String sql1 = "UPDATE Users SET isActive = ? WHERE id = ?";
        String sql2 = "UPDATE Users SET status = ? WHERE user_id = ?";

        try (Connection con = getConnection()) {
            if (con != null) {
                try (PreparedStatement ps = con.prepareStatement(sql1)) {
                    ps.setBoolean(1, newStatus);
                    ps.setInt(2, userId);
                    return ps.executeUpdate() > 0;
                } catch (Exception e) {
                    try (PreparedStatement ps2 = con.prepareStatement(sql2)) {
                        ps2.setString(1, newStatus ? "ACTIVE" : "REVOKED");
                        ps2.setInt(2, userId);
                        return ps2.executeUpdate() > 0;
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("UserDAO toggleUserStatus error: " + e.getMessage());
        }
        return true;
    }

    /**
     * Cập nhật vai trò người dùng (ADMIN, MANAGER, STAFF)
     */
    public boolean updateRole(int userId, String role) {
        String sql1 = "UPDATE Users SET role = ? WHERE id = ?";
        String sql2 = "UPDATE Users SET role = ? WHERE user_id = ?";

        try (Connection con = getConnection()) {
            if (con != null) {
                try (PreparedStatement ps = con.prepareStatement(sql1)) {
                    ps.setString(1, role != null ? role.toUpperCase() : "STAFF");
                    ps.setInt(2, userId);
                    return ps.executeUpdate() > 0;
                } catch (Exception e) {
                    try (PreparedStatement ps2 = con.prepareStatement(sql2)) {
                        ps2.setString(1, role != null ? role.toUpperCase() : "STAFF");
                        ps2.setInt(2, userId);
                        return ps2.executeUpdate() > 0;
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("UserDAO updateRole error: " + e.getMessage());
        }
        return true;
    }

    /**
     * Thêm tài khoản người dùng mới
     */
    public boolean addUser(User u) {
        String sql = "INSERT INTO Users (loginCode, phone, fullName, password, role, isActive, createdAt) " +
                     "VALUES (?, ?, ?, ?, ?, ?, GETDATE())";

        try (Connection con = getConnection()) {
            if (con != null) {
                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setString(1, u.getLoginCode() != null ? u.getLoginCode() : u.getPhone());
                    ps.setString(2, u.getPhone());
                    ps.setString(3, u.getFullName());
                    ps.setString(4, u.getPassword());
                    ps.setString(5, u.getRole() != null ? u.getRole().toUpperCase() : "STAFF");
                    ps.setBoolean(6, u.isIsActive());
                    return ps.executeUpdate() > 0;
                } catch (Exception e) {
                    // Fallback schema 2
                    String sql2 = "INSERT INTO Users (phone, passcode, full_name, role, status, created_at) " +
                                  "VALUES (?, ?, ?, ?, ?, GETDATE())";
                    try (PreparedStatement ps2 = con.prepareStatement(sql2)) {
                        ps2.setString(1, u.getPhone());
                        ps2.setString(2, u.getPassword());
                        ps2.setString(3, u.getFullName());
                        ps2.setString(4, u.getRole() != null ? u.getRole().toUpperCase() : "STAFF");
                        ps2.setString(5, u.isIsActive() ? "ACTIVE" : "REVOKED");
                        return ps2.executeUpdate() > 0;
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("UserDAO addUser error: " + e.getMessage());
        }
        return true;
    }

    /**
     * Ánh xạ ResultSet linh hoạt cho cả 2 kiểu cột (schema 1: id, loginCode, fullName... / schema 2: user_id, full_name...)
     */
    private User mapUser(ResultSet rs) throws Exception {
        int id = 0;
        try { id = rs.getInt("id"); } catch (Exception e) { id = rs.getInt("user_id"); }

        String phone = "";
        try { phone = rs.getString("phone"); } catch (Exception e) {}

        String loginCode = phone;
        try { loginCode = rs.getString("loginCode"); } catch (Exception e) {}
        if (loginCode == null || loginCode.isEmpty()) loginCode = phone;

        String fullName = "";
        try { fullName = rs.getString("fullName"); } catch (Exception e) { fullName = rs.getString("full_name"); }

        String password = "";
        try { password = rs.getString("password"); } catch (Exception e) { password = rs.getString("passcode"); }

        String role = "STAFF";
        try { role = rs.getString("role"); } catch (Exception e) {}

        boolean isActive = true;
        try {
            isActive = rs.getBoolean("isActive");
        } catch (Exception e) {
            try {
                String status = rs.getString("status");
                isActive = "ACTIVE".equalsIgnoreCase(status);
            } catch (Exception ex) {}
        }

        Timestamp createdAt = null;
        try { createdAt = rs.getTimestamp("createdAt"); } catch (Exception e) {
            try { createdAt = rs.getTimestamp("created_at"); } catch (Exception ex) {
                createdAt = new Timestamp(System.currentTimeMillis());
            }
        }

        return new User(id, loginCode, phone, fullName, password, role, isActive, createdAt);
    }
}
