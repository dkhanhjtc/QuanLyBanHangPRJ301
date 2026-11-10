package controller;

import dal.ActivityLogDAO;
import dal.CategoryDAO;
import dal.SystemNotificationDAO;
import model.ActivityLog;
import model.Category;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "CategoryServlet", urlPatterns = {"/categories"})
public class CategoryServlet extends HttpServlet {

    private final CategoryDAO categoryDAO = new CategoryDAO();
    private final ActivityLogDAO logDAO = new ActivityLogDAO();
    private final SystemNotificationDAO notificationDAO = new SystemNotificationDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("user") : null;
        Integer currentUserId = (currentUser != null) ? currentUser.getId() : null;
        boolean isStaff = currentUser != null && "STAFF".equalsIgnoreCase(currentUser.getRole());
        request.setAttribute("isStaff", isStaff);
        request.setAttribute("userRole", currentUser != null && currentUser.getRole() != null ? currentUser.getRole().toLowerCase() : "manager");

        String query = request.getParameter("q");
        List<Category> all = categoryDAO.getAllCategories();
        List<Category> categories = new ArrayList<>();

        int totalProductsInCats = 0;
        for (Category c : all) {
            totalProductsInCats += c.getProductCount();
            if (query != null && !query.trim().isEmpty()) {
                String q = query.trim().toLowerCase();
                String name = c.getCategoryName() != null ? c.getCategoryName().toLowerCase() : "";
                String desc = c.getDescription() != null ? c.getDescription().toLowerCase() : "";
                if (name.contains(q) || desc.contains(q)) {
                    categories.add(c);
                }
            } else {
                categories.add(c);
            }
        }

        request.setAttribute("categories", categories);
        request.setAttribute("totalCategories", all.size());
        request.setAttribute("totalProductsInCats", totalProductsInCats);
        request.setAttribute("notifications", notificationDAO.getNotificationsForUser(currentUserId, 5));
        request.setAttribute("unreadNotificationCount", notificationDAO.getUnreadCount(currentUserId));

        request.getRequestDispatcher("/views/categories.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("user") : null;
        int userId = (currentUser != null) ? currentUser.getId() : 2;
        String userName = (currentUser != null) ? currentUser.getFullName() : "Quản lý";
        String userRole = (currentUser != null) ? currentUser.getRole() : "MANAGER";

        if ("STAFF".equalsIgnoreCase(userRole)) {
            response.sendRedirect(request.getContextPath() + "/categories?error=unauthorized");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) action = "save";

        if ("add".equalsIgnoreCase(action) || "save".equalsIgnoreCase(action)) {
            String catIdStr = request.getParameter("categoryId");
            String name = request.getParameter("categoryName");
            String desc = request.getParameter("description");

            int catId = 0;
            try {
                if (catIdStr != null && !catIdStr.trim().isEmpty()) {
                    catId = Integer.parseInt(catIdStr);
                }
            } catch (Exception ignored) {}

            if (catId > 0) {
                // Update
                Category c = new Category(catId, name, desc);
                categoryDAO.updateCategory(c);
                logDAO.log(new ActivityLog(0, userId, userName, "Cập nhật danh mục", 
                    "Cập nhật danh mục #" + catId + " (" + name + ")", 
                    request.getRemoteAddr(), userRole, "DM-" + catId, "Thành công", null));
            } else {
                // Add
                Category c = new Category(0, name, desc);
                categoryDAO.insertCategory(c);
                logDAO.log(new ActivityLog(0, userId, userName, "Thêm danh mục mới", 
                    "Thêm danh mục hàng hóa mới: " + name, 
                    request.getRemoteAddr(), userRole, "DM", "Thành công", null));
            }
        } else if ("delete".equalsIgnoreCase(action)) {
            String catIdStr = request.getParameter("categoryId");
            int catId = 0;
            try {
                if (catIdStr != null) catId = Integer.parseInt(catIdStr);
            } catch (Exception ignored) {}

            if (catId > 0) {
                Category c = categoryDAO.getCategoryById(catId);
                String cName = c != null ? c.getCategoryName() : ("#" + catId);
                categoryDAO.deleteCategory(catId);
                logDAO.log(new ActivityLog(0, userId, userName, "Xóa danh mục", 
                    "Xóa danh mục " + cName + " (sản phẩm đã chuyển về nhóm mặc định)", 
                    request.getRemoteAddr(), userRole, "DM-" + catId, "Thành công", null));
            }
        }

        response.sendRedirect(request.getContextPath() + "/categories");
    }
}

