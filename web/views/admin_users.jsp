<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="activeMenu" value="admin_users" />
<c:set var="breadcrumbCurrent" value="Tài khoản & mã" />

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Tài khoản & mã đăng nhập · Kiotflow</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
  <script>
    function copyToClipboard(text) {
      navigator.clipboard.writeText(text);
      alert('Đã sao chép mã đăng nhập: ' + text);
    }
  </script>
</head>
<body>

<div class="app-container">
  <jsp:include page="/common/sidebar.jsp">
    <jsp:param name="activeMenu" value="admin_users" />
  </jsp:include>

  <div class="main-content">
    <jsp:include page="/common/header.jsp">
      <jsp:param name="breadcrumbCurrent" value="Tài khoản & mã" />
    </jsp:include>

    <div class="page-body">
      <!-- Page Top Header -->
      <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 20px;">
        <div>
          <h1 style="font-size: 1.85rem; font-weight: 800; color: #0f172a; letter-spacing: -0.02em;">Tài khoản &amp; mã đăng nhập</h1>
          <div style="font-size: 0.85rem; color: #64748b; margin-top: 4px;">
            Quản lý quyền truy cập tập trung · ${userCount != null ? userCount : 0} tài khoản · Đăng nhập bằng SĐT / Mã + Mật khẩu
          </div>
        </div>
        <div style="display: flex; gap: 10px;">
          <a href="${pageContext.request.contextPath}/admin-users" class="btn btn-outline" title="Làm mới danh sách">
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="23 4 23 10 17 10"/><polyline points="1 20 1 14 7 14"/><path d="M3.51 9a9 9 0 0114.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0020.49 15"/></svg>
            <span>Đồng bộ</span>
          </a>
          <button type="button" class="btn btn-outline" onclick="alert('Đang trích xuất danh sách tài khoản...')">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4M7 10l5 5 5-5M12 15V3"/></svg>
            <span>Xuất tài khoản</span>
          </button>
        </div>
      </div>

      <!-- Role Description Notice -->
      <div style="display: flex; align-items: flex-start; gap: 12px; background: #eff6ff; border: 1px solid #bfdbfe; border-radius: 12px; padding: 14px 18px; margin-bottom: 24px; font-size: 0.825rem; color: #1e40af; line-height: 1.5;">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="flex-shrink:0; margin-top:1px;"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
        <div>
          Super Admin có quyền cấp mới, thu hồi quyền đăng nhập và thay đổi vai trò tài khoản. Mọi thay đổi đều được cập nhật tức thì trong CSDL SQL Server và lưu vào Nhật ký hoạt động.
        </div>
      </div>

      <!-- Main Layout: Table on Left, Action Card on Right -->
      <div style="display: grid; grid-template-columns: 1fr 360px; gap: 24px; align-items: start;">
        <!-- LEFT: ACCOUNTS TABLE (Truy vấn từ CSDL, Không hardcode) -->
        <div>
          <div class="card">
            <!-- Search & Filter Bar -->
            <div style="padding: 16px 20px; display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--border);">
              <div class="input-icon-wrapper" style="flex: 1; max-width: 450px;">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                <input type="text" class="form-input" placeholder="Tìm tên hoặc số điện thoại..." oninput="filterUserTable(this.value)">
              </div>
            </div>

            <!-- Table -->
            <div class="table-responsive">
              <table class="custom-table" id="userMasterTable">
                <thead>
                  <tr>
                    <th>Tài khoản</th>
                    <th>Số điện thoại</th>
                    <th>Mã đăng nhập</th>
                    <th>Vai trò / Đổi</th>
                    <th>Trạng thái</th>
                    <th style="text-align: right;">Thao tác</th>
                  </tr>
                </thead>
                <tbody>
                  <c:choose>
                    <c:when test="${not empty users}">
                      <c:forEach items="${users}" var="u">
                        <tr class="user-row" data-name="${u.fullName}" data-phone="${u.phone}">
                          <td>
                            <div style="font-weight: 700; color: #0f172a;">${u.fullName}</div>
                            <div style="font-size: 0.72rem; color: #64748b;">ID: ${u.id}</div>
                          </td>
                          <td style="font-weight: 500;">${u.phone != null ? u.phone : 'Chưa cập nhật'}</td>
                          <td style="font-family: monospace; font-weight: 700; color: #0f172a;">${u.loginCode}</td>
                          <td>
                            <c:choose>
                              <c:when test="${u.role eq 'ADMIN' and u.id eq sessionScope.user.id}">
                                <span style="font-weight: 600; color: #475569;">Super Admin</span>
                              </c:when>
                              <c:otherwise>
                                <form action="${pageContext.request.contextPath}/admin-users" method="POST" style="margin:0;">
                                  <input type="hidden" name="action" value="update_role">
                                  <input type="hidden" name="userId" value="${u.id}">
                                  <select name="role" class="form-select" style="width: auto; padding: 4px 8px; font-size: 0.8rem; font-weight: 600; color: #2563eb;" onchange="this.form.submit()">
                                    <option value="STAFF" ${u.role eq 'STAFF' ? 'selected' : ''}>Nhân viên</option>
                                    <option value="MANAGER" ${u.role eq 'MANAGER' ? 'selected' : ''}>Quản lý</option>
                                    <option value="ADMIN" ${u.role eq 'ADMIN' ? 'selected' : ''}>Super Admin</option>
                                  </select>
                                </form>
                              </c:otherwise>
                            </c:choose>
                          </td>
                          <td>
                            <c:choose>
                              <c:when test="${u.isActive}">
                                <span class="badge badge-success">Đang hoạt động</span>
                              </c:when>
                              <c:otherwise>
                                <span class="badge badge-danger">Đã thu hồi</span>
                              </c:otherwise>
                            </c:choose>
                          </td>
                          <td style="text-align: right;">
                            <c:choose>
                              <c:when test="${u.role eq 'ADMIN' and u.id eq sessionScope.user.id}">
                                <span title="Không thể thu hồi chính tài khoản của bạn">
                                  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#94a3b8" stroke-width="2"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0110 0v4"/></svg>
                                </span>
                              </c:when>
                              <c:otherwise>
                                <form action="${pageContext.request.contextPath}/admin-users" method="POST" style="display:inline;">
                                  <input type="hidden" name="action" value="toggle_status">
                                  <input type="hidden" name="userId" value="${u.id}">
                                  <button type="submit" class="btn btn-outline" style="padding: 4px 10px; font-size: 0.75rem; ${u.isActive ? 'color: #dc2626; border-color: #fca5a5;' : 'color: #059669; border-color: #6ee7b7;'}" onclick="return confirm('Xác nhận thay đổi trạng thái tài khoản của ${u.fullName}?')">
                                    <span>${u.isActive ? 'Thu hồi' : 'Kích hoạt'}</span>
                                  </button>
                                </form>
                              </c:otherwise>
                            </c:choose>
                          </td>
                        </tr>
                      </c:forEach>
                    </c:when>
                    <c:otherwise>
                      <tr>
                        <td colspan="6" style="text-align: center; padding: 40px; color: #94a3b8;">
                          Chưa có tài khoản người dùng nào trong cơ sở dữ liệu.
                        </td>
                      </tr>
                    </c:otherwise>
                  </c:choose>
                </tbody>
              </table>
            </div>
          </div>
        </div>

        <!-- RIGHT: CẤP MÃ / THÊM TÀI KHOẢN MỚI -->
        <div class="card" style="padding: 24px;">
          <div style="display: flex; align-items: center; gap: 8px; margin-bottom: 6px;">
            <div style="width: 28px; height: 28px; border-radius: 6px; background: #eff6ff; color: #2563eb; display: flex; align-items: center; justify-content: center;">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
            </div>
            <h2 style="font-size: 1.15rem; font-weight: 700; color: #0f172a;">Cấp mã nhân sự mới</h2>
          </div>
          <p style="font-size: 0.78rem; color: #64748b; margin-bottom: 20px;">
            Tạo tài khoản và cấp mã truy cập cho nhân sự mới.
          </p>

          <form action="${pageContext.request.contextPath}/admin-users" method="POST">
            <input type="hidden" name="action" value="add_user">

            <div class="form-group">
              <label class="form-label" for="newFullName">Họ và tên *</label>
              <input type="text" id="newFullName" name="fullName" class="form-input" placeholder="Ví dụ: Hoàng Thu Thảo" required>
            </div>

            <div class="form-group">
              <label class="form-label" for="newPhone">Số điện thoại *</label>
              <input type="text" id="newPhone" name="phone" class="form-input" placeholder="090 111 2233" required>
            </div>

            <div class="form-group">
              <label class="form-label" for="newLoginCode">Mã đăng nhập *</label>
              <input type="text" id="newLoginCode" name="loginCode" class="form-input" placeholder="Ví dụ: AN-NV-007" required>
            </div>

            <div class="form-group">
              <label class="form-label" for="newPassword">Mật khẩu cấp *</label>
              <input type="text" id="newPassword" name="password" class="form-input" value="123456" required>
            </div>

            <div class="form-group">
              <label class="form-label" for="newRole">Vai trò ban đầu *</label>
              <select id="newRole" name="role" class="form-select">
                <option value="STAFF" selected>Nhân viên (POS &amp; Kiểm kê)</option>
                <option value="MANAGER">Quản lý (Kho &amp; Báo cáo)</option>
                <option value="ADMIN">Super Admin (Quản trị)</option>
              </select>
            </div>

            <button type="submit" class="btn btn-primary" style="width: 100%; padding: 12px; margin-top: 8px;">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
              <span>Cấp tài khoản</span>
            </button>
          </form>
        </div>
      </div>
    </div>
  </div>
</div>

<script>
  function filterUserTable(query) {
    var q = query.trim().toLowerCase();
    var rows = document.querySelectorAll('.user-row');
    rows.forEach(function(row) {
      var name = (row.getAttribute('data-name') || '').toLowerCase();
      var phone = (row.getAttribute('data-phone') || '').toLowerCase();
      if (name.indexOf(q) !== -1 || phone.indexOf(q) !== -1) {
        row.style.display = '';
      } else {
        row.style.display = 'none';
      }
    });
  }
</script>
<jsp:include page="/common/footer.jsp" />
</body>
</html>
