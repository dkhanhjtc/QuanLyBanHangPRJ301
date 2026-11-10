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

    private static final String SELECT_BASE = 
        "SELECT p.product_id AS id, p.product_code AS sku, p.product_name AS name, " +
        "       ISNULL(c.category_name, N'Thời trang') AS category, p.retail_price AS price, " +
        "       p.cost_price AS costPrice, p.stock_qty AS stockQuantity, p.min_stock_alert AS minStock, " +
        "       p.unit, (ISNULL(p.size, 'M') + ' - ' + ISNULL(p.color, N'Tiêu chuẩn')) AS spec, " +
        "       p.size, p.color, " +
        "       p.image_url AS imageUrl, p.status " +
        "FROM Products p " +
        "LEFT JOIN Categories c ON p.category_id = c.category_id ";

    /**
     * Lấy toàn bộ danh sách sản phẩm trong kho hàng
     * @return List<Product> danh sách sản phẩm
     */
    public List<Product> getAllProducts() {
        List<Product> list = new ArrayList<>();
        String sql = SELECT_BASE + "WHERE p.status = 'ACTIVE' ORDER BY p.product_id ASC";

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
     * @param id Mã sản phẩm (ví dụ "SM01" hoặc "1")
     * @return Product đối tượng sản phẩm hoặc null
     */
    public Product getProductById(String id) {
        String sql = SELECT_BASE + "WHERE p.product_code = ? OR CAST(p.product_id AS VARCHAR(50)) = ?";

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
     * @param cat Tên danh mục (ví dụ "Áo sơ mi", "Áo thun", "all")
     * @return List<Product> danh sách sản phẩm thuộc danh mục
     */
    public List<Product> getProductsByCategory(String cat) {
        if (cat == null || cat.trim().isEmpty() || "all".equalsIgnoreCase(cat)) {
            return getAllProducts();
        }

        List<Product> list = new ArrayList<>();
        String sql = SELECT_BASE + "WHERE (c.category_name = ? OR c.category_name LIKE ?) AND p.status = 'ACTIVE' ORDER BY p.product_id ASC";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, cat);
            ps.setString(2, "%" + cat + "%");
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
     * Lấy danh sách sản phẩm có số lượng tồn kho chạm đáy (stock_qty <= min_stock_alert)
     * @return List<Product> danh sách sản phẩm cần nhập thêm
     */
    public List<Product> getLowStockProducts() {
        List<Product> list = new ArrayList<>();
        String sql = SELECT_BASE + "WHERE p.stock_qty <= p.min_stock_alert AND p.status = 'ACTIVE' ORDER BY p.stock_qty ASC";

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
        String sql = "INSERT INTO Products (product_code, product_name, category_id, retail_price, cost_price, stock_qty, min_stock_alert, unit, size, color, image_url, status) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'ACTIVE')";

        int catId = 1;
        if (p.getCategory() != null) {
            String c = p.getCategory().toLowerCase();
            if (c.contains("thun") || c.contains("polo")) catId = 2;
            else if (c.contains("quần") || c.contains("jean") || c.contains("tây")) catId = 3;
            else if (c.contains("váy") || c.contains("đầm")) catId = 4;
            else if (c.contains("khoác")) catId = 5;
            else if (c.contains("sơ mi")) catId = 1;
        }

        String size = p.getSize() != null && !p.getSize().trim().isEmpty() ? p.getSize() : "M";
        String color = p.getColor() != null && !p.getColor().trim().isEmpty() ? p.getColor() : "Tiêu chuẩn";
        String img = (p.getImageUrl() != null && !p.getImageUrl().trim().isEmpty()) ? p.getImageUrl() : "CC01.svg";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, p.getSku() != null ? p.getSku() : ("SP" + System.currentTimeMillis() % 1000));
            ps.setString(2, p.getName());
            ps.setInt(3, catId);
            ps.setDouble(4, p.getPrice());
            ps.setDouble(5, p.getCostPrice());
            ps.setInt(6, p.getStockQuantity());
            ps.setInt(7, p.getMinStock());
            ps.setString(8, p.getUnit() != null ? p.getUnit() : "Cái");
            ps.setString(9, size);
            ps.setString(10, color);
            ps.setString(11, img);

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
        String sql = "UPDATE Products SET product_name = ?, category_id = ?, size = ?, color = ?, " +
                     "retail_price = ?, cost_price = ?, stock_qty = ?, min_stock_alert = ?, unit = ?, " +
                     "image_url = CASE WHEN ? IS NOT NULL AND ? <> '' THEN ? ELSE image_url END " +
                     "WHERE product_code = ? OR CAST(product_id AS VARCHAR(50)) = ?";

        int catId = 1;
        if (p.getCategory() != null) {
            String c = p.getCategory().toLowerCase();
            if (c.contains("thun") || c.contains("polo")) catId = 2;
            else if (c.contains("quần") || c.contains("jean") || c.contains("tây")) catId = 3;
            else if (c.contains("váy") || c.contains("đầm")) catId = 4;
            else if (c.contains("khoác")) catId = 5;
            else if (c.contains("sơ mi")) catId = 1;
        }

        String size = p.getSize() != null && !p.getSize().trim().isEmpty() ? p.getSize() : "M";
        String color = p.getColor() != null && !p.getColor().trim().isEmpty() ? p.getColor() : "Tiêu chuẩn";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, p.getName());
            ps.setInt(2, catId);
            ps.setString(3, size);
            ps.setString(4, color);
            ps.setDouble(5, p.getPrice());
            ps.setDouble(6, p.getCostPrice());
            ps.setInt(7, p.getStockQuantity());
            ps.setInt(8, p.getMinStock());
            ps.setString(9, p.getUnit() != null ? p.getUnit() : "Cái");
            ps.setString(10, p.getImageUrl());
            ps.setString(11, p.getImageUrl());
            ps.setString(12, p.getImageUrl());
            ps.setString(13, p.getSku() != null ? p.getSku() : p.getId());
            ps.setString(14, p.getId() != null ? p.getId() : p.getSku());

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Tạo phiếu nhập hàng mới từ nhà cung cấp / xưởng may (trạng thái PENDING chờ quản lý duyệt)
     */
    public boolean createPurchaseOrder(String code, String supplierName, String productId, int quantity, double costPrice, int createdBy) {
        String sql = "INSERT INTO PurchaseOrders (code, supplierName, productId, totalQuantity, totalCost, status, createdBy, createdAt) " +
                     "VALUES (?, ?, ?, ?, ?, 'PENDING', ?, GETDATE())";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, code);
            ps.setString(2, supplierName);
            ps.setString(3, productId);
            ps.setInt(4, quantity);
            ps.setDouble(5, costPrice * quantity);
            ps.setInt(6, createdBy > 0 ? createdBy : 2);

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
        String sql = "SELECT po.id, po.code, po.supplierName, po.productId, p.product_name AS productName, " +
                     "       po.totalQuantity, po.totalCost, po.status, po.rejectReason, po.createdBy, " +
                     "       u.full_name AS createdByName, p.stock_qty AS stockBefore, " +
                     "       (p.stock_qty + po.totalQuantity) AS stockAfter, po.createdAt " +
                     "FROM PurchaseOrders po " +
                     "JOIN Products p ON (po.productId = p.product_code OR CAST(p.product_id AS VARCHAR(50)) = po.productId) " +
                     "JOIN Users u ON po.createdBy = u.user_id " +
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
        String updateStockSql = "UPDATE Products SET stock_qty = stock_qty + ? WHERE product_code = ? OR CAST(product_id AS VARCHAR(50)) = ?";

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
                    psStock.setString(3, prodId);
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
        String sql = "SELECT po.id, po.code, po.supplierName, po.productId, p.product_name AS productName, " +
                     "       po.totalQuantity, po.totalCost, po.status, po.rejectReason, po.createdBy, " +
                     "       u.full_name AS createdByName, p.stock_qty AS stockBefore, " +
                     "       (p.stock_qty + po.totalQuantity) AS stockAfter, po.createdAt " +
                     "FROM PurchaseOrders po " +
                     "JOIN Products p ON (po.productId = p.product_code OR CAST(p.product_id AS VARCHAR(50)) = po.productId) " +
                     "JOIN Users u ON po.createdBy = u.user_id " +
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
        String id = String.valueOf(rs.getInt("id"));
        String sku = rs.getString("sku");
        String name = rs.getString("name");
        String category = rs.getString("category");
        double price = rs.getDouble("price");
        double costPrice = rs.getDouble("costPrice");
        int stockQuantity = rs.getInt("stockQuantity");
        int minStock = rs.getInt("minStock");
        String unit = rs.getString("unit");
        String spec = rs.getString("spec");
        String size = rs.getString("size");
        String color = rs.getString("color");
        String imageUrl = rs.getString("imageUrl");
        String status = rs.getString("status");

        return new Product(id, sku, name, category, price, costPrice, stockQuantity, minStock, unit, spec, size, color, imageUrl, status);
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
