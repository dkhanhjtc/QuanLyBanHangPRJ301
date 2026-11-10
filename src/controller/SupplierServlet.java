package controller;

import dal.ActivityLogDAO;
import dal.SupplierDAO;
import dal.SystemNotificationDAO;
import model.ActivityLog;
import model.Supplier;
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

@WebServlet(name = "SupplierServlet", urlPatterns = {"/suppliers"})
public class SupplierServlet extends HttpServlet {

    private final SupplierDAO supplierDAO = new SupplierDAO();
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
        List<Supplier> all = supplierDAO.getAllSuppliers();
        List<Supplier> suppliers = new ArrayList<>();

        int activeCount = 0;
        for (Supplier s : all) {
            if ("ACTIVE".equalsIgnoreCase(s.getStatus())) {
                activeCount++;
            }
            if (query != null && !query.trim().isEmpty()) {
                String q = query.trim().toLowerCase();
                String name = s.getSupplierName() != null ? s.getSupplierName().toLowerCase() : "";
                String code = s.getSupplierCode() != null ? s.getSupplierCode().toLowerCase() : "";
                String phone = s.getContactPhone() != null ? s.getContactPhone().toLowerCase() : "";
                if (name.contains(q) || code.contains(q) || phone.contains(q)) {
                    suppliers.add(s);
                }
            } else {
                suppliers.add(s);
            }
        }

        request.setAttribute("suppliers", suppliers);
        request.setAttribute("totalSuppliers", all.size());
        request.setAttribute("activeSuppliers", activeCount);
        request.setAttribute("notifications", notificationDAO.getNotificationsForUser(currentUserId, 5));
        request.setAttribute("unreadNotificationCount", notificationDAO.getUnreadCount(currentUserId));

        request.getRequestDispatcher("/views/suppliers.jsp").forward(request, response);
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
            response.sendRedirect(request.getContextPath() + "/suppliers?error=unauthorized");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) action = "save";

        if ("add".equalsIgnoreCase(action) || "save".equalsIgnoreCase(action)) {
            String supplierIdStr = request.getParameter("supplierId");
            String code = request.getParameter("supplierCode");
            String name = request.getParameter("supplierName");
            String phone = request.getParameter("contactPhone");
            String address = request.getParameter("address");
            String status = request.getParameter("status");
            if (status == null || status.trim().isEmpty()) status = "ACTIVE";

            int sId = 0;
            try {
                if (supplierIdStr != null && !supplierIdStr.trim().isEmpty()) {
                    sId = Integer.parseInt(supplierIdStr);
                }
            } catch (Exception ignored) {}

            if (sId > 0) {
                // Update
                Supplier s = new Supplier(sId, code, name, phone, address, status, null);
                supplierDAO.updateSupplier(s);
                logDAO.log(new ActivityLog(0, userId, userName, "Cập nhật nhà cung cấp", 
                    "Cập nhật thông tin NCC " + name + " (" + code + ")", 
                    request.getRemoteAddr(), userRole, code, "Thành công", null));
            } else {
                // Add
                if (code == null || code.trim().isEmpty()) {
                    code = "NCC-" + (System.currentTimeMillis() % 10000);
                }
                Supplier s = new Supplier(0, code, name, phone, address, status, null);
                supplierDAO.insertSupplier(s);
                logDAO.log(new ActivityLog(0, userId, userName, "Thêm nhà cung cấp mới", 
                    "Thêm đối tác " + name + " (Mã: " + code + ", SĐT: " + phone + ")", 
                    request.getRemoteAddr(), userRole, code, "Thành công", null));
            }
        } else if ("delete".equalsIgnoreCase(action)) {
            String supplierIdStr = request.getParameter("supplierId");
            int sId = 0;
            try {
                if (supplierIdStr != null) sId = Integer.parseInt(supplierIdStr);
            } catch (Exception ignored) {}

            if (sId > 0) {
                Supplier s = supplierDAO.getSupplierById(sId);
                String sName = s != null ? s.getSupplierName() : ("ID " + sId);
                String sCode = s != null ? s.getSupplierCode() : "-";
                supplierDAO.deleteSupplier(sId);
                logDAO.log(new ActivityLog(0, userId, userName, "Xóa nhà cung cấp", 
                    "Xóa/ngừng hợp tác với nhà cung cấp " + sName, 
                    request.getRemoteAddr(), userRole, sCode, "Thành công", null));
            }
        }

        response.sendRedirect(request.getContextPath() + "/suppliers");
    }
}

