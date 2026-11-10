package controller;

import dal.ActivityLogDAO;
import dal.ProductDAO;
import dal.StockTransactionDAO;
import dal.SupplierDAO;
import dal.SystemNotificationDAO;
import model.ActivityLog;
import model.Product;
import model.PurchaseOrder;
import model.Supplier;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "ProductServlet", urlPatterns = {"/products"})
public class ProductServlet extends HttpServlet {

    private final ProductDAO productDAO = new ProductDAO();
    private final ActivityLogDAO logDAO = new ActivityLogDAO();
    private final SupplierDAO supplierDAO = new SupplierDAO();
    private final StockTransactionDAO stockTransactionDAO = new StockTransactionDAO();
    private final SystemNotificationDAO notificationDAO = new SystemNotificationDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String category = request.getParameter("category");
        String activeTab = request.getParameter("tab");
        if (activeTab == null || activeTab.trim().isEmpty()) {
            activeTab = "products";
        }
        request.setAttribute("activeTab", activeTab);

        // 1. Tải danh sách hàng hóa
        List<Product> products = productDAO.getProductsByCategory(category);
        request.setAttribute("products", products);

        // 2. Tải danh sách sản phẩm chạm đáy
        List<Product> lowStockProducts = productDAO.getLowStockProducts();
        request.setAttribute("lowStockProducts", lowStockProducts);
        request.setAttribute("lowStockCount", lowStockProducts.size());

        // 3. Tải danh sách nhà cung cấp (Suppliers) cho dropdown
        List<Supplier> suppliers = supplierDAO.getAllSuppliers();
        request.setAttribute("suppliers", suppliers);

        // 4. Tải danh sách thông báo hệ thống cho người dùng hiện tại
        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("user") : null;
        Integer currentUserId = (currentUser != null) ? currentUser.getId() : null;
        boolean isStaff = currentUser != null && "STAFF".equalsIgnoreCase(currentUser.getRole());
        request.setAttribute("isStaff", isStaff);
        request.setAttribute("userRole", currentUser != null && currentUser.getRole() != null ? currentUser.getRole().toLowerCase() : "manager");
        request.setAttribute("notifications", notificationDAO.getNotificationsForUser(currentUserId, 5));
        request.setAttribute("unreadNotificationCount", notificationDAO.getUnreadCount(currentUserId));

        // 3. Tính toán tổng đơn vị tồn kho và giá trị vốn kho
        int totalUnits = 0;
        double totalInventoryCapital = 0;
        for (Product p : products) {
            totalUnits += p.getStockQuantity();
            totalInventoryCapital += (p.getStockQuantity() * p.getCostPrice());
        }
        request.setAttribute("totalProductsCount", products.size());
        request.setAttribute("totalUnits", totalUnits);
        request.setAttribute("totalInventoryCapital", totalInventoryCapital);

        // 4. Tải danh sách phiếu nhập kho chờ duyệt
        List<PurchaseOrder> pendingPOs = productDAO.getPendingPurchaseOrders();
        request.setAttribute("pendingPOs", pendingPOs);
        request.setAttribute("pendingPOCount", pendingPOs.size());

        int pendingQty = 0;
        double pendingCost = 0;
        for (PurchaseOrder po : pendingPOs) {
            pendingQty += po.getTotalQuantity();
            pendingCost += po.getTotalCost();
        }
        request.setAttribute("pendingQty", pendingQty);
        request.setAttribute("pendingCost", pendingCost);

        request.getRequestDispatcher("/views/products.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("user") : null;
        int userId = (currentUser != null) ? currentUser.getId() : 1;
        String userName = (currentUser != null) ? currentUser.getFullName() : "Quản lý";
        String userRole = (currentUser != null) ? currentUser.getRole() : "MANAGER";

        // Thu ngân chỉ có quyền xem hàng hóa, không được thêm/sửa
        if ("STAFF".equalsIgnoreCase(userRole)) {
            response.sendRedirect(request.getContextPath() + "/products?error=unauthorized");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            action = "save";
        }

        // 1. Xử lý Duyệt phiếu nhập hàng
        if ("approve_inflow".equalsIgnoreCase(action)) {
            String poIdStr = request.getParameter("poId");
            String poCode = request.getParameter("poCode");
            int poId = 0;

            if (poIdStr != null && !poIdStr.isEmpty()) {
                try { poId = Integer.parseInt(poIdStr); } catch (Exception ignored) {}
            } else if (poCode != null) {
                PurchaseOrder po = productDAO.getPurchaseOrderByCode(poCode);
                if (po != null) poId = po.getId();
            }

            if (poId > 0) {
                PurchaseOrder targetPo = productDAO.getPurchaseOrderByCode(poCode);
                productDAO.updatePurchaseOrderStatus(poId, "APPROVED", "Đã duyệt nhập kho");

                // Ghi nhận biến động thẻ kho StockTransactions khi duyệt phiếu nhập
                if (targetPo != null) {
                    int prodIntId = 0;
                    try { prodIntId = Integer.parseInt(targetPo.getProductId()); } catch (Exception ignored) {}
                    stockTransactionDAO.logTransaction(prodIntId, targetPo.getTotalQuantity(), 
                        targetPo.getStockBefore(), targetPo.getStockAfter(), "PURCHASE_IN", 
                        targetPo.getCode(), userId, "Duyệt nhập kho từ đối tác " + targetPo.getSupplierName());
                    
                    // Tạo thông báo thông minh cho người đề xuất và quản lý
                    notificationDAO.createNotification(targetPo.getCreatedBy(), "Phiếu nhập đã được duyệt", 
                        "Phiếu " + targetPo.getCode() + " (" + targetPo.getProductName() + " +" + targetPo.getTotalQuantity() + ") đã được Quản lý " + userName + " duyệt vào kho.", 
                        "PURCHASE_APPROVED", "products?tab=approvals");
                }

                logDAO.log(new ActivityLog(0, userId, userName, "Duyệt hàng về", 
                    "Duyệt nhập kho thành công cho phiếu " + (poCode != null ? poCode : ("ID " + poId)), 
                    request.getRemoteAddr(), userRole, poCode != null ? poCode : ("PN-" + poId), "Thành công", null));
            }

            response.sendRedirect(request.getContextPath() + "/products?tab=approvals");
            return;
        }

        // 2. Xử lý Từ chối phiếu nhập hàng
        if ("reject_inflow".equalsIgnoreCase(action)) {
            String poIdStr = request.getParameter("poId");
            String poCode = request.getParameter("poCode");
            String rejectReason = request.getParameter("rejectReason");
            int poId = 0;

            if (poIdStr != null && !poIdStr.isEmpty()) {
                try { poId = Integer.parseInt(poIdStr); } catch (Exception ignored) {}
            } else if (poCode != null) {
                PurchaseOrder po = productDAO.getPurchaseOrderByCode(poCode);
                if (po != null) poId = po.getId();
            }

            if (poId > 0) {
                PurchaseOrder targetPo = productDAO.getPurchaseOrderByCode(poCode);
                productDAO.updatePurchaseOrderStatus(poId, "REJECTED", rejectReason);

                // Tạo thông báo thông minh cho người tạo phiếu
                if (targetPo != null) {
                    notificationDAO.createNotification(targetPo.getCreatedBy(), "Phiếu nhập bị từ chối", 
                        "Phiếu " + targetPo.getCode() + " bị từ chối bởi " + userName + ". Lý do: " + rejectReason, 
                        "PURCHASE_REJECTED", "products?tab=approvals");
                }

                logDAO.log(new ActivityLog(0, userId, userName, "Từ chối hàng về", 
                    "Lý do: " + rejectReason, request.getRemoteAddr(), userRole, 
                    poCode != null ? poCode : ("PN-" + poId), "Đã từ chối", null));
            }

            response.sendRedirect(request.getContextPath() + "/products?tab=approvals");
            return;
        }

        // 3. Xử lý Xóa hàng hóa
        if ("delete".equalsIgnoreCase(action)) {
            String sku = request.getParameter("sku");
            if (sku != null && !sku.trim().isEmpty()) {
                Product p = productDAO.getProductById(sku);
                String pName = p != null ? p.getName() : sku;
                boolean deleted = productDAO.deleteProduct(sku);
                if (deleted) {
                    logDAO.log(new ActivityLog(0, userId, userName, "Xóa hàng hóa", 
                        "Xóa sản phẩm " + pName + " (" + sku + ") khỏi kho hàng", 
                        request.getRemoteAddr(), userRole, sku, "Thành công", null));
                } else {
                    logDAO.log(new ActivityLog(0, userId, userName, "Xóa hàng hóa", 
                        "Không thể xóa sản phẩm " + pName + " (" + sku + ") do ràng buộc hệ thống", 
                        request.getRemoteAddr(), userRole, sku, "Thất bại", null));
                }
            }
            response.sendRedirect(request.getContextPath() + "/products");
            return;
        }

        // 4. Xử lý Thêm / Sửa hàng hóa
        String sku = request.getParameter("sku");
        String name = request.getParameter("name");
        String cat = request.getParameter("category");
        String unit = request.getParameter("unit");
        String size = request.getParameter("size");
        String color = request.getParameter("color");
        String spec = request.getParameter("spec");
        String costPriceStr = request.getParameter("costPrice");
        String priceStr = request.getParameter("price");
        String stockStr = request.getParameter("stockQuantity");
        String minStockStr = request.getParameter("minStock");

        if (sku != null && name != null) {
            double costPrice = 0;
            double price = 0;
            int stock = 0;
            int minStock = 5;

            try { costPrice = Double.parseDouble(costPriceStr); } catch (Exception ignored) {}
            try { price = Double.parseDouble(priceStr); } catch (Exception ignored) {}
            try { stock = Integer.parseInt(stockStr); } catch (Exception ignored) {}
            try { if (minStockStr != null && !minStockStr.trim().isEmpty()) minStock = Integer.parseInt(minStockStr); } catch (Exception ignored) {}

            if (spec == null || spec.trim().isEmpty()) {
                String s = "";
                if (size != null && !size.trim().isEmpty()) s += "Size " + size.trim();
                if (color != null && !color.trim().isEmpty()) s += (s.isEmpty() ? "" : " · ") + color.trim();
                spec = s.isEmpty() ? unit : s;
            }

            String imageUrl = request.getParameter("imageUrl");
            if (imageUrl == null || imageUrl.trim().isEmpty()) {
                imageUrl = sku + ".svg";
            }

            Product existing = productDAO.getProductById(sku);
            Product p = new Product(sku, sku, name, cat, price, costPrice, stock, minStock, unit, spec, size, color, imageUrl, "ACTIVE");

            String supplierIdStr = request.getParameter("supplierId");
            String supplierName = request.getParameter("supplierName");
            Integer supplierId = null;
            try {
                if (supplierIdStr != null && !supplierIdStr.trim().isEmpty()) {
                    supplierId = Integer.parseInt(supplierIdStr);
                }
            } catch (Exception ignored) {}
            if (supplierId == null && supplierName != null && !supplierName.trim().isEmpty()) {
                for (Supplier sup : supplierDAO.getAllSuppliers()) {
                    if (supplierName.trim().equalsIgnoreCase(sup.getSupplierName().trim())) {
                        supplierId = sup.getSupplierId();
                        break;
                    }
                }
            }
            p.setSupplierId(supplierId);

            if (existing != null) {
                p.setId(existing.getId());
                productDAO.updateProduct(p);
                logDAO.log(new ActivityLog(0, userId, userName, "Cập nhật hàng hóa", 
                    "Cập nhật thông tin cho sản phẩm " + name + " (" + sku + ")", 
                    request.getRemoteAddr(), userRole, sku, "Thành công", null));
            } else {
                productDAO.addProduct(p);
                logDAO.log(new ActivityLog(0, userId, userName, "Thêm hàng hóa mới", 
                    "Thêm mới sản phẩm " + name + " (" + sku + ") vào kho", 
                    request.getRemoteAddr(), userRole, sku, "Thành công", null));
            }
        }

        response.sendRedirect(request.getContextPath() + "/products");
    }
}

