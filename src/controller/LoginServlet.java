package controller;

import dal.ActivityLogDAO;
import dal.UserDAO;
import model.ActivityLog;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "LoginServlet", urlPatterns = {"/login", "/logout"})
public class LoginServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final ActivityLogDAO logDAO = new ActivityLogDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();

        // Xử lý Đăng xuất
        if ("/logout".equals(path)) {
            HttpSession session = request.getSession(false);
            if (session != null) {
                User user = (User) session.getAttribute("user");
                if (user != null) {
                    logDAO.log(new ActivityLog(0, user.getId(), user.getFullName(), "Đăng xuất", 
                        "Người dùng đăng xuất khỏi phiên làm việc", request.getRemoteAddr(), 
                        user.getRole(), "-", "Thành công", null));
                }
                session.invalidate();
            }
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Kiểm tra nếu đã có Session hợp lệ thì chuyển hướng về màn hình tương ứng
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            User user = (User) session.getAttribute("user");
            if ("STAFF".equalsIgnoreCase(user.getRole())) {
                response.sendRedirect(request.getContextPath() + "/pos");
            } else {
                response.sendRedirect(request.getContextPath() + "/dashboard");
            }
            return;
        }

        // Hiển thị trang đăng nhập
        request.getRequestDispatcher("/views/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // Nhận tham số linh hoạt hỗ trợ cả loginCode/password lẫn phone/passcode
        String loginCode = request.getParameter("loginCode");
        if (loginCode == null || loginCode.trim().isEmpty()) {
            loginCode = request.getParameter("phone");
        }

        String password = request.getParameter("password");
        if (password == null || password.trim().isEmpty()) {
            password = request.getParameter("passcode");
        }

        if (loginCode != null) loginCode = loginCode.trim();
        if (password != null) password = password.trim();

        User user = userDAO.login(loginCode, password);

        if (user != null) {
            // Đăng nhập thành công -> Lưu thông tin vào Session
            HttpSession session = request.getSession(true);
            session.setAttribute("user", user);
            session.setAttribute("userRole", user.getRole().toLowerCase());

            // Ghi nhật ký đăng nhập
            logDAO.log(new ActivityLog(0, user.getId(), user.getFullName(), "Đăng nhập hệ thống", 
                "Đăng nhập thành công từ IP " + request.getRemoteAddr(), request.getRemoteAddr(), 
                user.getRole(), user.getLoginCode(), "Thành công", null));

            // Điều hướng theo quyền
            if ("STAFF".equalsIgnoreCase(user.getRole())) {
                response.sendRedirect(request.getContextPath() + "/pos");
            } else {
                response.sendRedirect(request.getContextPath() + "/dashboard");
            }
        } else {
            // Đăng nhập thất bại
            request.setAttribute("error", "Số điện thoại hoặc mã được cấp không chính xác, hoặc tài khoản đã bị thu hồi quyền truy cập.");
            request.setAttribute("enteredPhone", loginCode);
            request.getRequestDispatcher("/views/login.jsp").forward(request, response);
        }
    }
}

