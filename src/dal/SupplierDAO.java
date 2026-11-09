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
                "FROM Suppliers WHERE status = 'ACTIVE' ORDER BY supplier_name ASC";

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
        String sql = "INSERT INTO Suppliers (supplier_code, supplier_name, contact_phone, address, status, created_at) "
                +
                "VALUES (?, ?, ?, ?, ?, GETDATE())";

        try (Connection con = getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, s.getSupplierCode());
            ps.setString(2, s.getSupplierName());
            ps.setString(3, s.getContactPhone());
            ps.setString(4, s.getAddress());
            ps.setString(5, s.getStatus() != null ? s.getStatus() : "ACTIVE");
            return ps.executeUpdate() > 0;
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
