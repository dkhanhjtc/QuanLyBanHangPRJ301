<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="activeMenu" value="stocktakes" />
<c:set var="breadcrumbCurrent" value="Kiểm kê" />

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Kiểm kê định kỳ · Kiotflow</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
  <style>
    .sub-nav-tabs {
      display: flex;
      gap: 28px;
      border-bottom: 1px solid var(--border);
      margin-bottom: 24px;
    }
    .sub-nav-tab {
      padding: 10px 4px 14px;
      font-size: 0.95rem;
      font-weight: 600;
      color: var(--text-muted);
      border-bottom: 2px solid transparent;
      cursor: pointer;
      display: flex;
      align-items: center;
      gap: 6px;
      background: none;
      border-top: none;
      border-left: none;
      border-right: none;
      transition: all 0.15s ease;
    }
    .sub-nav-tab:hover {
      color: var(--text-main);
    }
    .sub-nav-tab.active {
      color: var(--primary);
      border-bottom-color: var(--primary);
    }
  </style>
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
          <h1 style="font-size: 1.85rem; font-weight: 800; color: #0f172a; letter-spacing: -0.02em;">Kiểm kê định kỳ</h1>
          <div style="font-size: 0.85rem; color: #64748b; margin-top: 4px;">
            Phân công theo khu vực, theo dõi tiến độ và kiểm soát sai lệch tồn kho.
          </div>
        </div>
        <div style="display: flex; gap: 10px;">
          <a href="${pageContext.request.contextPath}/stocktakes" class="btn btn-outline" title="Làm mới danh sách">
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="23 4 23 10 17 10"/><polyline points="1 20 1 14 7 14"/><path d="M3.51 9a9 9 0 0114.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0020.49 15"/></svg>
            <span>Đồng bộ</span>
          </a>
          <button type="button" class="btn btn-outline" onclick="alert('Đang xuất kế hoạch kiểm kê định kỳ...')">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4M7 10l5 5 5-5M12 15V3"/></svg>
            <span>Xuất kế hoạch</span>
          </button>
        </div>
      </div>

      <!-- Tab Buttons Navigation -->
      <div class="sub-nav-tabs">
        <button type="button" class="sub-nav-tab active">
          <span>Phân công kiểm kê</span>
        </button>
        <a href="${pageContext.request.contextPath}/stocktake-detail?code=KK-101" class="sub-nav-tab">
          <span>Đối soát chênh lệch</span>
          <span class="badge badge-warning" style="font-size: 0.7rem; padding: 2px 7px;">${reviewCount != null ? reviewCount : 0}</span>
        </a>
      </div>

      <!-- Main Layout: Form on Left, Stats & Table on Right -->
      <div style="display: grid; grid-template-columns: 380px 1fr; gap: 24px; align-items: start;">
        <!-- LEFT COLUMN: TẠO PHÂN CÔNG FORM -->
        <div class="card" style="padding: 24px;">
          <div style="display: flex; align-items: center; gap: 8px; margin-bottom: 6px;">
            <div style="width: 28px; height: 28px; border-radius: 6px; background: #eff6ff; color: #2563eb; display: flex; align-items: center; justify-content: center;">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="12" y1="9" x2="12" y2="15"/><line x1="9" y1="12" x2="15" y2="12"/></svg>
            </div>
            <h2 style="font-size: 1.15rem; font-weight: 700; color: #0f172a;">Tạo phân công</h2>
          </div>
          <p style="font-size: 0.78rem; color: #64748b; margin-bottom: 20px;">
            Giao nhiệm vụ kiểm kê cho nhân viên ca làm việc.
          </p>

          <form action="${pageContext.request.contextPath}/stocktakes" method="POST" onsubmit="alert('Đã tạo phân công kiểm kê mới!');">
            <div class="form-group">
              <label class="form-label" for="staffSelect">Nhân viên thực hiện *</label>
              <select id="staffSelect" name="assignedTo" class="form-select" required>
                <option value="Lê Lan Anh">Lê Lan Anh · Thu ngân</option>
                <option value="Trần Quốc Bảo">Trần Quốc Bảo · Thu ngân</option>
              </select>
            </div>

            <div class="form-group">
              <label class="form-label" for="areaSelect">Khu vực kiểm kê *</label>
              <select id="areaSelect" name="title" class="form-select" required>
                <option value="Kệ cà phê & trà">Kệ cà phê &amp; trà</option>
                <option value="Kệ đồ uống">Kệ đồ uống</option>
                <option value="Kệ thực phẩm">Kệ thực phẩm</option>
                <option value="Toàn bộ kho">Toàn bộ kho hàng</option>
              </select>
            </div>

            <div class="form-group">
              <label class="form-label">Chu kỳ</label>
              <select class="form-select">
                <option value="weekly">Hàng tuần · Cuối tuần</option>
                <option value="monthly">Hàng tháng · Ngày cuối tháng</option>
                <option value="adhoc">Đột xuất</option>
              </select>
            </div>

            <div class="form-group">
              <label class="form-label" for="notesInput">Ghi chú cho nhân viên</label>
              <input type="text" id="notesInput" class="form-input" placeholder="Đếm cả hàng trưng bày và kho lưu trữ.">
            </div>

            <button type="submit" class="btn btn-primary" style="width: 100%; padding: 12px; margin-top: 8px;">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="22" y1="2" x2="11" y2="13"/><polygon points="22 2 15 22 11 13 2 9 22 2"/></svg>
              <span>Giao kiểm kê</span>
            </button>
          </form>
        </div>

        <!-- RIGHT COLUMN: STATS & DANH SÁCH PHÂN CÔNG TABLE -->
        <div>
          <!-- Top 3 Stat Cards (Tính toán động) -->
          <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; margin-bottom: 20px;">
            <div class="card" style="padding: 18px 24px;">
              <div style="font-size: 0.75rem; color: #64748b; margin-bottom: 4px;">Đang mở</div>
              <div style="font-size: 2rem; font-weight: 800; color: #2563eb;">${openCount != null ? openCount : 0}</div>
            </div>
            <div class="card" style="padding: 18px 24px;">
              <div style="font-size: 0.75rem; color: #64748b; margin-bottom: 4px;">Chờ đối soát</div>
              <div style="font-size: 2rem; font-weight: 800; color: #d97706;">${reviewCount != null ? reviewCount : 0}</div>
            </div>
            <div class="card" style="padding: 18px 24px;">
              <div style="font-size: 0.75rem; color: #64748b; margin-bottom: 4px;">Quá hạn</div>
              <div style="font-size: 2rem; font-weight: 800; color: #dc2626;">${overdueCount != null ? overdueCount : 0}</div>
            </div>
          </div>

          <!-- Table Card (Truy vấn từ CSDL, Không hardcode) -->
          <div class="card">
            <div class="card-header">
              <div class="card-title">Danh sách phân công kiểm kê</div>
            </div>

            <div class="table-responsive">
              <table class="custom-table">
                <thead>
                  <tr>
                    <th>Phiếu / Phạm vi</th>
                    <th>Nhân viên</th>
                    <th>Thời gian</th>
                    <th>Trạng thái</th>
                    <th style="text-align: right;">Thao tác</th>
                  </tr>
                </thead>
                <tbody>
                  <c:choose>
                    <c:when test="${not empty stocktakes}">
                      <c:forEach items="${stocktakes}" var="st">
                        <tr>
                          <td>
                            <div style="font-weight: 700; color: #2563eb;">${st.code} · ${st.title}</div>
                          </td>
                          <td style="font-weight: 500; color: #0f172a;">${st.assignedTo}</td>
                          <td>
                            <div>${st.formattedDate}</div>
                          </td>
                          <td>
                            <c:choose>
                              <c:when test="${st.status eq 'REVIEW'}">
                                <span class="badge badge-warning">Chờ đối soát</span>
                              </c:when>
                              <c:when test="${st.status eq 'PENDING'}">
                                <span class="badge badge-primary">Chờ thực hiện</span>
                              </c:when>
                              <c:when test="${st.status eq 'OVERDUE'}">
                                <span class="badge badge-danger">Quá hạn</span>
                              </c:when>
                              <c:otherwise>
                                <span class="badge badge-success">Đã đối soát</span>
                              </c:otherwise>
                            </c:choose>
                          </td>
                          <td style="text-align: right;">
                            <c:choose>
                              <c:when test="${st.status eq 'REVIEW'}">
                                <a href="${pageContext.request.contextPath}/stocktake-detail?code=${st.code}" style="font-weight: 700; font-size: 0.85rem; color: #2563eb; display: inline-flex; align-items: center; gap: 4px;">
                                  <span>Đối soát</span>
                                  <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg>
                                </a>
                              </c:when>
                              <c:otherwise>
                                <a href="${pageContext.request.contextPath}/stocktake-detail?code=${st.code}" style="font-weight: 600; font-size: 0.825rem; color: #64748b;">Xem chi tiết</a>
                              </c:otherwise>
                            </c:choose>
                          </td>
                        </tr>
                      </c:forEach>
                    </c:when>
                    <c:otherwise>
                      <tr>
                        <td colspan="5" style="text-align: center; padding: 40px; color: #94a3b8;">
                          <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" style="margin-bottom:8px;"><path d="M9 11l3 3L22 4"/><path d="M21 12v7a2 2 0 01-2 2H5a2 2 0 01-2-2V5a2 2 0 012-2h11"/></svg>
                          <div style="font-weight: 600;">Chưa có phân công kiểm kê nào</div>
                          <div style="font-size: 0.75rem;">Sử dụng biểu mẫu bên trái để giao nhiệm vụ kiểm kê cho nhân viên</div>
                        </td>
                      </tr>
                    </c:otherwise>
                  </c:choose>
                </tbody>
              </table>
            </div>

            <!-- Pagination Bar -->
            <div style="display: flex; justify-content: space-between; align-items: center; padding: 14px 20px; border-top: 1px solid var(--border); font-size: 0.8rem; color: #64748b;">
              <div>Hiển thị ${stocktakes != null ? stocktakes.size() : 0} phân công kiểm kê</div>
            </div>
          </div>

          <!-- Bottom Notice -->
          <div style="display: flex; align-items: center; gap: 8px; background: #eff6ff; border: 1px solid #bfdbfe; border-radius: 10px; padding: 12px 16px; margin-top: 16px; font-size: 0.8rem; color: #1e40af;">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
            <span>Nhân viên chỉ nhập số đếm cho nhiệm vụ được giao. Tồn kho chỉ thay đổi sau khi Quản lý duyệt chênh lệch.</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>

<jsp:include page="/common/footer.jsp" />
</body>
</html>
