<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<header class="topbar">
  <!-- Breadcrumb Navigation -->
  <div class="breadcrumbs">
    <a href="${pageContext.request.contextPath}/">
      <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M3 9l9-7 9 7v11a2 2 0 01-2 2H5a2 2 0 01-2-2z"/>
        <polyline points="9 22 9 12 15 12 15 22"/>
      </svg>
      <span>
        <c:choose>
          <c:when test="${userRole eq 'admin'}">Hệ thống</c:when>
          <c:otherwise>An Nhiên</c:otherwise>
        </c:choose>
      </span>
    </a>
    <span>/</span>
    <span class="current">${empty breadcrumbCurrent ? 'Tổng quan' : breadcrumbCurrent}</span>
  </div>

  <!-- Topbar Right Controls -->
  <div class="topbar-right">
    <span class="mock-badge">Dữ liệu minh họa</span>

    <button type="button" class="icon-button" title="Thông báo" onclick="alert('Bạn có 3 thông báo mới về phiếu nhập kho & ca làm việc!')">
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M18 8A6 6 0 006 8c0 7-3 9-3 9h18s-3-2-3-9"/>
        <path d="M13.73 21a2 2 0 01-3.46 0"/>
      </svg>
    </button>

    <!-- User Profile Dropdown -->
    <div class="user-profile" id="userMenuToggle" onclick="toggleUserDropdown(event)" style="position: relative;">
      <div class="avatar-circle">
        <c:choose>
          <c:when test="${userRole eq 'staff'}">LA</c:when>
          <c:when test="${userRole eq 'admin'}">MA</c:when>
          <c:otherwise>MH</c:otherwise>
        </c:choose>
      </div>
      <div class="user-info-text">
        <div class="user-name">
          <c:choose>
            <c:when test="${userRole eq 'staff'}">Lê Lan Anh</c:when>
            <c:when test="${userRole eq 'admin'}">Mai Anh</c:when>
            <c:otherwise>Nguyễn Minh Hà</c:otherwise>
          </c:choose>
        </div>
        <div class="user-role-label">
          <c:choose>
            <c:when test="${userRole eq 'staff'}">Nhân viên</c:when>
            <c:when test="${userRole eq 'admin'}">Super Admin</c:when>
            <c:otherwise>Quản lý</c:otherwise>
          </c:choose>
        </div>
      </div>
      <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" color="#94a3b8">
        <path d="M6 9l6 6 6-6"/>
      </svg>

      <!-- Dropdown Popup -->
      <div id="userDropdown" style="display:none; position:absolute; right:0; top:48px; background:#fff; border:1px solid #e2e8f0; border-radius:10px; width:220px; box-shadow:0 10px 15px -3px rgba(0,0,0,0.1); z-index:1000; padding:8px 0;">
        <div style="padding:8px 16px; font-size:0.75rem; font-weight:700; color:#94a3b8; text-transform:uppercase;">Chuyển đổi vai trò</div>
        <a href="${pageContext.request.contextPath}/views/dashboard.jsp" style="display:flex; align-items:center; gap:8px; padding:8px 16px; font-size:0.85rem; color:#1e293b;">
          <span>🧑‍💼</span> Quản lý (Minh Hà)
        </a>
        <a href="${pageContext.request.contextPath}/views/pos.jsp" style="display:flex; align-items:center; gap:8px; padding:8px 16px; font-size:0.85rem; color:#1e293b;">
          <span>🛒</span> Nhân viên POS (Lan Anh)
        </a>
        <a href="${pageContext.request.contextPath}/views/admin_users.jsp" style="display:flex; align-items:center; gap:8px; padding:8px 16px; font-size:0.85rem; color:#1e293b;">
          <span>🛡️</span> Super Admin (Mai Anh)
        </a>
        <div style="height:1px; background:#f1f5f9; margin:6px 0;"></div>
        <a href="${pageContext.request.contextPath}/views/login.jsp" style="display:flex; align-items:center; gap:8px; padding:8px 16px; font-size:0.85rem; color:#ef4444; font-weight:600;">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4M16 17l5-5-5-5M21 12H9"/></svg>
          Đăng xuất
        </a>
      </div>
    </div>
  </div>
</header>

