package controller;

import dal.ActivityLogDAO;
import dal.StocktakeDAO;
import dal.StockTransactionDAO;
import dal.SystemNotificationDAO;
import model.ActivityLog;
import model.Stocktake;
import model.StocktakeItem;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "StocktakeServlet", urlPatterns = {"/stocktakes", "/stocktake-detail"})
public class StocktakeServlet extends HttpServlet {

    private final StocktakeDAO stocktakeDAO = new StocktakeDAO();
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
        String userRole = (currentUser != null && currentUser.getRole() != null) 
                ? currentUser.getRole().toUpperCase() : "MANAGER";
        boolean isStaff = "STAFF".equals(userRole);

        String path = request.getServletPath();

        // 1. Xem màn hình chi tiết đối soát kiểm kê
        if ("/stocktake-detail".equals(path)) {
            String code = request.getParameter("code");
            String idStr = request.getParameter("id");
            Stocktake stocktake = null;

            if (idStr != null && !idStr.isEmpty()) {
                try {
                    stocktake = stocktakeDAO.getStocktakeById(Integer.parseInt(idStr));
                } catch (Exception ignored) {}
            }

            if (stocktake == null) {
                stocktake = stocktakeDAO.getStocktakeByCode(code != null ? code : "KK-101");
            }

            request.setAttribute("stocktake", stocktake);
            request.getRequestDispatcher("/views/stocktake_detail.jsp").forward(request, response);
            return;
        }

        // 2. Tải danh sách phân công kiểm kê
        List<Stocktake> list;
        if (isStaff && currentUser != null) {
            // Thu ngân chỉ được xem các đợt kiểm kê được phân công cho mình
            list = stocktakeDAO.getStocktakesByStaff(currentUser.getId(), currentUser.getFullName());
        } else {
            // Quản lý và Admin xem toàn bộ
            list = stocktakeDAO.getAllStocktakes();
        }

        // Nạp chi tiết các mặt hàng cho từng đợt kiểm kê
        for (Stocktake s : list) {
            s.setItems(stocktakeDAO.getStocktakeItems(s.getId()));
        }
        request.setAttribute("stocktakes", list);

        int openCount = 0;
        int reviewCount = 0;
        int overdueCount = 0;

        for (Stocktake st : list) {
            String s = st.getStatus() != null ? st.getStatus().toUpperCase() : "";
            if ("PENDING".equals(s) || "ASSIGNED".equals(s)) openCount++;
            else if ("REVIEW".equals(s) || "COUNTED".equals(s)) reviewCount++;
            else if ("OVERDUE".equals(s)) overdueCount++;
        }

        request.setAttribute("openCount", openCount);
        request.setAttribute("reviewCount", reviewCount);
        request.setAttribute("overdueCount", overdueCount);
        request.setAttribute("isStaffOnly", isStaff);

        request.getRequestDispatcher("/views/stocktakes.jsp").forward(request, response);
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
        String userRole = (currentUser != null && currentUser.getRole() != null) ? currentUser.getRole().toUpperCase() : "MANAGER";
        boolean isStaff = "STAFF".equals(userRole);

        String action = request.getParameter("action");
        String idStr = request.getParameter("id");
        String code = request.getParameter("code");

        int stocktakeId = 0;
        if (idStr != null && !idStr.isEmpty()) {
            try { stocktakeId = Integer.parseInt(idStr); } catch (Exception ignored) {}
        } else if (code != null) {
            Stocktake st = stocktakeDAO.getStocktakeByCode(code);
            if (st != null) stocktakeId = st.getId();
        }

        // 1. HÀNH ĐỘNG DUYỆT ĐỐI SOÁT KIỂM KÊ (CHỈ DÀNH CHO QUẢN LÝ / ADMIN)
        if ("approve".equalsIgnoreCase(action) && stocktakeId > 0) {
            if (isStaff) {
                // Thu ngân KHÔNG ĐƯỢC đối soát hoặc duyệt
                response.sendRedirect(request.getContextPath() + "/stocktakes?error=unauthorized");
                return;
            }

            List<StocktakeItem> items = stocktakeDAO.getStocktakeItems(stocktakeId);
            stocktakeDAO.approveStocktake(stocktakeId);

            // Ghi nhận biến động thẻ kho StockTransactions cho từng mặt hàng có chênh lệch
            if (items != null) {
                for (StocktakeItem item : items) {
                    if (item.getVariance() != 0) {
                        int prodIntId = 0;
                        try { prodIntId = Integer.parseInt(item.getProductId()); } catch (Exception ignored) {}
                        stockTransactionDAO.logTransaction(prodIntId, item.getVariance(), 
                            item.getSystemStock(), item.getActualStock(), "STOCKTAKE_ADJUST", 
                            (code != null ? code : ("KK-" + stocktakeId)), userId, 
                            "Cân đối kiểm kê lệch " + item.getVariance() + " (" + (code != null ? code : "Phiếu KK") + ")");
                    }
                }
            }

            // Tạo thông báo thông minh
            notificationDAO.createNotification(null, "Kiểm kê đã được chốt duyệt", 
                "Đợt kiểm kê " + (code != null ? code : ("ID " + stocktakeId)) + " đã được hoàn tất bởi " + userName + ".", 
                "STOCKTAKE_APPROVED", "stocktakes");

            logDAO.log(new ActivityLog(0, userId, userName, "Duyệt đối soát kiểm kê", 
                "Cân bằng tồn kho thực tế cho phiếu " + (code != null ? code : ("ID " + stocktakeId)), 
                request.getRemoteAddr(), userRole, (code != null ? code : ("KK-" + stocktakeId)), "Thành công", null));
        }

        // 2. HÀNH ĐỘNG TẠO PHÂN CÔNG KIỂM KÊ (CHỈ QUẢN LÝ / ADMIN)
        else if ("create".equalsIgnoreCase(action)) {
            if (isStaff) {
                response.sendRedirect(request.getContextPath() + "/stocktakes?error=unauthorized");
                return;
            }

            String title = request.getParameter("title");
            String staffIdStr = request.getParameter("assignedStaffId");
            int assignedStaffId = 3; // Mặc định Lê Lan Anh
            try {
                if (staffIdStr != null && !staffIdStr.isEmpty()) {
                    assignedStaffId = Integer.parseInt(staffIdStr);
                }
            } catch (Exception ignored) {}

            String newCode = "KK-" + (System.currentTimeMillis() % 1000);
            stocktakeDAO.createStocktake(newCode, (title != null ? title : "Kiểm kê khu vực"), assignedStaffId);

            notificationDAO.createNotification(assignedStaffId, "Phân công kiểm kê mới", 
                "Bạn được Quản lý " + userName + " phân công kiểm kê " + title + " (Mã: " + newCode + ").", 
                "STOCKTAKE_ASSIGNED", "stocktakes");

            logDAO.log(new ActivityLog(0, userId, userName, "Tạo phân công kiểm kê", 
                "Giao phiếu " + newCode + " (" + title + ")", 
                request.getRemoteAddr(), userRole, newCode, "Thành công", null));
        }

        // 3. HÀNH ĐỘNG NHÂN VIÊN GỬI SỐ THỰC ĐẾM
        else if ("submitCount".equalsIgnoreCase(action) && stocktakeId > 0) {
            String[] itemIds = request.getParameterValues("itemId");
            String[] actualQtys = request.getParameterValues("actualQty");
            String[] notes = request.getParameterValues("note");

            if (itemIds != null && actualQtys != null) {
                for (int i = 0; i < itemIds.length; i++) {
                    try {
                        int itId = Integer.parseInt(itemIds[i]);
                        int actQty = Integer.parseInt(actualQtys[i]);
                        String nt = (notes != null && i < notes.length) ? notes[i] : "";
                        stocktakeDAO.submitStaffCount(itId, actQty, nt);
                    } catch (Exception ignored) {}
                }
                stocktakeDAO.markStocktakeAsCounted(stocktakeId);

                notificationDAO.createNotification(null, "Số đếm kiểm kê đã gửi", 
                    "Nhân viên " + userName + " đã hoàn thành đếm và gửi kết quả phiếu " + (code != null ? code : ("ID " + stocktakeId)) + " chờ Quản lý đối soát.", 
                    "STOCKTAKE_COUNTED", "stocktakes");
            }
        }

        response.sendRedirect(request.getContextPath() + "/stocktakes");
    }
}
