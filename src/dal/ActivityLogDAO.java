package dal;

import model.ActivityLog;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class ActivityLogDAO extends DBContext {

    /**
     * Ghi lại nhật ký hoạt động hệ thống
     */
    public boolean log(int userId, String action, String details, String ipAddress) {
        return log(new ActivityLog(0, userId, null, action, details, ipAddress, null, "-", "Thành công", null));
    }

    /**
     * Ghi nhật ký đầy đủ thuộc tính vào bảng ActivityLogs (khớp chuẩn schema CSDL)
     */
    public boolean log(ActivityLog log) {
        String sql = "INSERT INTO ActivityLogs (user_id, action_type, record_target, description, created_at) " +
                     "VALUES (?, ?, ?, ?, GETDATE())";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            int uid = log.getUserId();
            if (uid <= 0) uid = 2; // Mặc định Quản lý nếu chưa gán

            ps.setInt(1, uid);
            ps.setString(2, log.getAction() != null ? log.getAction() : "HOAT_DONG");
            ps.setString(3, log.getRecordCode() != null && !log.getRecordCode().trim().isEmpty() ? log.getRecordCode() : "-");
            
            String desc = log.getDetails();
            if (desc == null || desc.trim().isEmpty()) {
                desc = log.getAction();
            }
            if (desc.length() > 250) {
                desc = desc.substring(0, 250);
            }
            ps.setString(4, desc);

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Lấy danh sách nhật ký gần đây
     */
    public List<ActivityLog> getRecentLogs(int limit) {
        List<ActivityLog> list = new ArrayList<>();
        String sql = "SELECT TOP (?) l.log_id AS id, " +
                     "       l.user_id AS userId, " +
                     "       ISNULL(u.full_name, N'Quản trị viên') AS userName, " +
                     "       l.action_type AS action, " +
                     "       l.description AS details, " +
                     "       N'127.0.0.1' AS ipAddress, " +
                     "       ISNULL(u.role, 'ADMIN') AS role, " +
                     "       ISNULL(l.record_target, '-') AS recordCode, " +
                     "       N'Thành công' AS result, " +
                     "       l.created_at AS createdAt " +
                     "FROM ActivityLogs l " +
                     "LEFT JOIN Users u ON l.user_id = u.user_id " +
                     "ORDER BY l.created_at DESC";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapLog(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lấy toàn bộ danh sách nhật ký hoạt động
     */
    public List<ActivityLog> getAllLogs() {
        return getRecentLogs(200);
    }

    private ActivityLog mapLog(ResultSet rs) throws Exception {
        int id = (int) rs.getLong("id");
        int userId = rs.getInt("userId");
        String userName = rs.getString("userName");
        String action = rs.getString("action");
        String details = rs.getString("details");
        String ipAddress = rs.getString("ipAddress");
        String role = rs.getString("role");
        String recordCode = rs.getString("recordCode");
        String result = rs.getString("result");
        Timestamp createdAt = rs.getTimestamp("createdAt");

        return new ActivityLog(id, userId, userName, action, details, ipAddress, role, recordCode, result, createdAt);
    }
}
