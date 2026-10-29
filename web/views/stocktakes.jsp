<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="activeMenu" value="stocktakes" />
<c:set var="currentRole" value="manager" />
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
        <button type="button" class="btn btn-outline" onclick="alert('Đang xuất kế hoạch kiểm kê định kỳ...')">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4M7 10l5 5 5-5M12 15V3"/></svg>
          <span>Xuất kế hoạch</span>
        </button>
      </div>

      <!-- Tab Buttons Navigation -->
      <div class="sub-nav-tabs">
        <button type="button" class="sub-nav-tab active">
          <span>Phân công kiểm kê</span>
        </button>
        <a href="${pageContext.request.contextPath}/views/stocktake_detail.jsp" class="sub-nav-tab">
          <span>Đối soát chênh lệch</span>
          <span class="badge badge-warning" style="font-size: 0.7rem; padding: 2px 7px;">1</span>
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
            Giao nhiệm vụ kiểm kê cuối tuần cho nhân viên.
          </p>

          <form action="${pageContext.request.contextPath}/stocktakes" method="POST" onsubmit="event.preventDefault(); alert('Đã giao nhiệm vụ kiểm kê thành công!');">
            <div class="form-group">
              <label class="form-label">Nhân viên thực hiện *</label>
              <select class="form-select" required>
                <option value="NV-002">Lê Lan Anh · NV-002</option>
                <option value="NV-003">Trần Quốc Bảo · NV-003</option>
              </select>
            </div>

            <div class="form-group">
              <label class="form-label">Khu vực kiểm kê *</label>
              <select class="form-select" required>
                <option value="all">Toàn cửa hàng Nguyễn Trãi</option>
                <option value="drinks">Kệ đồ uống</option>
                <option value="coffee">Kệ cà phê &amp; trà</option>
                <option value="food">Kệ thực phẩm</option>
              </select>
            </div>

            <div class="form-group">
              <label class="form-label">Phạm vi sản phẩm *</label>
              <div class="input-icon-wrapper">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><circle cx="12" cy="12" r="10"/><path d="M12 6v6l4 2"/></svg>
                <input type="text" class="form-input" value="Tất cả 8 sản phẩm" readonly style="background: #f8fafc; font-weight: 600;">
              </div>
              <div style="font-size: 0.72rem; color: #94a3b8; margin-top: 4px;">Bao gồm 3 nhóm hàng · 163 đơn vị hiện tại</div>
            </div>

            <div class="form-group">
              <label class="form-label">Chu kỳ</label>
              <select class="form-select">
                <option value="weekly">Hàng tuần · Thứ Bảy</option>
                <option value="monthly">Hàng tháng · Ngày cuối tháng</option>
                <option value="adhoc">Đột xuất</option>
              </select>
            </div>

            <div class="form-group">
              <label class="form-label">Thời gian bắt đầu *</label>
              <div style="display: grid; grid-template-columns: 1fr 100px; gap: 8px;">
                <input type="text" class="form-input" value="31/10/2026">
                <input type="text" class="form-input" value="17:00">
              </div>
            </div>

            <div class="form-group">
              <label class="form-label">Hạn hoàn thành *</label>
              <div style="display: grid; grid-template-columns: 1fr 100px; gap: 8px;">
                <input type="text" class="form-input" value="31/10/2026">
                <input type="text" class="form-input" value="19:00">
              </div>
            </div>

            <div class="form-group">
              <label class="form-label">Ghi chú cho nhân viên</label>
              <input type="text" class="form-input" value="Đếm cả hàng trưng bày và kho sau.">
            </div>

            <button type="submit" class="btn btn-primary" style="width: 100%; padding: 12px; margin-top: 8px;">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="22" y1="2" x2="11" y2="13"/><polygon points="22 2 15 22 11 13 2 9 22 2"/></svg>
              <span>Giao kiểm kê</span>
            </button>
          </form>
        </div>

        <!-- RIGHT COLUMN: STATS & DANH SÁCH PHÂN CÔNG TABLE -->
        <div>
          <!-- Top 3 Stat Cards -->
          <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; margin-bottom: 20px;">
            <div class="card" style="padding: 18px 24px;">
              <div style="font-size: 0.75rem; color: #64748b; margin-bottom: 4px;">Đang mở</div>
              <div style="font-size: 2rem; font-weight: 800; color: #2563eb;">3</div>
            </div>
            <div class="card" style="padding: 18px 24px;">
              <div style="font-size: 0.75rem; color: #64748b; margin-bottom: 4px;">Chờ đối soát</div>
              <div style="font-size: 2rem; font-weight: 800; color: #d97706;">1</div>
            </div>
            <div class="card" style="padding: 18px 24px;">
              <div style="font-size: 0.75rem; color: #64748b; margin-bottom: 4px;">Quá hạn</div>
              <div style="font-size: 2rem; font-weight: 800; color: #dc2626;">1</div>
            </div>
          </div>

          <!-- Table Card -->
          <div class="card">
            <div class="card-header">
              <div class="card-title">Danh sách phân công</div>
              <select class="form-select" style="width: auto; font-size: 0.8rem; padding: 6px 12px;">
                <option value="all">Tất cả trạng thái</option>
                <option value="pending">Chờ thực hiện</option>
                <option value="review">Chờ đối soát</option>
                <option value="overdue">Quá hạn</option>
                <option value="completed">Đã đối soát</option>
              </select>
            </div>

            <div class="table-responsive">
              <table class="custom-table">
                <thead>
                  <tr>
                    <th>Phiếu / Phạm vi</th>
                    <th>Nhân viên</th>
                    <th>Lịch / Hạn</th>
                    <th>Trạng thái</th>
                    <th style="text-align: right;">Thao tác</th>
                  </tr>
                </thead>
                <tbody>
                  <!-- Row 1: KK-102 -->
                  <tr>
                    <td>
                      <div style="font-weight: 700; color: #2563eb;">KK-102 · Kệ đồ uống</div>
                      <div style="font-size: 0.72rem; color: #64748b;">MK01, WA01 · 2 sản phẩm</div>
                    </td>
                    <td style="font-weight: 500; color: #0f172a;">Lê Lan Anh</td>
                    <td>
                      <div>27/10 · 11:00</div>
                      <div style="font-size: 0.72rem; color: #64748b;">Hạn 12:00</div>
                    </td>
                    <td><span class="badge badge-primary">Chờ thực hiện</span></td>
                    <td style="text-align: right;">
                      <a href="javascript:void(0)" onclick="alert('Xem chi tiết nhiệm vụ KK-102')" style="font-weight: 600; font-size: 0.825rem;">Chi tiết</a>
                    </td>
                  </tr>

                  <!-- Row 2: KK-101 (Chờ đối soát) -->
                  <tr>
                    <td>
                      <div style="font-weight: 700; color: #2563eb;">KK-101 · Kệ cà phê &amp; trà</div>
                      <div style="font-size: 0.72rem; color: #64748b;">CF01, TE01, CC01 · 3 SP</div>
                    </td>
                    <td style="font-weight: 500; color: #0f172a;">Trần Quốc Bảo</td>
                    <td>
                      <div>27/10 · 10:25</div>
                      <div style="font-size: 0.72rem; color: #64748b;">Hạn 10:30</div>
                    </td>
                    <td><span class="badge badge-warning">Chờ đối soát</span></td>
                    <td style="text-align: right;">
                      <a href="${pageContext.request.contextPath}/views/stocktake_detail.jsp" style="font-weight: 700; font-size: 0.85rem; color: #2563eb; display: inline-flex; align-items: center; gap: 4px;">
                        <span>Đối soát</span>
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg>
                      </a>
                    </td>
                  </tr>

                  <!-- Row 3: KK-099 (Quá hạn) -->
                  <tr>
                    <td>
                      <div style="font-weight: 700; color: #2563eb;">KK-099 · Kệ thực phẩm</div>
                      <div style="font-size: 0.72rem; color: #64748b;">GR01, HN01, CK01 · 3 SP</div>
                    </td>
                    <td style="font-weight: 500; color: #0f172a;">Lê Lan Anh</td>
                    <td>
                      <div>26/10 · 17:00</div>
                      <div style="font-size: 0.72rem; color: #dc2626;">Hạn 18:00</div>
                    </td>
                    <td><span class="badge badge-danger">Quá hạn</span></td>
                    <td style="text-align: right;">
                      <a href="javascript:void(0)" onclick="alert('Đã gửi thông báo nhắc việc đến nhân viên Lê Lan Anh!')" style="font-weight: 600; font-size: 0.825rem; color: #d97706;">Nhắc việc</a>
                    </td>
                  </tr>

                  <!-- Row 4: KK-098 (Đã đối soát) -->
                  <tr>
                    <td>
                      <div style="font-weight: 700; color: #2563eb;">KK-098 · Kệ nước khoáng</div>
                      <div style="font-size: 0.72rem; color: #64748b;">WA01 · 1 sản phẩm</div>
                    </td>
                    <td style="font-weight: 500; color: #0f172a;">Trần Quốc Bảo</td>
                    <td>
                      <div>26/10 · 16:00</div>
                      <div style="font-size: 0.72rem; color: #64748b;">Hạn 17:30</div>
                    </td>
                    <td><span class="badge badge-success">Đã đối soát</span></td>
                    <td style="text-align: right;">
                      <a href="javascript:void(0)" onclick="alert('Xem lại phiếu đã đối soát KK-098')" style="font-weight: 600; font-size: 0.825rem; color: #64748b;">Xem phiếu</a>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>

            <!-- Pagination Bar -->
            <div style="display: flex; justify-content: space-between; align-items: center; padding: 14px 20px; border-top: 1px solid var(--border); font-size: 0.8rem; color: #64748b;">
              <div>Hiển thị 1–4 trong 4 phân công</div>
              <div style="display: flex; gap: 6px;">
                <button type="button" class="btn btn-outline" style="padding: 4px 8px; font-size: 0.75rem;">&lt;</button>
                <button type="button" class="btn btn-primary" style="padding: 4px 10px; font-size: 0.75rem;">1</button>
                <button type="button" class="btn btn-outline" style="padding: 4px 8px; font-size: 0.75rem;">&gt;</button>
              </div>
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

