package dal;

import model.WorkShift;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class WorkShiftDAO extends DBContext {

    public WorkShift getCurrentShiftByStaff(int staffId) {
        String sql = "SELECT ws.shift_id, ws.shift_code, ws.staff_id, u.full_name AS staffName, " +
                     "       ws.start_time, ws.end_time, ws.opening_cash, ws.closing_cash, ws.total_sales, ws.status, ws.note " +
                     "FROM WorkShifts ws " +
                     "JOIN Users u ON ws.staff_id = u.user_id " +
                     "WHERE ws.staff_id = ? AND ws.status = 'OPEN' " +
                     "ORDER BY ws.start_time DESC";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, staffId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapWorkShift(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public WorkShift getActiveShift() {
        String sql = "SELECT TOP 1 ws.shift_id, ws.shift_code, ws.staff_id, u.full_name AS staffName, " +
                     "       ws.start_time, ws.end_time, ws.opening_cash, ws.closing_cash, ws.total_sales, ws.status, ws.note " +
                     "FROM WorkShifts ws " +
                     "JOIN Users u ON ws.staff_id = u.user_id " +
                     "WHERE ws.status = 'OPEN' " +
                     "ORDER BY ws.start_time DESC";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                return mapWorkShift(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean openShift(int staffId, double openingCash, String note) {
        String code = "CA-" + System.currentTimeMillis();
        String sql = "INSERT INTO WorkShifts (shift_code, staff_id, start_time, opening_cash, total_sales, status, note) " +
                     "VALUES (?, ?, GETDATE(), ?, 0, 'OPEN', ?)";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, code);
            ps.setInt(2, staffId);
            ps.setDouble(3, openingCash);
            ps.setString(4, note);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean closeShift(int shiftId, double closingCash, String note) {
        String sql = "UPDATE WorkShifts SET end_time = GETDATE(), closing_cash = ?, status = 'CLOSED', note = ? " +
                     "WHERE shift_id = ? AND status = 'OPEN'";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setDouble(1, closingCash);
            ps.setString(2, note);
            ps.setInt(3, shiftId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public void addSalesToShift(int shiftId, double amount) {
        String sql = "UPDATE WorkShifts SET total_sales = total_sales + ? WHERE shift_id = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setDouble(1, amount);
            ps.setInt(2, shiftId);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private WorkShift mapWorkShift(ResultSet rs) throws Exception {
        int id = rs.getInt("shift_id");
        String code = rs.getString("shift_code");
        int staffId = rs.getInt("staff_id");
        String staffName = rs.getString("staffName");
        Timestamp startTime = rs.getTimestamp("start_time");
        Timestamp endTime = rs.getTimestamp("end_time");
        double openingCash = rs.getDouble("opening_cash");
        double closingCash = rs.getDouble("closing_cash");
        double totalSales = rs.getDouble("total_sales");
        String status = rs.getString("status");
        String note = rs.getString("note");

        return new WorkShift(id, code, staffId, staffName, startTime, endTime, openingCash, closingCash, totalSales, status, note);
    }
}

