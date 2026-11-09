package dal;

import model.Product;
import model.PurchaseOrder;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class ProductDAO extends DBContext {

    /**
     * Lấy toàn bộ danh sách sản phẩm trong kho hàng
     * @return List<Product> danh sách sản phẩm
     */
    public List<Product> getAllProducts() {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT id, sku, name, category, price, costPrice, stockQuantity, minStock, unit, spec, imageUrl, status " +
                     "FROM Products WHERE status = 'ACTIVE' ORDER BY id ASC";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapProduct(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lấy thông tin chi tiết một sản phẩm theo ID hoặc SKU
     * @param id Mã sản phẩm (ví dụ "CF01")
     * @return Product đối tượng sản phẩm hoặc null
     */
    public Product getProductById(String id) {
        String sql = "SELECT id, sku, name, category, price, costPrice, stockQuantity, minStock, unit, spec, imageUrl, status " +
                     "FROM Products WHERE id = ? OR sku = ?";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, id);
            ps.setString(2, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapProduct(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Lọc danh sách sản phẩm theo danh mục
     * @param cat Tên danh mục (ví dụ "coffee", "drinks", "food")
     * @return List<Product> danh sách sản phẩm thuộc danh mục
     */
    public List<Product> getProductsByCategory(String cat) {
        if (cat == null || cat.trim().isEmpty() || "all".equalsIgnoreCase(cat)) {
            return getAllProducts();
        }

        List<Product> list = new ArrayList<>();
        String sql = "SELECT id, sku, name, category, price, costPrice, stockQuantity, minStock, unit, spec, imageUrl, status " +
                     "FROM Products WHERE category = ? AND status = 'ACTIVE' ORDER BY id ASC";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, cat);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapProduct(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lấy danh sách sản phẩm có số lượng tồn kho chạm đáy (stockQuantity <= minStock)
     * @return List<Product> danh sách sản phẩm cần nhập thêm
     */
    public List<Product> getLowStockProducts() {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT id, sku, name, category, price, costPrice, stockQuantity, minStock, unit, spec, imageUrl, status " +
                     "FROM Products WHERE stockQuantity <= minStock AND status = 'ACTIVE' ORDER BY stockQuantity ASC";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapProduct(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Thêm sản phẩm mới vào danh mục
     * @param p Đối tượng sản phẩm
     * @return true nếu thêm thành công, false nếu thất bại
     */
    public boolean addProduct(Product p) {
        String sql = "INSERT INTO Products (id, sku, name, category, price, costPrice, stockQuantity, minStock, unit, spec, imageUrl, status) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, p.getId());
            ps.setString(2, p.getSku() != null ? p.getSku() : p.getId());
            ps.setString(3, p.getName());
            ps.setString(4, p.getCategory());
            ps.setDouble(5, p.getPrice());
            ps.setDouble(6, p.getCostPrice());
            ps.setInt(7, p.getStockQuantity());
            ps.setInt(8, p.getMinStock());
            ps.setString(9, p.getUnit());
            ps.setString(10, p.getSpec());
            ps.setString(11, p.getImageUrl());
            ps.setString(12, p.getStatus() != null ? p.getStatus() : "ACTIVE");

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Cập nhật thông tin hàng hóa
     * @param p Đối tượng sản phẩm có dữ liệu mới
     * @return true nếu cập nhật thành công, false nếu thất bại
     */
    public boolean updateProduct(Product p) {
        String sql = "UPDATE Products SET name = ?, category = ?, price = ?, costPrice = ?, " +
                     "stockQuantity = ?, minStock = ?, unit = ?, spec = ?, imageUrl = COALESCE(?, imageUrl) " +
                     "WHERE id = ? OR sku = ?";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, p.getName());
            ps.setString(2, p.getCategory());
            ps.setDouble(3, p.getPrice());
            ps.setDouble(4, p.getCostPrice());
            ps.setInt(5, p.getStockQuantity());
            ps.setInt(6, p.getMinStock());
            ps.setString(7, p.getUnit());
            ps.setString(8, p.getSpec());
            ps.setString(9, p.getImageUrl());
            ps.setString(10, p.getId());
            ps.setString(11, p.getId());

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Lấy danh sách các phiếu nhập hàng chờ quản lý duyệt
     * @return List<PurchaseOrder> danh sách phiếu nhập
     */
    public List<PurchaseOrder> getPendingPurchaseOrders() {
        List<PurchaseOrder> list = new ArrayList<>();
        String sql = "SELECT po.id, po.code, po.supplierName, po.productId, p.name AS productName, " +
                     "       po.totalQuantity, po.totalCost, po.status, po.rejectReason, po.createdBy, " +
                     "       u.fullName AS createdByName, p.stockQuantity AS stockBefore, " +
                     "       (p.stockQuantity + po.totalQuantity) AS stockAfter, po.createdAt " +
                     "FROM PurchaseOrders po " +
                     "JOIN Products p ON po.productId = p.id " +
                     "JOIN Users u ON po.createdBy = u.id " +
                     "WHERE po.status = 'PENDING' " +
                     "ORDER BY po.createdAt DESC";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapPurchaseOrder(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Duyệt hoặc từ chối phiếu nhập hàng.
     * Sử dụng Transaction: nếu duyệt (APPROVED) thì cộng ngay số lượng vào kho của sản phẩm tương ứng.
     * @param poId ID của phiếu nhập
     * @param status 'APPROVED' hoặc 'REJECTED'
     * @param note Ghi chú / Lý do từ chối
     * @return true nếu xử lý thành công
     */
    public boolean updatePurchaseOrderStatus(int poId, String status, String note) {
        String findPoSql = "SELECT productId, totalQuantity FROM PurchaseOrders WHERE id = ? AND status = 'PENDING'";
        String updatePoSql = "UPDATE PurchaseOrders SET status = ?, rejectReason = ? WHERE id = ?";
        String updateStockSql = "UPDATE Products SET stockQuantity = stockQuantity + ? WHERE id = ?";

        Connection con = null;
        try {
            con = getConnection();
            con.setAutoCommit(false); // Bắt đầu Transaction

            String prodId = null;
            int qty = 0;

            try (PreparedStatement psFind = con.prepareStatement(findPoSql)) {
                psFind.setInt(1, poId);
                try (ResultSet rs = psFind.executeQuery()) {
                    if (rs.next()) {
                        prodId = rs.getString("productId");
                        qty = rs.getInt("totalQuantity");
                    } else {
                        con.rollback();
                        return false;
                    }
                }
            }

            // Cập nhật trạng thái phiếu
            try (PreparedStatement psUpdatePo = con.prepareStatement(updatePoSql)) {
                psUpdatePo.setString(1, status.toUpperCase());
                psUpdatePo.setString(2, note);
                psUpdatePo.setInt(3, poId);
                psUpdatePo.executeUpdate();
            }

            // Nếu Duyệt -> cộng tồn kho
            if ("APPROVED".equalsIgnoreCase(status) && prodId != null && qty > 0) {
                try (PreparedStatement psStock = con.prepareStatement(updateStockSql)) {
                    psStock.setInt(1, qty);
                    psStock.setString(2, prodId);
                    psStock.executeUpdate();
                }
            }

            con.commit(); // Hoàn tất Transaction
            return true;
        } catch (Exception e) {
            if (con != null) {
                try { con.rollback(); } catch (Exception ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
        } finally {
            if (con != null) {
                try { con.setAutoCommit(true); con.close(); } catch (Exception e) { e.printStackTrace(); }
            }
        }
        return false;
    }

    /**
     * Tìm phiếu nhập theo mã phiếu (PN-026)
     */
    public PurchaseOrder getPurchaseOrderByCode(String code) {
        String sql = "SELECT po.id, po.code, po.supplierName, po.productId, p.name AS productName, " +
                     "       po.totalQuantity, po.totalCost, po.status, po.rejectReason, po.createdBy, " +
                     "       u.fullName AS createdByName, p.stockQuantity AS stockBefore, " +
                     "       (p.stockQuantity + po.totalQuantity) AS stockAfter, po.createdAt " +
                     "FROM PurchaseOrders po " +
                     "JOIN Products p ON po.productId = p.id " +
                     "JOIN Users u ON po.createdBy = u.id " +
                     "WHERE po.code = ?";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, code);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapPurchaseOrder(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    private Product mapProduct(ResultSet rs) throws Exception {
        String id = rs.getString("id");
        String sku = rs.getString("sku");
        String name = rs.getString("name");
        String category = rs.getString("category");
        double price = rs.getDouble("price");
        double costPrice = rs.getDouble("costPrice");
        int stockQuantity = rs.getInt("stockQuantity");
        int minStock = rs.getInt("minStock");
        String unit = rs.getString("unit");
        String spec = rs.getString("spec");
        String imageUrl = rs.getString("imageUrl");
        String status = rs.getString("status");

        return new Product(id, sku, name, category, price, costPrice, stockQuantity, minStock, unit, spec, imageUrl, status);
    }

    private PurchaseOrder mapPurchaseOrder(ResultSet rs) throws Exception {
        int id = rs.getInt("id");
        String code = rs.getString("code");
        String supplierName = rs.getString("supplierName");
        String productId = rs.getString("productId");
        String productName = rs.getString("productName");
        int totalQuantity = rs.getInt("totalQuantity");
        double totalCost = rs.getDouble("totalCost");
        String status = rs.getString("status");
        String rejectReason = rs.getString("rejectReason");
        int createdBy = rs.getInt("createdBy");
        String createdByName = rs.getString("createdByName");
        int stockBefore = rs.getInt("stockBefore");
        int stockAfter = rs.getInt("stockAfter");
        Timestamp createdAt = rs.getTimestamp("createdAt");

        return new PurchaseOrder(id, code, supplierName, productId, productName, totalQuantity, totalCost, status, rejectReason, createdBy, createdByName, stockBefore, stockAfter, createdAt);
    }
}

