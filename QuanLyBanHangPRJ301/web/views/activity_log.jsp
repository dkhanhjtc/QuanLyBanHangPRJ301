<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="activeMenu" value="activity_log" />
<c:set var="breadcrumbCurrent" value="Nhật ký hoạt động" />

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Nhật ký hoạt động · Kiotflow</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>

<div class="app-container">
  <jsp:include page="/common/sidebar.jsp" />

  <div class="main-content">
    <jsp:include page="/common/header.jsp" />

    <div class="page-body">
      <!-- Page Top Header -->
      <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 20px;">
        <div>
          <h1 style="font-size: 1.85rem; font-weight: 800; color: #0f172a; letter-spacing: -0.02em;">Nhật ký hoạt động</h1>
          <div style="font-size: 0.85rem; color: #64748b; margin-top: 4px;">
            Theo dõi ai đã làm gì, khi nào và trên bản ghi nào · Dữ liệu lưu trữ SQL Server
          </div>
        </div>
        <div style="display: flex; gap: 10px;">
          <a href="${pageContext.request.contextPath}/activity-log" class="btn btn-outline" title="Làm mới">
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="23 4 23 10 17 10"/><polyline points="1 20 1 14 7 14"/><path d="M3.51 9a9 9 0 0114.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0020.49 15"/></svg>
            <span>Đồng bộ</span>
          </a>
          <button type="button" class="btn btn-outline" onclick="alert('Đang trích xuất nhật ký hoạt động hệ thống ra file Excel...')">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4M7 10l5 5 5-5M12 15V3"/></svg>
            <span>Xuất nhật ký</span>
          </button>
        </div>
      </div>

      <!-- Blue Audit Notice -->
      <div style="display: flex; justify-content: space-between; align-items: center; background: #eff6ff; border: 1px solid #bfdbfe; border-radius: 12px; padding: 14px 20px; margin-bottom: 24px; font-size: 0.825rem; color: #1e40af;">
        <div style="display: flex; align-items: center; gap: 10px;">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
          <span>Nhật ký chỉ đọc, không thể sửa hoặc xóa. Các thay đổi quyền, duyệt kho và bán hàng được ghi nhận để phục vụ truy vết.</span>
        </div>
        <span style="font-weight: 600; color: #2563eb;">Múi giờ GMT+7</span>
      </div>

      <!-- Main Log Card -->
      <div class="card">
        <!-- Filter Row -->
        <div style="padding: 16px 20px; display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--border); flex-wrap: wrap; gap: 12px;">
          <div style="display: flex; gap: 10px; align-items: center; flex: 1;">
            <div class="input-icon-wrapper" style="flex: 1; max-width: 320px;">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
              <input type="text" class="form-input" placeholder="Tìm người dùng, mã bản ghi..." oninput="filterLogs(this.value)">
            </div>
          </div>
        </div>

        <!-- Table (Truy vấn từ CSDL, Không hardcode) -->
        <div class="table-responsive">
          <table class="custom-table" id="logMasterTable">
            <thead>
              <tr>
                <th>Thời gian</th>
                <th>Người thực hiện</th>
                <th>Vai trò</th>
                <th>Hành động / Chi tiết</th>
                <th>Bản ghi</th>
                <th>Kết quả</th>
              </tr>
            </thead>
            <tbody>
              <c:choose>
                <c:when test="${not empty logs}">
                  <c:forEach items="${logs}" var="log">
                    <tr class="log-row" data-user="${log.userName}" data-code="${log.recordCode}">
                      <td>
                        <div style="font-weight: 700; color: #0f172a;">${log.formattedTime}</div>
                        <div style="font-size: 0.72rem; color: #64748b;">${log.formattedDate}</div>
                      </td>
                      <td style="font-weight: 600; color: #0f172a;">${log.userName}</td>
                      <td style="font-size: 0.8rem; color: #64748b;">${log.role}</td>
                      <td>
                        <div style="font-weight: 600; color: #0f172a;">${log.action}</div>
                        <div style="font-size: 0.75rem; color: #64748b;">${log.details}</div>
                      </td>
                      <td>
                        <div style="font-weight: 700; color: #2563eb;">${log.recordCode}</div>
                      </td>
                      <td>
                        <c:choose>
                          <c:when test="${log.result eq 'Đã từ chối'}">
                            <span class="badge badge-danger">${log.result}</span>
                          </c:when>
                          <c:when test="${log.result eq 'Đã gửi'}">
                            <span class="badge badge-primary">${log.result}</span>
                          </c:when>
                          <c:otherwise>
                            <span class="badge badge-success">${log.result}</span>
                          </c:otherwise>
                        </c:choose>
                      </td>
                    </tr>
                  </c:forEach>
                </c:when>
                <c:otherwise>
                  <tr>
                    <td colspan="6" style="text-align: center; padding: 40px; color: #94a3b8;">
                      Chưa có nhật ký hoạt động nào được ghi nhận.
                    </td>
                  </tr>
                </c:otherwise>
              </c:choose>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</div>

<script>
  function filterLogs(query) {
    var q = query.trim().toLowerCase();
    var rows = document.querySelectorAll('.log-row');
    rows.forEach(function(row) {
      var user = (row.getAttribute('data-user') || '').toLowerCase();
      var code = (row.getAttribute('data-code') || '').toLowerCase();
      if (user.indexOf(q) !== -1 || code.indexOf(q) !== -1) {
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
