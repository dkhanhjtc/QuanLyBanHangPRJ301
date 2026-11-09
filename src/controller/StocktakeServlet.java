package controller;

import dal.ActivityLogDAO;
import dal.StocktakeDAO;
import model.ActivityLog;
import model.Stocktake;
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

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

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

        // 2. Xem danh sách phân công kiểm kê định kỳ
        List<Stocktake> list = stocktakeDAO.getAllStocktakes();
        request.setAttribute("stocktakes", list);

        int openCount = 0;
        int reviewCount = 0;
        int overdueCount = 0;

        for (Stocktake st : list) {
            if ("PENDING".equalsIgnoreCase(st.getStatus())) openCount++;
            else if ("REVIEW".equalsIgnoreCase(st.getStatus())) reviewCount++;
            else if ("OVERDUE".equalsIgnoreCase(st.getStatus())) overdueCount++;
        }

        request.setAttribute("openCount", openCount);
        request.setAttribute("reviewCount", reviewCount);
        request.setAttribute("overdueCount", overdueCount);

        request.getRequestDispatcher("/views/stocktakes.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("user") : null;
        int userId = (currentUser != null) ? currentUser.getId() : 2;
        String userName = (currentUser != null) ? currentUser.getFullName() : "Nguyễn Minh Hà";
        String userRole = (currentUser != null) ? currentUser.getRole() : "MANAGER";

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

        // Duyệt điều chỉnh tồn kho theo số đếm thực tế
        if ("approve".equalsIgnoreCase(action) && stocktakeId > 0) {
            stocktakeDAO.approveStocktake(stocktakeId);

            logDAO.log(new ActivityLog(0, userId, userName, "Duyệt đối soát kiểm kê", 
                "Cân bằng tồn kho thực tế cho phiếu " + (code != null ? code : ("ID " + stocktakeId)), 
                request.getRemoteAddr(), userRole, (code != null ? code : ("KK-" + stocktakeId)), "Thành công", null));
        }

        response.sendRedirect(request.getContextPath() + "/stocktakes");
    }
}

