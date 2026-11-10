package dal;

import model.Supplier;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class SupplierDAO extends DBContext {

    public List<Supplier> getAllSuppliers() {
        List<Supplier> list = new ArrayList<>();
        String sql = "SELECT supplier_id, supplier_code, supplier_name, contact_phone, address, status, created_at " +
                "FROM Suppliers ORDER BY supplier_id ASC";

        try (Connection con = getConnection();
                PreparedStatement ps = con.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapSupplier(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public Supplier getSupplierById(int id) {
        String sql = "SELECT supplier_id, supplier_code, supplier_name, contact_phone, address, status, created_at " +
                "FROM Suppliers WHERE supplier_id = ?";

        try (Connection con = getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapSupplier(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean insertSupplier(Supplier s) {
        String sql = "INSERT INTO Suppliers (supplier_code, supplier_name, contact_phone, address, status, created_at) " +
                     "VALUES (?, ?, ?, ?, ?, GETDATE())";

        try (Connection con = getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            String code = s.getSupplierCode();
            if (code == null || code.trim().isEmpty()) {
                code = "NCC-" + (System.currentTimeMillis() % 10000);
            }

            ps.setString(1, code);
            ps.setString(2, s.getSupplierName());
            ps.setString(3, s.getContactPhone() != null ? s.getContactPhone() : "");
            ps.setString(4, s.getAddress() != null ? s.getAddress() : "");
            ps.setString(5, s.getStatus() != null ? s.getStatus() : "ACTIVE");
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateSupplier(Supplier s) {
        String sql = "UPDATE Suppliers SET supplier_name = ?, contact_phone = ?, address = ?, status = ? " +
                     "WHERE supplier_id = ?";

        try (Connection con = getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, s.getSupplierName());
            ps.setString(2, s.getContactPhone());
            ps.setString(3, s.getAddress());
            ps.setString(4, s.getStatus() != null ? s.getStatus() : "ACTIVE");
            ps.setInt(5, s.getSupplierId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deleteSupplier(int id) {
        // Xóa an toàn: Cố gắng xóa cứng, nếu vướng khóa ngoại đơn hàng thì chuyển sang status='INACTIVE'
        String deleteSql = "DELETE FROM Suppliers WHERE supplier_id = ?";
        String deactivateSql = "UPDATE Suppliers SET status = 'INACTIVE' WHERE supplier_id = ?";

        try (Connection con = getConnection()) {
            try (PreparedStatement ps = con.prepareStatement(deleteSql)) {
                ps.setInt(1, id);
                if (ps.executeUpdate() > 0) return true;
            } catch (Exception fkEx) {
                // Vướng khóa ngoại -> Soft delete
                try (PreparedStatement ps2 = con.prepareStatement(deactivateSql)) {
                    ps2.setInt(1, id);
                    return ps2.executeUpdate() > 0;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    private Supplier mapSupplier(ResultSet rs) throws Exception {
        int id = rs.getInt("supplier_id");
        String code = rs.getString("supplier_code");
        String name = rs.getString("supplier_name");
        String phone = rs.getString("contact_phone");
        String address = rs.getString("address");
        String status = rs.getString("status");
        Timestamp createdAt = rs.getTimestamp("created_at");

        return new Supplier(id, code, name, phone, address, status, createdAt);
    }
}
