package controller;

import dal.OrderDAO;
import dal.ProductDAO;
import dal.SystemNotificationDAO;
import model.Order;
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
import java.util.Map;

@WebServlet(name = "DashboardServlet", urlPatterns = {"/dashboard"})
public class DashboardServlet extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDAO();
    private final ProductDAO productDAO = new ProductDAO();
    private final SystemNotificationDAO notificationDAO = new SystemNotificationDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Tải chỉ số tổng quan tài chính & kho (KPI Summary)
        Map<String, Object> summary = orderDAO.getRevenueSummary();
        request.setAttribute("kpiSummary", summary);

        // 2. Tải danh sách các sản phẩm chạm đáy cần bổ sung
        List<Product> lowStockProducts = productDAO.getLowStockProducts();
        request.setAttribute("lowStockProducts", lowStockProducts);

        // 3. Tải danh sách đơn hàng gần đây
        List<Order> recentOrders = orderDAO.getRecentOrders(6);
        request.setAttribute("orders", recentOrders);

        // 4. Tải số lượng phiếu hàng chờ duyệt
        List<PurchaseOrder> pendingPOs = productDAO.getPendingPurchaseOrders();
        request.setAttribute("pendingPOCount", pendingPOs.size());

        // 5. Tải thông báo thông minh cho người dùng
        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("user") : null;
        Integer currentUserId = (currentUser != null) ? currentUser.getId() : null;
        request.setAttribute("notifications", notificationDAO.getNotificationsForUser(currentUserId, 5));
        request.setAttribute("unreadNotificationCount", notificationDAO.getUnreadCount(currentUserId));

        // 6. Chuyển tiếp tới View
        request.getRequestDispatcher("/views/dashboard.jsp").forward(request, response);
    }
}

