<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="activeMenu" value="${empty activeMenu ? 'dashboard' : activeMenu}" />
<c:set var="userRole" value="${empty sessionScope.userRole ? (empty sessionScope.user.role ? (empty currentRole ? 'manager' : currentRole) : sessionScope.user.role.toLowerCase()) : sessionScope.userRole.toLowerCase()}" />

<aside class="sidebar">
  <!-- Brand Header -->
  <div class="brand-logo">
    <div class="brand-icon">
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
        <path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/>
      </svg>
    </div>
    <div>
      <div>kiotflow</div>
      <div class="brand-tag">RETAIL OPERATIONS</div>
    </div>
  </div>

  <!-- Workspace Selector Card -->
  <div class="workspace-card" onclick="alert('Chi nhánh: Cửa hàng An Nhiên (128 Nguyễn Trãi)')">
    <div>
      <div class="workspace-label">KHÔNG GIAN LÀM VIỆC</div>
      <div class="workspace-name">
        <c:choose>
          <c:when test="${userRole eq 'admin'}">Quản trị hệ thống</c:when>
          <c:otherwise>Cửa hàng An Nhiên</c:otherwise>
        </c:choose>
      </div>
      <div class="workspace-sub">
        <c:choose>
          <c:when test="${userRole eq 'admin'}">Toàn bộ tài khoản</c:when>
          <c:otherwise>Chi nhánh Nguyễn Trãi</c:otherwise>
        </c:choose>
      </div>
    </div>
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" color="#94a3b8">
      <path d="M7 15l5 5 5-5M7 9l5-5 5 5"/>
    </svg>
  </div>

  <!-- Navigation Groups -->
  <c:choose>
    <%-- ================= STAFF NAVIGATION ================= --%>
    <c:when test="${userRole eq 'staff'}">
      <div class="nav-section-title">VẬN HÀNH</div>
      <ul class="nav-menu">
        <li>
          <a href="${pageContext.request.contextPath}/pos" class="nav-link ${activeMenu eq 'pos' ? 'active nav-item--active' : ''}">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
              <rect x="2" y="4" width="20" height="16" rx="2"/>
              <path d="M7 15h0M2 10h20"/>
            </svg>
            <span>Bán hàng</span>
          </a>
        </li>
        <li>
          <a href="javascript:void(0)" onclick="if(typeof openShiftOrdersModal === 'function'){openShiftOrdersModal();}else{location.href='${pageContext.request.contextPath}/pos';}" class="nav-link ${activeMenu eq 'shift_orders' ? 'active nav-item--active' : ''}">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
              <rect x="3" y="4" width="18" height="18" rx="2"/>
              <path d="M16 2v4M8 2v4M3 10h18"/>
            </svg>
            <span>Đơn trong ca</span>
          </a>
        </li>
        <li>
          <a href="${pageContext.request.contextPath}/stocktakes" class="nav-link ${activeMenu eq 'stocktakes' ? 'active nav-item--active' : ''}">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
              <path d="M9 11l3 3L22 4"/>
              <path d="M21 12v7a2 2 0 01-2 2H5a2 2 0 01-2-2V5a2 2 0 012-2h11"/>
            </svg>
            <span>Kiểm kê của tôi</span>
          </a>
        </li>
      </ul>
    </c:when>

    <%-- ================= ADMIN NAVIGATION ================= --%>
    <c:when test="${userRole eq 'admin'}">
      <div class="nav-section-title">QUẢN TRỊ</div>
      <ul class="nav-menu">
        <li>
          <a href="${pageContext.request.contextPath}/admin-users" class="nav-link ${activeMenu eq 'admin_users' ? 'active nav-item--active' : ''}">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
              <path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/>
              <circle cx="9" cy="7" r="4"/>
              <path d="M23 21v-2a4 4 0 00-3-3.87M16 3.13a4 4 0 010 7.75"/>
            </svg>
            <span>Tài khoản &amp; mã</span>
          </a>
        </li>
        <li>
          <a href="${pageContext.request.contextPath}/activity-log" class="nav-link ${activeMenu eq 'activity_log' ? 'active nav-item--active' : ''}">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
              <circle cx="12" cy="12" r="10"/>
              <polyline points="12 6 12 12 16 14"/>
            </svg>
            <span>Nhật ký hoạt động</span>
          </a>
        </li>
        <li style="margin-top: 10px;">
          <div class="nav-section-title">CHẾ ĐỘ XEM</div>
        </li>
        <li>
          <a href="${pageContext.request.contextPath}/dashboard" class="nav-link ${activeMenu eq 'dashboard' ? 'active nav-item--active' : ''}">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
              <rect x="3" y="3" width="7" height="7"/>
              <rect x="14" y="3" width="7" height="7"/>
              <rect x="14" y="14" width="7" height="7"/>
              <rect x="3" y="14" width="7" height="7"/>
            </svg>
            <span>Tổng quan quản lý</span>
          </a>
        </li>
      </ul>
    </c:when>

    <%-- ================= MANAGER NAVIGATION (DEFAULT) ================= --%>
    <c:otherwise>
      <div class="nav-section-title">VẬN HÀNH</div>
      <ul class="nav-menu">
        <li>
          <a href="${pageContext.request.contextPath}/dashboard" class="nav-link ${activeMenu eq 'dashboard' ? 'active nav-item--active' : ''}">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
              <rect x="3" y="3" width="7" height="7"/>
              <rect x="14" y="3" width="7" height="7"/>
              <rect x="14" y="14" width="7" height="7"/>
              <rect x="3" y="14" width="7" height="7"/>
            </svg>
            <span>Tổng quan</span>
          </a>
        </li>
        <li>
          <a href="${pageContext.request.contextPath}/products" class="nav-link ${activeMenu eq 'products' ? 'active nav-item--active' : ''}">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
              <path d="M21 16V8a2 2 0 00-1-1.73l-7-4a2 2 0 00-2 0l-7 4A2 2 0 003 8v8a2 2 0 001 1.73l7 4a2 2 0 002 0l7-4A2 2 0 0021 16z"/>
              <polyline points="3.27 6.96 12 12.01 20.73 6.96"/>
              <line x1="12" y1="22.08" x2="12" y2="12"/>
            </svg>
            <span>Hàng hóa</span>
          </a>
        </li>
        <li>
          <a href="${pageContext.request.contextPath}/products?tab=approvals" class="nav-link ${activeMenu eq 'approvals' ? 'active nav-item--active' : ''}">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
              <path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/>
              <polyline points="14 2 14 8 20 8"/>
              <line x1="16" y1="13" x2="8" y2="13"/>
              <line x1="16" y1="17" x2="8" y2="17"/>
              <polyline points="10 9 9 9 8 9"/>
            </svg>
            <span>Duyệt hàng về</span>
          </a>
        </li>
        <li>
          <a href="${pageContext.request.contextPath}/stocktakes" class="nav-link ${activeMenu eq 'stocktakes' ? 'active nav-item--active' : ''}">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
              <path d="M9 11l3 3L22 4"/>
              <path d="M21 12v7a2 2 0 01-2 2H5a2 2 0 01-2-2V5a2 2 0 012-2h11"/>
            </svg>
            <span>Kiểm kê</span>
          </a>
        </li>
      </ul>
    </c:otherwise>
  </c:choose>

  <!-- Sidebar Footer Card -->
  <div class="sidebar-footer">
    <div class="role-badge-card">
      <div class="role-badge-title">
        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="#2563eb" stroke-width="2.5">
          <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>
        </svg>
        <span>
          <c:choose>
            <c:when test="${userRole eq 'staff'}">Nhân viên</c:when>
            <c:when test="${userRole eq 'admin'}">Super Admin</c:when>
            <c:otherwise>Quản lý</c:otherwise>
          </c:choose>
        </span>
      </div>
      <div class="role-badge-desc">
        <c:choose>
          <c:when test="${userRole eq 'staff'}">Bán hàng, xem đơn trong ca và thực hiện kiểm kê được giao.</c:when>
          <c:when test="${userRole eq 'admin'}">Cấp mã, quản lý vai trò và tra cứu nhật ký hệ thống.</c:when>
          <c:otherwise>Quản lý hàng hóa, duyệt nhập kho và đối soát kiểm kê.</c:otherwise>
        </c:choose>
      </div>
    </div>

    <a href="javascript:void(0)" class="help-link" onclick="alert('Trung tâm hỗ trợ vận hành KiotFlow\nHotline: 1900-8888\nEmail: hotro@kiotflow.vn')">
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <circle cx="12" cy="12" r="10"/>
        <path d="M9.09 9a3 3 0 015.83 1c0 2-3 3-3 3M12 17h.01"/>
      </svg>
      <span>Trung tâm trợ giúp</span>
    </a>
  </div>
</aside>

<!-- JavaScript for Smooth Click Navigation Animation -->
<script>
  document.addEventListener('DOMContentLoaded', function() {
    var navLinks = document.querySelectorAll('.sidebar .nav-link');
    navLinks.forEach(function(link) {
      link.addEventListener('click', function(e) {
        var href = this.getAttribute('href');
        if (href && !href.startsWith('javascript')) {
          navLinks.forEach(function(l) {
            l.classList.remove('active');
            l.classList.remove('nav-item--active');
          });
          this.classList.add('nav-item--active');
          this.classList.add('active');
        }
      });
    });
  });
</script>
