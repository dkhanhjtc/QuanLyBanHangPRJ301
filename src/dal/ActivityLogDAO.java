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
     * @param userId ID người dùng thực hiện (có thể là 0 nếu chưa đăng nhập)
     * @param action Tên hành động thực hiện
     * @param details Chi tiết nội dung thao tác
     * @param ipAddress Địa chỉ IP của client
     * @return true nếu ghi log thành công
     */
    public boolean log(int userId, String action, String details, String ipAddress) {
        String findUserSql = "SELECT fullName, role FROM Users WHERE id = ?";
        String insertSql = "INSERT INTO ActivityLogs (userId, userName, action, details, ipAddress, role, recordCode, result, createdAt) " +
                           "VALUES (?, ?, ?, ?, ?, ?, ?, ?, GETDATE())";

        String userName = "Hệ thống";
        String role = "SYSTEM";

        try (Connection con = getConnection()) {
            if (userId > 0) {
                try (PreparedStatement psUser = con.prepareStatement(findUserSql)) {
                    psUser.setInt(1, userId);
                    try (ResultSet rs = psUser.executeQuery()) {
                        if (rs.next()) {
                            userName = rs.getString("fullName");
                            role = rs.getString("role");
                        }
                    }
                }
            }

            try (PreparedStatement ps = con.prepareStatement(insertSql)) {
                ps.setInt(1, userId > 0 ? userId : 0);
                ps.setString(2, userName);
                ps.setString(3, action);
                ps.setString(4, details);
                ps.setString(5, ipAddress);
                ps.setString(6, role);
                ps.setString(7, "-");
                ps.setString(8, "Thành công");

                return ps.executeUpdate() > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Ghi nhật ký đầy đủ thuộc tính
     * @param log Đối tượng ActivityLog
     * @return true nếu ghi log thành công
     */
    public boolean log(ActivityLog log) {
        String sql = "INSERT INTO ActivityLogs (userId, userName, action, details, ipAddress, role, recordCode, result, createdAt) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, GETDATE())";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, log.getUserId());
            ps.setString(2, log.getUserName() != null ? log.getUserName() : "Hệ thống");
            ps.setString(3, log.getAction());
            ps.setString(4, log.getDetails());
            ps.setString(5, log.getIpAddress());
            ps.setString(6, log.getRole());
            ps.setString(7, log.getRecordCode());
            ps.setString(8, log.getResult() != null ? log.getResult() : "Thành công");

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Lấy danh sách nhật ký gần đây
     * @param limit Số lượng bản ghi tối đa
     * @return List<ActivityLog> danh sách nhật ký
     */
    public List<ActivityLog> getRecentLogs(int limit) {
        List<ActivityLog> list = new ArrayList<>();
        String sql = "SELECT TOP (?) id, userId, userName, action, details, ipAddress, role, recordCode, result, createdAt " +
                     "FROM ActivityLogs ORDER BY createdAt DESC";

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
     * @return List<ActivityLog> danh sách toàn bộ log
     */
    public List<ActivityLog> getAllLogs() {
        List<ActivityLog> list = new ArrayList<>();
        String sql = "SELECT id, userId, userName, action, details, ipAddress, role, recordCode, result, createdAt " +
                     "FROM ActivityLogs ORDER BY createdAt DESC";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapLog(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    private ActivityLog mapLog(ResultSet rs) throws Exception {
        int id = rs.getInt("id");
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

