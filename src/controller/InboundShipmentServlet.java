package controller;

import dal.ActivityLogDAO;
import dal.ProductDAO;
import dal.StockTransactionDAO;
import dal.SystemNotificationDAO;
import model.ActivityLog;
import model.Product;
import model.PurchaseOrder;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "InboundShipmentServlet", urlPatterns = {"/inbound-shipments"})
public class InboundShipmentServlet extends HttpServlet {

    private final ProductDAO productDAO = new ProductDAO();
    private final ActivityLogDAO logDAO = new ActivityLogDAO();
    private final StockTransactionDAO stockTransactionDAO = new StockTransactionDAO();
    private final SystemNotificationDAO notificationDAO = new SystemNotificationDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("user") : null;
        Integer currentUserId = (currentUser != null) ? currentUser.getId() : null;

        // 1. Tải danh sách phiếu nhập kho chờ duyệt
        List<PurchaseOrder> pendingPOs = productDAO.getPendingPurchaseOrders();
        request.setAttribute("pendingPOs", pendingPOs);
        request.setAttribute("pendingPOCount", pendingPOs.size());

        int pendingQty = 0;
        double pendingCost = 0;
        for (PurchaseOrder po : pendingPOs) {
            pendingQty += po.getTotalQuantity();
            pendingCost += po.getTotalCost();
        }
        request.setAttribute("pendingUnits", pendingQty);
        request.setAttribute("pendingTotalCost", pendingCost);

        // 2. Tải danh sách cảnh báo chạm đáy & thông báo
        List<Product> lowStockProducts = productDAO.getLowStockProducts();
        request.setAttribute("lowStockProducts", lowStockProducts);
        request.setAttribute("lowStockCount", lowStockProducts.size());
        request.setAttribute("notifications", notificationDAO.getNotificationsForUser(currentUserId, 5));
        request.setAttribute("unreadNotificationCount", notificationDAO.getUnreadCount(currentUserId));

        request.getRequestDispatcher("/views/inbound_shipments.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("user") : null;
        int userId = (currentUser != null) ? currentUser.getId() : 2;
        String userName = (currentUser != null) ? currentUser.getFullName() : "Nguyễn Minh Hà";
        String userRole = (currentUser != null && currentUser.getRole() != null) ? currentUser.getRole() : "MANAGER";

        String action = request.getParameter("action");

        // 1. Duyệt phiếu nhập hàng
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

                if (targetPo != null) {
                    int prodIntId = 0;
                    try { prodIntId = Integer.parseInt(targetPo.getProductId()); } catch (Exception ignored) {}
                    stockTransactionDAO.logTransaction(prodIntId, targetPo.getTotalQuantity(), 
                        targetPo.getStockBefore(), targetPo.getStockAfter(), "PURCHASE_IN", 
                        targetPo.getCode(), userId, "Duyệt nhập kho từ đối tác " + targetPo.getSupplierName());
                    
                    notificationDAO.createNotification(targetPo.getCreatedBy(), "Phiếu nhập đã được duyệt", 
                        "Phiếu " + targetPo.getCode() + " (" + targetPo.getProductName() + " +" + targetPo.getTotalQuantity() + ") đã được Quản lý " + userName + " duyệt vào kho.", 
                        "PURCHASE_APPROVED", "inbound-shipments");
                }

                logDAO.log(new ActivityLog(0, userId, userName, "Duyệt hàng về", 
                    "Duyệt nhập kho thành công cho phiếu " + (poCode != null ? poCode : ("ID " + poId)), 
                    request.getRemoteAddr(), userRole, poCode != null ? poCode : ("PN-" + poId), "Thành công", null));
            }

            response.sendRedirect(request.getContextPath() + "/inbound-shipments");
            return;
        }

        // 2. Từ chối phiếu nhập hàng
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

                if (targetPo != null) {
                    notificationDAO.createNotification(targetPo.getCreatedBy(), "Phiếu nhập bị từ chối", 
                        "Phiếu " + targetPo.getCode() + " bị từ chối bởi " + userName + ". Lý do: " + rejectReason, 
                        "PURCHASE_REJECTED", "inbound-shipments");
                }

                logDAO.log(new ActivityLog(0, userId, userName, "Từ chối hàng về", 
                    "Lý do: " + rejectReason, request.getRemoteAddr(), userRole, 
                    poCode != null ? poCode : ("PN-" + poId), "Đã từ chối", null));
            }

            response.sendRedirect(request.getContextPath() + "/inbound-shipments");
            return;
        }

        response.sendRedirect(request.getContextPath() + "/inbound-shipments");
    }
}
