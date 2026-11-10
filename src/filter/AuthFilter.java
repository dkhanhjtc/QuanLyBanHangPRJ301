package filter;

import model.User;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebFilter(filterName = "AuthFilter", urlPatterns = {"/*"})
public class AuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        String uri = req.getRequestURI();
        String contextPath = req.getContextPath();
        String path = uri.substring(contextPath.length());

        // Thiết lập mã hóa UTF-8 toàn hệ thống
        req.setCharacterEncoding("UTF-8");
        res.setCharacterEncoding("UTF-8");
        if (path.endsWith(".js")) {
            res.setContentType("application/javascript;charset=UTF-8");
        } else if (path.endsWith(".css")) {
            res.setContentType("text/css;charset=UTF-8");
        } else if (!path.startsWith("/assets/") && !path.endsWith(".svg") && !path.endsWith(".png") && !path.endsWith(".jpg")
                && !path.endsWith(".ico") && !path.endsWith(".woff") && !path.endsWith(".woff2")) {
            res.setContentType("text/html;charset=UTF-8");
        }

        // 1. Cho phép truy cập tự do các tài nguyên tĩnh và trang công khai
        if (path.startsWith("/assets/") ||
            path.endsWith(".css") ||
            path.endsWith(".js") ||
            path.endsWith(".svg") ||
            path.endsWith(".png") ||
            path.endsWith(".jpg") ||
            path.endsWith(".jpeg") ||
            path.endsWith(".gif") ||
            path.endsWith(".ico") ||
            path.endsWith(".woff") ||
            path.endsWith(".woff2") ||
            path.equals("/login") ||
            path.equals("/logout") ||
            path.equals("/views/login.jsp")) {
            chain.doFilter(request, response);
            return;
        }

        // 2. Kiểm tra phiên đăng nhập (Session)
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            // Chưa đăng nhập -> Lưu URL chuyển tiếp và điều hướng về trang đăng nhập
            res.sendRedirect(contextPath + "/login");
            return;
        }

        // 3. Phân quyền truy cập theo vai trò người dùng (RBAC)
        String role = user.getRole() != null ? user.getRole().toUpperCase() : "";

        // Nhân viên (STAFF): Cho phép truy cập /pos, /products (chỉ xem), /stocktakes
        if ("STAFF".equals(role)) {
            if (path.startsWith("/dashboard") ||
                path.startsWith("/suppliers") ||
                path.startsWith("/categories") ||
                path.startsWith("/inbound-shipments") ||
                path.startsWith("/admin-users") ||
                path.startsWith("/activity-log") ||
                path.equals("/views/dashboard.jsp") ||
                path.equals("/views/suppliers.jsp") ||
                path.equals("/views/categories.jsp") ||
                path.equals("/views/inbound_shipments.jsp") ||
                path.equals("/views/admin_users.jsp") ||
                path.equals("/views/activity_log.jsp")) {
                res.sendRedirect(contextPath + "/pos");
                return;
            }
        }

        // Quản lý (MANAGER): Không được vào quản trị tài khoản Super Admin (/admin-users)
        if ("MANAGER".equals(role)) {
            if (path.startsWith("/admin-users") ||
                path.equals("/views/admin_users.jsp")) {
                res.sendRedirect(contextPath + "/dashboard");
                return;
            }
        }

        // Super Admin có toàn quyền truy cập
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
    }
}

