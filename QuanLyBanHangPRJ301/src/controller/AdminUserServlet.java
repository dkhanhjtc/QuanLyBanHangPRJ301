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
import java.util.List;

@WebServlet(name = "AdminUserServlet", urlPatterns = {"/admin-users"})
public class AdminUserServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final ActivityLogDAO logDAO = new ActivityLogDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<User> userList = userDAO.getAllUsers();
        request.setAttribute("users", userList);
        request.setAttribute("userCount", userList.size());

        request.getRequestDispatcher("/views/admin_users.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("user") : null;
        int currentUserId = (currentUser != null) ? currentUser.getId() : 1;
        String currentUserName = (currentUser != null) ? currentUser.getFullName() : "Super Admin";

        String action = request.getParameter("action");
        String userIdStr = request.getParameter("userId");

        int targetUserId = 0;
        try {
            if (userIdStr != null) targetUserId = Integer.parseInt(userIdStr);
        } catch (Exception ignored) {}

        if ("toggle_status".equalsIgnoreCase(action) && targetUserId > 0) {
            User target = userDAO.getUserById(targetUserId);
            userDAO.toggleUserStatus(targetUserId);

            String logDetail = (target != null && target.isIsActive()) ? 
                ("Thu hồi quyền đăng nhập của " + target.getFullName()) : 
                ("Kích hoạt lại tài khoản của " + (target != null ? target.getFullName() : targetUserId));

            logDAO.log(new ActivityLog(0, currentUserId, currentUserName, "Đổi trạng thái tài khoản", 
                logDetail, request.getRemoteAddr(), "ADMIN", 
                target != null ? target.getLoginCode() : ("ID-" + targetUserId), "Thành công", null));
        } 
        else if ("update_role".equalsIgnoreCase(action) && targetUserId > 0) {
            String newRole = request.getParameter("role");
            if (newRole != null && !newRole.trim().isEmpty()) {
                userDAO.updateRole(targetUserId, newRole);
                User target = userDAO.getUserById(targetUserId);

                logDAO.log(new ActivityLog(0, currentUserId, currentUserName, "Cập nhật vai trò", 
                    "Đổi vai trò người dùng " + (target != null ? target.getFullName() : targetUserId) + " thành " + newRole, 
                    request.getRemoteAddr(), "ADMIN", 
                    target != null ? target.getLoginCode() : ("ID-" + targetUserId), "Thành công", null));
            }
        }
        else if ("add_user".equalsIgnoreCase(action)) {
            String loginCode = request.getParameter("loginCode");
            String phone = request.getParameter("phone");
            String fullName = request.getParameter("fullName");
            String password = request.getParameter("password");
            String role = request.getParameter("role");

            if (loginCode != null && fullName != null && password != null) {
                User newUser = new User(0, loginCode, phone, fullName, password, role != null ? role : "STAFF", true, null);
                userDAO.addUser(newUser);

                logDAO.log(new ActivityLog(0, currentUserId, currentUserName, "Cấp mã đăng nhập mới", 
                    fullName + " · Vai trò " + role, request.getRemoteAddr(), "ADMIN", loginCode, "Thành công", null));
            }
        }

        response.sendRedirect(request.getContextPath() + "/admin-users");
    }
}

