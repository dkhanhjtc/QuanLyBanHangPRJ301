<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="activeMenu" value="dashboard" />
<c:set var="currentRole" value="manager" />
<c:set var="breadcrumbCurrent" value="Tổng quan" />

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Tổng quan vận hành (Dashboard) · Kiotflow</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
  <!-- Chart.js CDN for revenue visualization -->
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>

<div class="app-container">
  <!-- Dynamic Sidebar -->
  <jsp:include page="/common/sidebar.jsp" />

  <!-- Main Work Area -->
  <div class="main-content">
    <jsp:include page="/common/header.jsp" />

    <div class="page-body">
      <!-- Page Top Header -->
      <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 24px;">
        <div>
          <h1 style="font-size: 1.85rem; font-weight: 800; color: #0f172a; letter-spacing: -0.02em;">Tổng quan vận hành</h1>
          <div style="font-size: 0.85rem; color: #64748b; margin-top: 4px;">
            Cửa hàng An Nhiên · Cập nhật lúc 10:30, 27/10/2026 · Dữ liệu minh họa
          </div>
        </div>
        <div style="display: flex; gap: 10px;">
          <button type="button" class="btn btn-outline" style="font-size: 0.85rem;">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
            <span>21–27/10/2026</span>
          </button>
          <button type="button" class="btn btn-outline" onclick="alert('Đang trích xuất báo cáo Excel tổng quan tuần...')">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4M7 10l5 5 5-5M12 15V3"/></svg>
            <span>Xuất báo cáo</span>
          </button>
        </div>
      </div>

      <!-- KPI DARK METRIC CARDS (Exact Replica from Mockup) -->
      <div class="kpi-dark-container">
        <!-- KPI 1: Estimated Weekly Revenue -->
        <div class="kpi-dark-item">
          <div class="kpi-label-row">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/></svg>
            <span>Ước tính doanh thu</span>
          </div>
          <div class="kpi-value-row">
            11.054.000 <span style="text-decoration: underline;">đ</span>
          </div>
          <div class="kpi-sub-row positive">
            +8,2% so với 7 ngày trước
          </div>
        </div>

        <!-- KPI 2: Inventory Capital Value Sum(Stock * Cost) -->
        <div class="kpi-dark-item">
          <div class="kpi-label-row">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 16V8a2 2 0 00-1-1.73l-7-4a2 2 0 00-2 0l-7 4A2 2 0 003 8v8a2 2 0 001 1.73l7 4a2 2 0 002 0l7-4A2 2 0 0021 16z"/></svg>
            <span>Giá trị vốn kho</span>
          </div>
          <div class="kpi-value-row">
            7.492.000 <span style="text-decoration: underline;">đ</span>
          </div>
          <div class="kpi-sub-row">
            &sum; Tồn × Giá nhập · 163 đơn vị
          </div>
        </div>

        <!-- KPI 3: Stock Depletion Warning -->
        <div class="kpi-dark-item">
          <div class="kpi-label-row">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#f87171" stroke-width="2"><path d="M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
            <span style="color: #fca5a5;">Cảnh báo hàng chạm đáy</span>
          </div>
          <div class="kpi-value-row">
            2 sản phẩm
          </div>
          <div class="kpi-sub-row">
            Tồn kho &le; Mức tồn tối thiểu
          </div>
        </div>
      </div>

      <!-- MIDDLE ROW: REVENUE CHART & RESTOCK WARNING -->
      <div style="display: grid; grid-template-columns: 2fr 1.05fr; gap: 24px; margin-bottom: 24px;">
        <!-- Left: 7-Day Revenue Chart -->
        <div class="card">
          <div class="card-header">
            <div>
              <div class="card-title">Doanh thu 7 ngày</div>
              <div class="card-subtitle">Đơn đã thanh toán · Đơn vị: triệu đồng</div>
            </div>
            <span class="badge" style="background:#eff6ff; color:#2563eb; font-weight:600; padding:4px 10px;">21–27/10/2026</span>
          </div>
          <div class="card-body">
            <div style="height: 250px; position: relative;">
              <canvas id="revenueChart"></canvas>
            </div>
          </div>
        </div>

        <!-- Right: Need Restock Card -->
        <div class="card" style="display: flex; flex-direction: column;">
          <div class="card-header">
            <div class="card-title" style="display: flex; align-items: center; gap: 8px;">
              <span>Cần nhập thêm</span>
              <span class="badge badge-danger" style="font-size:0.75rem;">2</span>
            </div>
          </div>
          <div class="card-body" style="display: flex; flex-direction: column; justify-content: space-between; flex: 1;">
            <div style="display: flex; flex-direction: column; gap: 14px;">
              <!-- Item 1: Sữa yến mạch -->
              <div style="display: flex; justify-content: space-between; align-items: center; padding-bottom: 12px; border-bottom: 1px solid #f1f5f9;">
                <div>
                  <div style="font-size: 0.9rem; font-weight: 700; color: #0f172a;">Sữa yến mạch</div>
                  <div style="font-size: 0.75rem; color: #64748b; margin-top: 2px;">MK01 · Tồn / tối thiểu</div>
                </div>
                <span class="badge" style="background:#fef2f2; color:#ef4444; font-size:0.85rem; font-weight:700; padding:4px 10px;">8 / 8</span>
              </div>

              <!-- Item 2: Granola hạt -->
              <div style="display: flex; justify-content: space-between; align-items: center; padding-bottom: 12px; border-bottom: 1px solid #f1f5f9;">
                <div>
                  <div style="font-size: 0.9rem; font-weight: 700; color: #0f172a;">Granola hạt</div>
                  <div style="font-size: 0.75rem; color: #64748b; margin-top: 2px;">GR01 · Tồn / tối thiểu</div>
                </div>
                <span class="badge" style="background:#fef2f2; color:#ef4444; font-size:0.85rem; font-weight:700; padding:4px 10px;">6 / 6</span>
              </div>

              <!-- Pending Shipments Link Box -->
              <a href="${pageContext.request.contextPath}/views/products.jsp?tab=approvals" style="display: flex; align-items: center; gap: 10px; background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 10px; padding: 12px 14px; color: #334155; font-size: 0.825rem; font-weight: 600;">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#2563eb" stroke-width="2"><path d="M21 16V8a2 2 0 00-1-1.73l-7-4a2 2 0 00-2 0l-7 4A2 2 0 003 8v8a2 2 0 001 1.73l7 4a2 2 0 002 0l7-4A2 2 0 0021 16z"/></svg>
                <span>3 phiếu hàng về chờ duyệt</span>
              </a>
            </div>

            <div style="margin-top: 16px;">
              <a href="${pageContext.request.contextPath}/views/products.jsp" style="display: inline-flex; align-items: center; gap: 6px; font-size: 0.85rem; font-weight: 600; color: #2563eb;">
                <span>Xem hàng hóa cần bổ sung</span>
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg>
              </a>
            </div>
          </div>
        </div>
      </div>

      <!-- BOTTOM ROW: STAFF SALES ORDER HISTORY TABLE -->
      <div class="card">
        <div class="card-header">
          <div class="card-title">Lịch sử bán hàng nhân viên</div>
          <div style="display: flex; align-items: center; gap: 16px;">
            <select class="form-select" style="width: auto; padding: 6px 12px; font-size: 0.8rem;" onchange="alert('Lọc theo nhân viên: ' + this.value)">
              <option value="all">Tất cả nhân viên</option>
              <option value="lananh">Lê Lan Anh</option>
              <option value="baotran">Trần Quốc Bảo</option>
            </select>
            <a href="javascript:void(0)" onclick="alert('Đang mở toàn bộ lịch sử đơn hàng...')" style="font-size: 0.85rem; font-weight: 600; display: inline-flex; align-items: center; gap: 4px;">
              <span>Xem tất cả</span>
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg>
            </a>
          </div>
        </div>

        <div class="table-responsive">
          <table class="custom-table">
            <thead>
              <tr>
                <th>Mã đơn</th>
                <th>Nhân viên</th>
                <th>Thời gian</th>
                <th>Thanh toán</th>
                <th>Giá trị</th>
                <th>Trạng thái</th>
              </tr>
            </thead>
            <tbody>
              <c:choose>
                <c:when test="${not empty orders}">
                  <c:forEach items="${orders}" var="ord">
                    <tr>
                      <td style="font-weight: 700; color: #2563eb;">#${ord.code}</td>
                      <td style="font-weight: 500; color: #0f172a;">${ord.staffName}</td>
                      <td>${ord.formattedTime}</td>
                      <td>${ord.paymentMethod}</td>
                      <td style="font-weight: 600; color: #0f172a;"><fmt:formatNumber value="${ord.totalAmount}" pattern="#,###"/> đ</td>
                      <td><span class="badge badge-success">${ord.status}</span></td>
                    </tr>
                  </c:forEach>
                </c:when>
                <c:otherwise>
                  <!-- Mock Rows matching exact Mockup -->
                  <tr>
                    <td style="font-weight: 700; color: #2563eb;">#BH-1042</td>
                    <td style="font-weight: 500; color: #0f172a;">Lê Lan Anh</td>
                    <td>27/10 · 10:24</td>
                    <td>Tiền mặt</td>
                    <td style="font-weight: 600; color: #0f172a;">408.000 đ</td>
                    <td><span class="badge badge-success">Đã thanh toán</span></td>
                  </tr>
                  <tr>
                    <td style="font-weight: 700; color: #2563eb;">#BH-1041</td>
                    <td style="font-weight: 500; color: #0f172a;">Lê Lan Anh</td>
                    <td>27/10 · 09:52</td>
                    <td>Chuyển khoản</td>
                    <td style="font-weight: 600; color: #0f172a;">354.000 đ</td>
                    <td><span class="badge badge-success">Đã thanh toán</span></td>
                  </tr>
                  <tr>
                    <td style="font-weight: 700; color: #2563eb;">#BH-1040</td>
                    <td style="font-weight: 500; color: #0f172a;">Lê Lan Anh</td>
                    <td>27/10 · 09:15</td>
                    <td>Tiền mặt</td>
                    <td style="font-weight: 600; color: #0f172a;">492.000 đ</td>
                    <td><span class="badge badge-success">Đã thanh toán</span></td>
                  </tr>
                  <tr>
                    <td style="font-weight: 700; color: #2563eb;">#BH-1039</td>
                    <td style="font-weight: 500; color: #0f172a;">Trần Quốc Bảo</td>
                    <td>26/10 · 16:48</td>
                    <td>Chuyển khoản</td>
                    <td style="font-weight: 600; color: #0f172a;">246.000 đ</td>
                    <td><span class="badge badge-success">Đã thanh toán</span></td>
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

<script src="${pageContext.request.contextPath}/assets/js/dashboard.js"></script>
<jsp:include page="/common/footer.jsp" />

