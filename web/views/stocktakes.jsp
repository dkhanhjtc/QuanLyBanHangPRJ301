<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="userRole" value="${empty sessionScope.userRole ? (empty sessionScope.user.role ? (empty currentRole ? 'manager' : currentRole) : sessionScope.user.role.toLowerCase()) : sessionScope.userRole.toLowerCase()}" />
<c:set var="isStaff" value="${userRole eq 'staff'}" />
<c:set var="activeMenu" value="stocktakes" />
<c:set var="breadcrumbCurrent" value="${isStaff ? 'Kiểm kê của tôi' : 'Kiểm kê định kỳ'}" />

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${isStaff ? 'Kiểm kê của tôi' : 'Kiểm kê định kỳ'} · Kiotflow</title>
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
    .modal-window-80 {
      width: 80vw !important;
      max-width: 80vw !important;
      max-height: 85vh;
      overflow-y: auto;
      border-radius: 16px;
      box-shadow: 0 25px 50px -12px rgba(15, 23, 42, 0.25);
      background: #ffffff;
      padding: 28px 32px;
    }
  </style>
</head>
<body>

<div class="app-container">
  <jsp:include page="/common/sidebar.jsp">
    <jsp:param name="activeMenu" value="stocktakes" />
  </jsp:include>

  <div class="main-content">
    <jsp:include page="/common/header.jsp">
      <jsp:param name="breadcrumbCurrent" value="${isStaff ? 'Kiểm kê của tôi' : 'Kiểm kê định kỳ'}" />
    </jsp:include>

    <div class="page-body">
      <!-- Page Top Header -->
      <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 20px;">
        <div>
          <h1 style="font-size: 1.85rem; font-weight: 800; color: #0f172a; letter-spacing: -0.02em;">
            <c:choose>
              <c:when test="${isStaff}">Nhiệm vụ kiểm kê của tôi</c:when>
              <c:otherwise>Kiểm kê định kỳ</c:otherwise>
            </c:choose>
          </h1>
          <div style="font-size: 0.85rem; color: #64748b; margin-top: 4px;">
            <c:choose>
              <c:when test="${isStaff}">Danh sách các khu vực được quản lý phân công cho bạn đếm và kiểm tra tồn thực tế.</c:when>
              <c:otherwise>Phân công theo khu vực, theo dõi tiến độ và kiểm soát sai lệch tồn kho.</c:otherwise>
            </c:choose>
          </div>
        </div>
        <div style="display: flex; gap: 10px;">
          <a href="${pageContext.request.contextPath}/stocktakes" class="btn btn-outline" title="Làm mới danh sách">
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="23 4 23 10 17 10"/><polyline points="1 20 1 14 7 14"/><path d="M3.51 9a9 9 0 0114.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0020.49 15"/></svg>
            <span>Đồng bộ</span>
          </a>
        </div>
      </div>

      <!-- Tab Buttons Navigation -->
      <div class="sub-nav-tabs">
        <button type="button" class="sub-nav-tab active" id="tabBtnStocktakes">
          <span>${isStaff ? 'Kiểm kê được phân công' : 'Phân công kiểm kê'}</span>
          <span class="badge badge-primary" style="font-size: 0.7rem; padding: 2px 7px;">${stocktakes != null ? stocktakes.size() : 0}</span>
        </button>
        <c:if test="${!isStaff}">
          <button type="button" class="sub-nav-tab" id="tabBtnReconcile" onclick="openFirstReviewModal()">
            <span>Đối soát chênh lệch</span>
            <span class="badge badge-warning" style="font-size: 0.7rem; padding: 2px 7px;">${reviewCount != null ? reviewCount : 0}</span>
          </button>
        </c:if>
      </div>

      <!-- Main Layout: Form on Left (if Manager) or Full Width (if Staff) -->
      <div style="display: grid; grid-template-columns: ${isStaff ? '1fr' : '380px 1fr'}; gap: 24px; align-items: start;">
        
        <!-- LEFT COLUMN: TẠO PHÂN CÔNG (CHỈ HIỂN THỊ VỚI QUẢN LÝ / ADMIN) -->
        <c:if test="${!isStaff}">
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

            <form action="${pageContext.request.contextPath}/stocktakes" method="POST">
              <input type="hidden" name="action" value="create">

              <div class="form-group">
                <label class="form-label" for="staffSelect">Nhân viên thực hiện *</label>
                <select id="staffSelect" name="assignedStaffId" class="form-select" required>
                  <option value="3">Lê Lan Anh · Thu ngân</option>
                  <option value="4">Trần Quốc Bảo · Thu ngân</option>
                </select>
              </div>

              <div class="form-group">
                <label class="form-label" for="areaSelect">Khu vực / Nhóm hàng kiểm kê *</label>
                <select id="areaSelect" name="title" class="form-select" required>
                  <option value="Khu vực: Áo sơ mi">Khu vực: Áo sơ mi</option>
                  <option value="Khu vực: Áo thun & Polo">Khu vực: Áo thun &amp; Polo</option>
                  <option value="Khu vực: Quần Jeans & Quần Tây">Khu vực: Quần Jeans &amp; Quần Tây</option>
                  <option value="Khu vực: Váy đầm">Khu vực: Váy đầm</option>
                  <option value="Khu vực: Áo khoác">Khu vực: Áo khoác</option>
                  <option value="Toàn bộ kho thời trang">Toàn bộ kho thời trang</option>
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
                <input type="text" id="notesInput" name="note" class="form-input" placeholder="Đếm cả hàng trưng bày và kho lưu trữ.">
              </div>

              <button type="submit" class="btn btn-primary" style="width: 100%; padding: 12px; margin-top: 8px;">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="22" y1="2" x2="11" y2="13"/><polygon points="22 2 15 22 11 13 2 9 22 2"/></svg>
                <span>Giao kiểm kê</span>
              </button>
            </form>
          </div>
        </c:if>

        <!-- RIGHT/MAIN COLUMN: STATS & DANH SÁCH BẢNG -->
        <div>
          <!-- Top 3 Stat Cards -->
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

          <!-- Table Card -->
          <div class="card">
            <div class="card-header">
              <div class="card-title">
                ${isStaff ? 'Danh sách kiểm kê được phân công cho bạn' : 'Danh sách phân công kiểm kê'}
              </div>
            </div>

            <div class="table-responsive">
              <table class="custom-table">
                <thead>
                  <tr>
                    <th>Phiếu / Phạm vi</th>
                    <c:if test="${!isStaff}"><th>Nhân viên</th></c:if>
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
                          <c:if test="${!isStaff}">
                            <td style="font-weight: 500; color: #0f172a;">${st.assignedTo}</td>
                          </c:if>
                          <td>
                            <div>${st.formattedDate}</div>
                          </td>
                          <td>
                            <c:choose>
                              <c:when test="${st.status eq 'REVIEW' || st.status eq 'COUNTED'}">
                                <span class="badge badge-warning">${isStaff ? 'Chờ quản lý đối soát' : 'Chờ đối soát'}</span>
                              </c:when>
                              <c:when test="${st.status eq 'PENDING' || st.status eq 'ASSIGNED'}">
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
                              <%-- VỚI THU NGÂN (STAFF) --%>
                              <c:when test="${isStaff}">
                                <c:choose>
                                  <c:when test="${st.status eq 'PENDING' || st.status eq 'ASSIGNED'}">
                                    <button type="button" class="btn btn-primary" style="padding: 5px 12px; font-size: 0.825rem; font-weight: 700; display: inline-flex; align-items: center; gap: 4px;" onclick="openStocktakeModal('${st.code}', '${st.id}')">
                                      <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>
                                      <span>Nhập số đếm</span>
                                    </button>
                                  </c:when>
                                  <c:otherwise>
                                    <button type="button" class="btn btn-outline" style="padding: 4px 10px; font-size: 0.8rem;" onclick="openStocktakeModal('${st.code}', '${st.id}')">
                                      <span>Xem chi tiết</span>
                                    </button>
                                  </c:otherwise>
                                </c:choose>
                              </c:when>

                              <%-- VỚI QUẢN LÝ (MANAGER/ADMIN) --%>
                              <c:otherwise>
                                <c:choose>
                                  <c:when test="${st.status eq 'REVIEW' || st.status eq 'COUNTED'}">
                                    <button type="button" class="btn btn-primary" style="padding: 5px 12px; font-size: 0.825rem; font-weight: 700; display: inline-flex; align-items: center; gap: 4px;" onclick="openStocktakeModal('${st.code}', '${st.id}')">
                                      <span>Đối soát</span>
                                      <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="9 18 15 12 9 6"/></svg>
                                    </button>
                                  </c:when>
                                  <c:otherwise>
                                    <button type="button" class="btn btn-outline" style="padding: 4px 10px; font-size: 0.8rem;" onclick="openStocktakeModal('${st.code}', '${st.id}')">
                                      <span>Xem chi tiết</span>
                                    </button>
                                  </c:otherwise>
                                </c:choose>
                              </c:otherwise>
                            </c:choose>
                          </td>
                        </tr>
                      </c:forEach>
                    </c:when>
                    <c:otherwise>
                      <tr>
                        <td colspan="${isStaff ? 4 : 5}" style="text-align: center; padding: 40px; color: #94a3b8;">
                          <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" style="margin-bottom:8px;"><path d="M9 11l3 3L22 4"/><path d="M21 12v7a2 2 0 01-2 2H5a2 2 0 01-2-2V5a2 2 0 012-2h11"/></svg>
                          <div style="font-weight: 600;">Chưa có phân công kiểm kê nào</div>
                          <div style="font-size: 0.75rem;">
                            ${isStaff ? 'Hiện bạn chưa có nhiệm vụ kiểm kê nào được giao.' : 'Sử dụng biểu mẫu bên trái để giao nhiệm vụ kiểm kê cho nhân viên'}
                          </div>
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
            <span>Nhân viên chỉ kiểm đếm và nộp số thực tế cho nhiệm vụ được giao. Quản lý là người duy nhất có quyền đối soát và duyệt cân bằng kho.</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>

<!-- ==========================================================================
     MODALS: CÁC POPUP KIỂM KÊ & ĐỐI SOÁT (80% MÀN HÌNH THEO TỪNG PHIẾU)
     ========================================================================== -->
<c:forEach items="${stocktakes}" var="st">
  <div class="modal-backdrop stocktake-modal-backdrop" id="modal_${st.code}" style="display: none;">
    <div class="modal-window modal-window-80">
      <!-- Modal Header -->
      <div class="modal-header" style="padding-bottom: 16px; border-bottom: 1px solid var(--border); margin-bottom: 20px;">
        <div>
          <div style="display: flex; align-items: center; gap: 12px;">
            <h2 class="modal-title" style="font-size: 1.5rem; font-weight: 800; color: #0f172a; margin: 0;">
              <c:choose>
                <c:when test="${st.status eq 'REVIEW' || st.status eq 'COUNTED'}">
                  ${isStaff ? 'Chi tiết số đếm đã nộp' : 'Đối soát chênh lệch'} #${st.code}
                </c:when>
                <c:when test="${st.status eq 'PENDING' || st.status eq 'ASSIGNED'}">
                  ${isStaff ? 'Thực hiện kiểm đếm kho' : 'Nhiệm vụ kiểm kê'} #${st.code}
                </c:when>
                <c:when test="${st.status eq 'OVERDUE'}">Phiếu kiểm kê quá hạn #${st.code}</c:when>
                <c:otherwise>Kết quả đối soát #${st.code}</c:otherwise>
              </c:choose>
            </h2>
            <c:choose>
              <c:when test="${st.status eq 'REVIEW' || st.status eq 'COUNTED'}">
                <span class="badge badge-warning" style="font-size: 0.8rem; padding: 4px 10px;">${isStaff ? 'Chờ quản lý đối soát' : 'Chờ đối soát'}</span>
              </c:when>
              <c:when test="${st.status eq 'PENDING' || st.status eq 'ASSIGNED'}">
                <span class="badge badge-primary" style="font-size: 0.8rem; padding: 4px 10px;">Chờ thực hiện</span>
              </c:when>
              <c:when test="${st.status eq 'OVERDUE'}">
                <span class="badge badge-danger" style="font-size: 0.8rem; padding: 4px 10px;">Quá hạn</span>
              </c:when>
              <c:otherwise>
                <span class="badge badge-success" style="font-size: 0.8rem; padding: 4px 10px;">Đã đối soát</span>
              </c:otherwise>
            </c:choose>
          </div>
          <div class="modal-sub" style="font-size: 0.85rem; color: #64748b; margin-top: 4px;">
            ${st.title} · Nhân viên phụ trách: <strong>${st.assignedTo}</strong>
          </div>
        </div>
        <button type="button" class="modal-close" onclick="closeStocktakeModal('${st.code}')">&times;</button>
      </div>

      <div class="modal-body" style="padding: 0;">
        <!-- Info Meta Panel -->
        <div class="card" style="padding: 16px 20px; margin-bottom: 18px; background: #f8fafc; border: 1px solid #e2e8f0;">
          <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px;">
            <div>
              <div style="font-size: 0.72rem; color: #64748b; text-transform: uppercase; font-weight: 700; margin-bottom: 2px;">Thời điểm giao phiếu</div>
              <div style="font-size: 0.875rem; font-weight: 600; color: #0f172a;">${st.formattedDate}</div>
            </div>
            <div>
              <div style="font-size: 0.72rem; color: #64748b; text-transform: uppercase; font-weight: 700; margin-bottom: 2px;">Trạng thái phiếu</div>
              <div style="font-size: 0.875rem; font-weight: 700; color: #2563eb;">${st.status}</div>
            </div>
            <div>
              <div style="font-size: 0.72rem; color: #64748b; text-transform: uppercase; font-weight: 700; margin-bottom: 2px;">Nhân sự phân công</div>
              <div style="font-size: 0.875rem; font-weight: 600; color: #0f172a;">Nguyễn Minh Hà · Quản lý</div>
            </div>
          </div>
        </div>

        <c:choose>
          <%-- =========================================================
               TRƯỜNG HỢP 1: CHỜ THỰC HIỆN (PENDING / ASSIGNED)
               ========================================================= --%>
          <c:when test="${st.status eq 'PENDING' || st.status eq 'ASSIGNED' || st.status eq 'OVERDUE'}">
            <c:choose>
              <%-- NẾU LÀ THU NGÂN (STAFF): HIỂN THỊ FORM NHẬP SỐ ĐẾM THỰC TẾ --%>
              <c:when test="${isStaff}">
                <div style="background: #eff6ff; border: 1px solid #bfdbfe; border-radius: 12px; padding: 16px 20px; margin-bottom: 18px; font-size: 0.85rem; color: #1e40af;">
                  <strong>Hướng dẫn nhân viên:</strong> Vui lòng đếm số lượng thực tế tại quầy/kệ cho từng mặt hàng bên dưới, nhập vào ô <em>Số thực đếm</em> và nhấn <strong>Nộp số đếm cho Quản lý</strong>.
                </div>

                <form action="${pageContext.request.contextPath}/stocktakes" method="POST">
                  <input type="hidden" name="action" value="submitCount">
                  <input type="hidden" name="id" value="${st.id}">
                  <input type="hidden" name="code" value="${st.code}">

                  <div class="card" style="margin-bottom: 20px;">
                    <div class="table-responsive">
                      <table class="custom-table">
                        <thead>
                          <tr>
                            <th>SẢN PHẨM</th>
                            <th style="text-align: center; width: 140px;">SỐ THỰC ĐẾM *</th>
                            <th>GHI CHÚ / GIẢI TRÌNH</th>
                          </tr>
                        </thead>
                        <tbody>
                          <c:choose>
                            <c:when test="${not empty st.items}">
                              <c:forEach items="${st.items}" var="item">
                                <tr>
                                  <td>
                                    <input type="hidden" name="itemId" value="${item.id}">
                                    <div style="font-weight: 700; color: #0f172a;">${item.productName}</div>
                                    <div style="font-size: 0.72rem; color: #64748b;">Mã SP: ${item.productId} · ${item.spec}</div>
                                  </td>
                                  <td style="text-align: center;">
                                    <input type="number" name="actualQty" value="${item.actualStock}" min="0" class="form-input" style="text-align: center; font-weight: 700; font-size: 1rem; width: 100px; margin: 0 auto;" required>
                                  </td>
                                  <td>
                                    <input type="text" name="note" value="${item.note}" class="form-input" placeholder="Ví dụ: Đã đếm đủ tại sào trưng bày">
                                  </td>
                                </tr>
                              </c:forEach>
                            </c:when>
                            <c:otherwise>
                              <tr><td colspan="3" style="text-align: center; padding: 24px; color: #94a3b8;">Chưa có danh sách mặt hàng cần đếm cho phiếu này.</td></tr>
                            </c:otherwise>
                          </c:choose>
                        </tbody>
                      </table>
                    </div>
                  </div>

                  <div style="display: flex; justify-content: flex-end; gap: 12px;">
                    <button type="button" class="btn btn-outline" onclick="closeStocktakeModal('${st.code}')">Đóng</button>
                    <button type="submit" class="btn btn-primary" style="padding: 10px 20px; font-weight: 700;" onclick="return confirm('Xác nhận nộp số đếm của phiếu ${st.code} lên hệ thống để Quản lý đối soát?');">
                      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                      <span>Nộp số đếm cho Quản lý</span>
                    </button>
                  </div>
                </form>
              </c:when>

              <%-- NẾU LÀ QUẢN LÝ (MANAGER): THÔNG BÁO ĐANG CHỜ NHÂN VIÊN ĐẾM --%>
              <c:otherwise>
                <div style="background: #eff6ff; border: 1px solid #bfdbfe; border-radius: 12px; padding: 28px 24px; margin-bottom: 20px; text-align: center;">
                  <div style="width: 52px; height: 52px; border-radius: 50%; background: #dbeafe; color: #2563eb; display: inline-flex; align-items: center; justify-content: center; margin-bottom: 12px;">
                    <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                  </div>
                  <h3 style="font-size: 1.2rem; font-weight: 700; color: #1e3a8a; margin-bottom: 6px;">
                    Nhiệm vụ đang chờ nhân viên kiểm đếm tại quầy
                  </h3>
                  <p style="font-size: 0.875rem; color: #475569; max-width: 650px; margin: 0 auto 16px; line-height: 1.5;">
                    Nhiệm vụ kiểm kê nhóm <strong>${st.title}</strong> đã phân công cho nhân viên <strong>${st.assignedTo}</strong>.
                    Khi nhân viên nộp kết quả, bảng đối soát chênh lệch sẽ hiển thị tại đây để bạn duyệt cân bằng kho.
                  </p>
                  <div style="display: inline-flex; gap: 16px; font-size: 0.825rem; color: #1e40af; background: #ffffff; padding: 10px 20px; border-radius: 8px; border: 1px solid #bfdbfe;">
                    <span><strong>Mã phân công:</strong> #${st.code}</span>
                    <span>•</span>
                    <span><strong>Khu vực:</strong> ${st.title}</span>
                    <span>•</span>
                    <span><strong>Nhân viên:</strong> ${st.assignedTo}</span>
                  </div>
                </div>

                <div style="display: flex; justify-content: flex-end;">
                  <button type="button" class="btn btn-outline" onclick="closeStocktakeModal('${st.code}')">Đóng cửa sổ</button>
                </div>
              </c:otherwise>
            </c:choose>
          </c:when>

          <%-- =========================================================
               TRƯỜNG HỢP 2: ĐÃ ĐỐI SOÁT (COMPLETED / APPROVED)
               ========================================================= --%>
          <c:when test="${st.status eq 'COMPLETED' || st.status eq 'APPROVED'}">
            <div style="background: #f0fdf4; border: 1px solid #bbf7d0; border-radius: 12px; padding: 16px 20px; margin-bottom: 20px; display: flex; align-items: center; gap: 14px;">
              <div style="width: 38px; height: 38px; border-radius: 50%; background: #dcfce7; color: #16a34a; display: flex; align-items: center; justify-content: center; flex-shrink: 0;">
                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
              </div>
              <div>
                <div style="color: #15803d; font-weight: 700; font-size: 0.95rem;">✓ Đã hoàn tất đối soát và cân bằng tồn kho</div>
                <div style="color: #166534; font-size: 0.8rem; margin-top: 2px;">Số lượng tồn kho trong SQL Server đã được cập nhật chính xác theo kết quả kiểm đếm thực tế của đợt này.</div>
              </div>
            </div>

            <div class="card" style="margin-bottom: 20px;">
              <div class="card-header" style="padding: 14px 20px;">
                <div class="card-title" style="font-size: 1rem;">Kết quả kiểm kê đã ghi nhận</div>
              </div>
              <div class="table-responsive">
                <table class="custom-table">
                  <thead>
                    <tr>
                      <th>SẢN PHẨM</th>
                      <th style="text-align: center;">HỆ THỐNG</th>
                      <th style="text-align: center;">THỰC ĐẾM</th>
                      <th style="text-align: center;">CHÊNH LỆCH</th>
                      <th style="text-align: right;">GIÁ TRỊ VỐN CHÊNH</th>
                      <th>GHI CHÚ KIỂM KÊ</th>
                    </tr>
                  </thead>
                  <tbody>
                    <c:choose>
                      <c:when test="${not empty st.items}">
                        <c:forEach items="${st.items}" var="item">
                          <tr>
                            <td>
                              <div style="font-weight: 700; color: #0f172a;">${item.productName}</div>
                              <div style="font-size: 0.72rem; color: #64748b;">Mã SP: ${item.productId} · ${item.spec}</div>
                            </td>
                            <td style="font-weight: 600; text-align: center;">${item.systemStock}</td>
                            <td style="font-weight: 600; text-align: center;">${item.actualStock}</td>
                            <td style="text-align: center;">
                              <c:choose>
                                <c:when test="${item.variance < 0}"><span class="badge badge-danger">${item.variance}</span></c:when>
                                <c:when test="${item.variance > 0}"><span class="badge badge-primary">+${item.variance}</span></c:when>
                                <c:otherwise><span class="badge badge-gray">0</span></c:otherwise>
                              </c:choose>
                            </td>
                            <td style="font-weight: 600; text-align: right; ${item.variance < 0 ? 'color: #ef4444;' : (item.variance > 0 ? 'color: #2563eb;' : 'color: #64748b;')}">
                              <fmt:formatNumber value="${item.varianceCost}" pattern="#,###"/> đ
                            </td>
                            <td><div style="font-size: 0.825rem; color: #475569;">${not empty item.note ? item.note : 'Khớp số lượng hệ thống.'}</div></td>
                          </tr>
                        </c:forEach>
                      </c:when>
                      <c:otherwise>
                        <tr><td colspan="6" style="text-align: center; padding: 24px; color: #94a3b8;">Khớp hoàn toàn số lượng hệ thống.</td></tr>
                      </c:otherwise>
                    </c:choose>
                  </tbody>
                </table>
              </div>
            </div>

            <div style="display: flex; justify-content: flex-end;">
              <button type="button" class="btn btn-outline" onclick="closeStocktakeModal('${st.code}')">Đóng cửa sổ</button>
            </div>
          </c:when>

          <%-- =========================================================
               TRƯỜNG HỢP 3: CHỜ ĐỐI SOÁT (REVIEW / COUNTED)
               ========================================================= --%>
          <c:otherwise>
            <div style="display: flex; align-items: flex-start; gap: 12px; background: #fffbeb; border: 1px solid #fde68a; border-radius: 10px; padding: 12px 16px; margin-bottom: 18px; font-size: 0.825rem; color: #b45309;">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="flex-shrink:0; margin-top:1px;"><path d="M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
              <div>
                <c:choose>
                  <c:when test="${isStaff}">
                    <strong>Thông báo:</strong> Bạn đã nộp số đếm cho phiếu này. Phiếu đang ở trạng thái chờ Quản lý đối soát và phê duyệt cập nhật tồn kho.
                  </c:when>
                  <c:otherwise>
                    <strong>Lưu ý:</strong> Chưa cập nhật tồn kho. Khi nhấn Duyệt: số lượng tồn trong CSDL SQL Server sẽ được cập nhật chính xác theo số thực đếm của nhân viên.
                  </c:otherwise>
                </c:choose>
              </div>
            </div>

            <div class="card" style="margin-bottom: 20px;">
              <div class="card-header" style="padding: 14px 20px;">
                <div>
                  <div class="card-title" style="font-size: 1rem;">Số đếm &amp; chênh lệch thực tế</div>
                  <div class="card-subtitle">Chênh lệch = Thực đếm – Hệ thống</div>
                </div>
              </div>
              <div class="table-responsive">
                <table class="custom-table">
                  <thead>
                    <tr>
                      <th>SẢN PHẨM</th>
                      <th style="text-align: center;">HỆ THỐNG</th>
                      <th style="text-align: center;">THỰC ĐẾM</th>
                      <th style="text-align: center;">CHÊNH LỆCH</th>
                      <th style="text-align: right;">GIÁ TRỊ VỐN CHÊNH</th>
                      <th>GIẢI TRÌNH CỦA NHÂN VIÊN</th>
                    </tr>
                  </thead>
                  <tbody>
                    <c:choose>
                      <c:when test="${not empty st.items}">
                        <c:forEach items="${st.items}" var="item">
                          <tr>
                            <td>
                              <div style="font-weight: 700; color: #0f172a;">${item.productName}</div>
                              <div style="font-size: 0.72rem; color: #64748b;">Mã SP: ${item.productId} · ${item.spec}</div>
                            </td>
                            <td style="font-weight: 600; text-align: center;">${item.systemStock}</td>
                            <td style="font-weight: 600; text-align: center;">${item.actualStock}</td>
                            <td style="text-align: center;">
                              <c:choose>
                                <c:when test="${item.variance < 0}"><span class="badge badge-danger" style="font-size: 0.8rem; padding: 4px 8px;">${item.variance}</span></c:when>
                                <c:when test="${item.variance > 0}"><span class="badge badge-primary" style="font-size: 0.8rem; padding: 4px 8px;">+${item.variance}</span></c:when>
                                <c:otherwise><span class="badge badge-gray" style="font-size: 0.8rem; padding: 4px 8px;">0</span></c:otherwise>
                              </c:choose>
                            </td>
                            <td style="font-weight: 600; text-align: right; ${item.variance < 0 ? 'color: #ef4444;' : (item.variance > 0 ? 'color: #2563eb;' : 'color: #64748b;')}">
                              <fmt:formatNumber value="${item.varianceCost}" pattern="#,###"/> đ
                            </td>
                            <td>
                              <div style="font-size: 0.825rem; color: #334155;">
                                <c:out value="${item.note != null && !item.note.isEmpty() ? item.note : 'Khớp số lượng hệ thống.'}" />
                              </div>
                            </td>
                          </tr>
                        </c:forEach>
                      </c:when>
                      <c:otherwise>
                        <tr><td colspan="6" style="text-align: center; padding: 30px; color: #94a3b8;">Chưa có mặt hàng nào được ghi nhận trong phiếu kiểm kê này.</td></tr>
                      </c:otherwise>
                    </c:choose>
                  </tbody>
                </table>
              </div>
            </div>

            <!-- NẾU LÀ QUẢN LÝ: FORM DUYỆT ĐỐI SOÁT CÂN BẰNG TỒN KHO -->
            <c:if test="${!isStaff}">
              <form action="${pageContext.request.contextPath}/stocktakes" method="POST">
                <input type="hidden" name="action" value="approve">
                <input type="hidden" name="id" value="${st.id}">
                <input type="hidden" name="code" value="${st.code}">

                <div class="form-group" style="margin-bottom: 10px;">
                  <label class="form-label" for="reconcileNotes_${st.code}">Ghi chú đối soát của quản lý</label>
                  <input type="text" id="reconcileNotes_${st.code}" name="notes" class="form-input" value="Đã kiểm tra lại thực tế và xác nhận điều chỉnh tồn kho.">
                </div>
                <div style="font-size: 0.75rem; color: #94a3b8; margin-bottom: 18px;">
                  Hành động duyệt sẽ cập nhật số lượng tồn kho trong SQL Server và lưu vào Nhật ký hoạt động.
                </div>

                <div style="display: flex; justify-content: flex-end; gap: 12px;">
                  <button type="button" class="btn btn-outline" onclick="closeStocktakeModal('${st.code}')">
                    <span>Hủy bỏ</span>
                  </button>
                  <button type="submit" class="btn btn-primary" onclick="return confirm('Xác nhận DUYỆT và cập nhật cân bằng tồn kho thực tế cho phiếu ${st.code}?')">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                    <span>Duyệt điều chỉnh tồn kho</span>
                  </button>
                </div>
              </form>
            </c:if>

            <!-- NẾU LÀ THU NGÂN: CHỈ CÓ NÚT ĐÓNG (KHÔNG ĐƯỢC DUYỆT) -->
            <c:if test="${isStaff}">
              <div style="display: flex; justify-content: flex-end;">
                <button type="button" class="btn btn-outline" onclick="closeStocktakeModal('${st.code}')">Đóng cửa sổ</button>
              </div>
            </c:if>
          </c:otherwise>
        </c:choose>
      </div>
    </div>
  </div>
</c:forEach>

<script>
  function openStocktakeModal(code, id) {
    document.querySelectorAll('.stocktake-modal-backdrop').forEach(m => m.style.display = 'none');
    const m = document.getElementById('modal_' + code);
    if (m) {
      m.style.display = 'flex';
      const url = new URL(window.location.href);
      url.searchParams.set('code', code);
      if (id) url.searchParams.set('id', id);
      window.history.pushState({}, '', url.toString());
    }
  }

  function closeStocktakeModal(code) {
    const m = document.getElementById('modal_' + code);
    if (m) m.style.display = 'none';
    const url = new URL(window.location.href);
    url.searchParams.delete('code');
    url.searchParams.delete('id');
    window.history.pushState({}, '', url.toString());
  }

  function openFirstReviewModal() {
    <c:forEach items="${stocktakes}" var="st">
      <c:if test="${st.status eq 'REVIEW' || st.status eq 'COUNTED'}">
        openStocktakeModal('${st.code}', '${st.id}');
        return;
      </c:if>
    </c:forEach>
    alert('Hiện không có phiếu kiểm kê nào đang chờ đối soát!');
  }

  document.addEventListener('DOMContentLoaded', function() {
    const params = new URLSearchParams(window.location.search);
    const code = params.get('code');
    if (code) {
      const modal = document.getElementById('modal_' + code);
      if (modal) modal.style.display = 'flex';
    }
  });
</script>

<jsp:include page="/common/footer.jsp" />
</body>
</html>
