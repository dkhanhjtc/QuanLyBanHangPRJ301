package dal;

import model.SystemNotification;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class SystemNotificationDAO extends DBContext {

    public List<SystemNotification> getNotificationsForUser(Integer userId, int limit) {
        List<SystemNotification> list = new ArrayList<>();
        String sql = "SELECT TOP (?) notification_id, user_id, title, message, type, reference_url, is_read, created_at "
                +
                "FROM SystemNotifications " +
                "WHERE (user_id IS NULL OR user_id = ?) " +
                "ORDER BY created_at DESC";

        try (Connection con = getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, limit);
            ps.setObject(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapNotification(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public int getUnreadCount(Integer userId) {
        String sql = "SELECT COUNT(*) FROM SystemNotifications WHERE (user_id IS NULL OR user_id = ?) AND is_read = 0";
        try (Connection con = getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setObject(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public boolean createNotification(Integer userId, String title, String message, String type, String refUrl) {
        String sql = "INSERT INTO SystemNotifications (user_id, title, message, type, reference_url, is_read, created_at) "
                +
                "VALUES (?, ?, ?, ?, ?, 0, GETDATE())";

        try (Connection con = getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setObject(1, userId);
            ps.setString(2, title);
            ps.setString(3, message);
            ps.setString(4, type);
            ps.setString(5, refUrl);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean markAsRead(long notificationId) {
        String sql = "UPDATE SystemNotifications SET is_read = 1 WHERE notification_id = ?";
        try (Connection con = getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setLong(1, notificationId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    private SystemNotification mapNotification(ResultSet rs) throws Exception {
        long id = rs.getLong("notification_id");
        Integer uId = (Integer) rs.getObject("user_id");
        String title = rs.getString("title");
        String msg = rs.getString("message");
        String type = rs.getString("type");
        String url = rs.getString("reference_url");
        boolean read = rs.getBoolean("is_read");
        Timestamp createdAt = rs.getTimestamp("created_at");

        return new SystemNotification(id, uId, title, msg, type, url, read, createdAt);
    }
}
