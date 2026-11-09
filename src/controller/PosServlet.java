package controller;

import dal.ActivityLogDAO;
import dal.OrderDAO;
import dal.ProductDAO;
import model.ActivityLog;
import model.Order;
import model.OrderDetail;
import model.Product;
import model.User;
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

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Lấy danh mục được chọn (nếu có)
        String category = request.getParameter("category");
        List<Product> products = productDAO.getProductsByCategory(category);
        request.setAttribute("products", products);

        // Lấy danh sách sản phẩm cảnh báo chạm đáy
        List<Product> lowStockProducts = productDAO.getLowStockProducts();
        request.setAttribute("lowStockProducts", lowStockProducts);

        // Lấy danh sách đơn hàng trong ngày/ca
        List<Order> shiftOrders = orderDAO.getTodayOrders();
        request.setAttribute("shiftOrders", shiftOrders);
        request.setAttribute("shiftOrderCount", shiftOrders.size());

        request.getRequestDispatcher("/views/pos.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("user") : null;

        int userId = (currentUser != null) ? currentUser.getId() : 1;
        String userName = (currentUser != null) ? currentUser.getFullName() : "Nhân viên";

        String paymentMethod = request.getParameter("paymentMethod");
        if (paymentMethod == null || paymentMethod.trim().isEmpty()) {
            paymentMethod = "Tiền mặt";
        }

        // Nhận danh sách sản phẩm từ các tham số form
        String[] productIds = request.getParameterValues("productId");
        String[] quantitiesStr = request.getParameterValues("quantity");

        // Hỗ trợ cả trường hợp gửi dạng đơn lẻ hoặc chuỗi
        if (productIds == null && request.getParameter("items") != null) {
            // Định dạng chuỗi đơn giản: "CF01:2,MK01:1,GR01:1"
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

        PrintWriter out = response.getWriter();

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

        // Tạo mã đơn hàng tự động duy nhất
        String orderCode = "BH-" + (System.currentTimeMillis() % 100000);
        dal.WorkShiftDAO workShiftDAO = new dal.WorkShiftDAO();
        model.WorkShift activeShift = workShiftDAO.getCurrentShiftByStaff(userId);
        Integer shiftId = (activeShift != null) ? activeShift.getShiftId() : null;

        Order order = new Order(0, orderCode, userId, shiftId, totalAmount, paymentMethod, null);
        order.setStaffName(userName);

        boolean created = orderDAO.createOrder(order, details);

        if (created) {
            // Ghi nhận biến động thẻ kho StockTransactions cho từng món hàng bán ra
            dal.StockTransactionDAO transDAO = new dal.StockTransactionDAO();
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
                currentUser != null ? currentUser.getRole() : "STAFF", 
                orderCode, "Thành công", null));

            out.print("{\"success\":true,\"orderCode\":\"" + orderCode + "\",\"totalAmount\":" + (long) totalAmount + "}");
        } else {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"success\":false,\"message\":\"Không thể tạo đơn hàng do xung đột tồn kho. Vui lòng thử lại!\"}");
        }
    }
}

