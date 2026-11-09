package controller;

import dal.ActivityLogDAO;
import dal.OrderDAO;
import dal.ProductDAO;
import dal.StockTransactionDAO;
import dal.SystemNotificationDAO;
import dal.WorkShiftDAO;
import model.ActivityLog;
import model.Order;
import model.OrderDetail;
import model.Product;
import model.User;
import model.WorkShift;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "PosServlet", urlPatterns = {"/pos"})
public class PosServlet extends HttpServlet {

    private final ProductDAO productDAO = new ProductDAO();
    private final OrderDAO orderDAO = new OrderDAO();
    private final ActivityLogDAO logDAO = new ActivityLogDAO();
    private final WorkShiftDAO workShiftDAO = new WorkShiftDAO();
    private final SystemNotificationDAO notificationDAO = new SystemNotificationDAO();
    private final StockTransactionDAO transDAO = new StockTransactionDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("user") : null;
        int userId = (currentUser != null) ? currentUser.getId() : 3;
        String userName = (currentUser != null) ? currentUser.getFullName() : "Lê Lan Anh";

        // 1. Kiểm tra ca làm việc hiện tại của nhân viên
        WorkShift currentShift = workShiftDAO.getCurrentShiftByStaff(userId, userName);
        request.setAttribute("currentShift", currentShift);
        request.setAttribute("hasActiveShift", currentShift != null);

        // 2. Lấy danh mục được chọn (nếu có)
        String category = request.getParameter("category");
        List<Product> products = productDAO.getProductsByCategory(category);
        request.setAttribute("products", products);

        // 3. Lấy danh sách sản phẩm cảnh báo chạm đáy
        List<Product> lowStockProducts = productDAO.getLowStockProducts();
        request.setAttribute("lowStockProducts", lowStockProducts);

        // 4. Lấy thông báo thông minh cho nhân viên thu ngân
        Integer currentUserId = (currentUser != null) ? currentUser.getId() : null;
        request.setAttribute("notifications", notificationDAO.getNotificationsForUser(currentUserId, 5));
        request.setAttribute("unreadNotificationCount", notificationDAO.getUnreadCount(currentUserId));

        // 5. Lấy danh sách đơn hàng trong ngày/ca
        List<Order> shiftOrders = orderDAO.getTodayOrders();
        request.setAttribute("shiftOrders", shiftOrders);
        request.setAttribute("shiftOrderCount", shiftOrders.size());

        request.getRequestDispatcher("/views/pos.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("user") : null;

        int userId = (currentUser != null) ? currentUser.getId() : 3;
        String userName = (currentUser != null) ? currentUser.getFullName() : "Lê Lan Anh";
        String userRole = (currentUser != null && currentUser.getRole() != null) ? currentUser.getRole() : "STAFF";

        String action = request.getParameter("action");

        // =====================================================================
        // 1. HÀNH ĐỘNG: BẮT ĐẦU CA LÀM VIỆC (MỞ CA MỚI)
        // =====================================================================
        if ("startShift".equalsIgnoreCase(action)) {
            double openingCash = 1000000;
            try {
                String cashStr = request.getParameter("openingCash");
                if (cashStr != null && !cashStr.trim().isEmpty()) {
                    openingCash = Double.parseDouble(cashStr.replaceAll("[^0-9.]", ""));
                }
            } catch (Exception ignored) {}

            String note = request.getParameter("note");
            if (note == null || note.trim().isEmpty()) {
                note = "Vào ca làm việc thu ngân";
            }

            workShiftDAO.openShift(userId, openingCash, note);

            logDAO.log(new ActivityLog(0, userId, userName, "Bắt đầu ca làm việc", 
                "Mở ca làm việc mới, tiền mặt đầu ca: " + String.format("%,.0f đ", openingCash), 
                request.getRemoteAddr(), userRole, "SHIFT", "Thành công", null));

            response.sendRedirect(request.getContextPath() + "/pos");
            return;
        }

        // =====================================================================
        // 2. HÀNH ĐỘNG: KẾT CA LÀM VIỆC (CHỐT CA & ĐÓNG CA)
        // =====================================================================
        if ("closeShift".equalsIgnoreCase(action)) {
            int shiftId = 0;
            try {
                String sIdStr = request.getParameter("shiftId");
                if (sIdStr != null && !sIdStr.isEmpty()) {
                    shiftId = Integer.parseInt(sIdStr);
                }
            } catch (Exception ignored) {}

            if (shiftId == 0) {
                WorkShift active = workShiftDAO.getCurrentShiftByStaff(userId, userName);
                if (active != null) shiftId = active.getShiftId();
            }

            double closingCash = 0;
            try {
                String closeCashStr = request.getParameter("closingCash");
                if (closeCashStr != null && !closeCashStr.trim().isEmpty()) {
                    closingCash = Double.parseDouble(closeCashStr.replaceAll("[^0-9.]", ""));
                }
            } catch (Exception ignored) {}

            String note = request.getParameter("note");
            if (note == null || note.trim().isEmpty()) {
                note = "Kết ca làm việc hoàn tất";
            }

            if (shiftId > 0) {
                workShiftDAO.closeShift(shiftId, closingCash, note);

                logDAO.log(new ActivityLog(0, userId, userName, "Kết thúc ca làm việc", 
                    "Chốt ca #" + shiftId + ", tiền mặt cuối ca: " + String.format("%,.0f đ", closingCash), 
                    request.getRemoteAddr(), userRole, "CA-" + shiftId, "Thành công", null));
            }

            response.sendRedirect(request.getContextPath() + "/pos");
            return;
        }

        // =====================================================================
        // 3. HÀNH ĐỘNG: BÁN HÀNG & CHECKOUT POS (TRẢ VỀ JSON)
        // =====================================================================
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        String paymentMethod = request.getParameter("paymentMethod");
        if (paymentMethod == null || paymentMethod.trim().isEmpty()) {
            paymentMethod = "Tiền mặt";
        }

        // Nhận danh sách sản phẩm từ các tham số form
        String[] productIds = request.getParameterValues("productId");
        String[] quantitiesStr = request.getParameterValues("quantity");

        // Hỗ trợ cả trường hợp gửi dạng đơn lẻ hoặc chuỗi: "SM01:2,AT01:1"
        if (productIds == null && request.getParameter("items") != null) {
            String itemsStr = request.getParameter("items");
            String[] pairs = itemsStr.split(",");
            List<String> pIdList = new ArrayList<>();
            List<String> qList = new ArrayList<>();
            for (String p : pairs) {
                String[] parts = p.split(":");
                if (parts.length == 2) {
                    pIdList.add(parts[0].trim());
                    qList.add(parts[1].trim());
                }
            }
            productIds = pIdList.toArray(new String[0]);
            quantitiesStr = qList.toArray(new String[0]);
        }

        if (productIds == null || productIds.length == 0 || quantitiesStr == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"success\":false,\"message\":\"Giỏ hàng trống!\"}");
            return;
        }

        double totalAmount = 0;
        List<OrderDetail> details = new ArrayList<>();

        // Kiểm tra tính hợp lệ và tồn kho trước khi lập đơn
        for (int i = 0; i < productIds.length; i++) {
            String pId = productIds[i];
            int qty = 1;
            try {
                qty = Integer.parseInt(quantitiesStr[i]);
            } catch (Exception ignored) {}

            if (qty <= 0) continue;

            Product p = productDAO.getProductById(pId);
            if (p == null) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"success\":false,\"message\":\"Sản phẩm mã " + pId + " không tồn tại!\"}");
                return;
            }

            if (p.getStockQuantity() < qty) {
                response.setStatus(HttpServletResponse.SC_CONFLICT);
                out.print("{\"success\":false,\"message\":\"Sản phẩm " + p.getName() + " chỉ còn " + p.getStockQuantity() + " trong kho, không đủ số lượng " + qty + "!\"}");
                return;
            }

            double subtotal = p.getPrice() * qty;
            totalAmount += subtotal;

            OrderDetail d = new OrderDetail(p.getId(), p.getName(), qty, p.getPrice());
            d.setSubtotal(subtotal);
            details.add(d);
        }

        // Lấy ca làm việc đang mở
        WorkShift activeShift = workShiftDAO.getCurrentShiftByStaff(userId, userName);
        Integer shiftId = (activeShift != null) ? activeShift.getShiftId() : null;

        // Tạo mã đơn hàng tự động duy nhất
        String orderCode = "BH-" + (System.currentTimeMillis() % 100000);
        Order order = new Order(0, orderCode, userId, shiftId, totalAmount, paymentMethod, null);
        order.setStaffName(userName);

        boolean created = orderDAO.createOrder(order, details);

        if (created) {
            // Ghi nhận biến động thẻ kho StockTransactions cho từng món hàng bán ra
            for (OrderDetail d : details) {
                Product cur = productDAO.getProductById(d.getProductId());
                int curStock = cur != null ? cur.getStockQuantity() : 0;
                int prodIntId = 0;
                try { prodIntId = Integer.parseInt(d.getProductId()); } catch (Exception ignored) {}
                transDAO.logTransaction(prodIntId, -d.getQuantity(), curStock + d.getQuantity(), curStock, "SALE", orderCode, userId, "Bán hàng POS đơn #" + orderCode);
            }

            // Ghi nhật ký bán hàng
            String logDetail = String.format("%,.0f đ · %s · Trừ tồn %d mặt hàng.", totalAmount, paymentMethod, details.size());
            logDAO.log(new ActivityLog(0, userId, userName, "Thanh toán đơn bán hàng", 
                logDetail, request.getRemoteAddr(), 
                userRole, orderCode, "Thành công", null));

            out.print("{\"success\":true,\"orderCode\":\"" + orderCode + "\",\"totalAmount\":" + (long) totalAmount + "}");
        } else {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"success\":false,\"message\":\"Không thể tạo đơn hàng do xung đột tồn kho. Vui lòng thử lại!\"}");
        }
    }
}
