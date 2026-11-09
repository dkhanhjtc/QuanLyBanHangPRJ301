<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="activeMenu" value="dashboard" />
<c:set var="breadcrumbCurrent" value="Tổng quan" />

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Tổng quan vận hành (Dashboard) · Kiotflow</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>

<div class="app-container">
  <!-- Dynamic Sidebar -->
  <jsp:include page="/common/sidebar.jsp">
    <jsp:param name="activeMenu" value="dashboard" />
  </jsp:include>

  <!-- Main Work Area -->
  <div class="main-content">
    <jsp:include page="/common/header.jsp">
      <jsp:param name="breadcrumbCurrent" value="Tổng quan vận hành" />
    </jsp:include>

    <div class="page-body">
      <!-- Page Top Header -->
      <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 24px;">
        <div>
          <h1 style="font-size: 1.85rem; font-weight: 800; color: #0f172a; letter-spacing: -0.02em;">Tổng quan vận hành</h1>
          <div style="font-size: 0.85rem; color: #64748b; margin-top: 4px;">
            Cửa hàng An Nhiên · Dữ liệu đồng bộ thời gian thực từ CSDL
          </div>
        </div>
        <div style="display: flex; gap: 10px;">
          <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-outline" style="font-size: 0.85rem;" title="Làm mới dữ liệu">
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="23 4 23 10 17 10"/><polyline points="1 20 1 14 7 14"/><path d="M3.51 9a9 9 0 0114.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0020.49 15"/></svg>
            <span>Đồng bộ</span>
          </a>
          <button type="button" class="btn btn-outline" onclick="alert('Đang trích xuất báo cáo doanh thu & tồn kho Excel...')">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4M7 10l5 5 5-5M12 15V3"/></svg>
            <span>Xuất báo cáo</span>
          </button>
        </div>
      </div>

      <!-- KPI METRIC CARDS (Truy vấn động từ CSDL qua OrderDAO.getRevenueSummary) -->
      <div class="kpi-dark-container">
        <!-- KPI 1: Doanh thu ngày -->
        <div class="kpi-dark-item">
          <div class="kpi-label-row">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/></svg>
            <span>Doanh thu hôm nay</span>
          </div>
          <div class="kpi-value-row">
            <fmt:formatNumber value="${kpiSummary.todayRevenue != null ? kpiSummary.todayRevenue : 0}" pattern="#,###"/> <span style="text-decoration: underline;">đ</span>
          </div>
          <div class="kpi-sub-row positive">
            Giao dịch thanh toán hoàn tất
          </div>
        </div>

        <!-- KPI 2: Giá trị vốn kho -->
        <div class="kpi-dark-item">
          <div class="kpi-label-row">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 16V8a2 2 0 00-1-1.73l-7-4a2 2 0 00-2 0l-7 4A2 2 0 003 8v8a2 2 0 001 1.73l7 4a2 2 0 002 0l7-4A2 2 0 0021 16z"/></svg>
            <span>Giá trị vốn kho</span>
          </div>
          <div class="kpi-value-row">
            <fmt:formatNumber value="${kpiSummary.totalInventoryValue != null ? kpiSummary.totalInventoryValue : 0}" pattern="#,###"/> <span style="text-decoration: underline;">đ</span>
          </div>
          <div class="kpi-sub-row">
            &sum; Tồn &times; Giá nhập · ${kpiSummary.totalUnits != null ? kpiSummary.totalUnits : 0} đơn vị
          </div>
        </div>

        <!-- KPI 3: Cảnh báo hàng chạm đáy -->
        <div class="kpi-dark-item">
          <div class="kpi-label-row">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#f87171" stroke-width="2"><path d="M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
            <span style="color: #fca5a5;">Cảnh báo hàng chạm đáy</span>
          </div>
          <div class="kpi-value-row">
            ${kpiSummary.lowStockCount != null ? kpiSummary.lowStockCount : 0} sản phẩm
          </div>
          <div class="kpi-sub-row">
            Tồn kho &le; Mức tồn tối thiểu
          </div>
        </div>
      </div>

      <!-- MIDDLE ROW: REVENUE CHART & RESTOCK WARNING -->
      <div style="display: grid; grid-template-columns: 2fr 1.05fr; gap: 24px; margin-bottom: 24px;">
        <!-- Left: Revenue Chart -->
        <div class="card">
          <div class="card-header">
            <div>
              <div class="card-title">Biểu đồ doanh thu tuần</div>
              <div class="card-subtitle">Đơn đã thanh toán · Đơn vị: nghìn đồng</div>
            </div>
            <span class="badge" style="background:#eff6ff; color:#2563eb; font-weight:600; padding:4px 10px;">Tuần hiện tại</span>
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
              <span class="badge badge-danger" style="font-size:0.75rem;">${kpiSummary.lowStockCount != null ? kpiSummary.lowStockCount : 0}</span>
            </div>
          </div>
          <div class="card-body" style="display: flex; flex-direction: column; justify-content: space-between; flex: 1;">
            <div style="display: flex; flex-direction: column; gap: 14px;">
              <c:choose>
                <c:when test="${not empty lowStockProducts}">
                  <c:forEach items="${lowStockProducts}" var="lp" end="2">
                    <div style="display: flex; justify-content: space-between; align-items: center; padding-bottom: 12px; border-bottom: 1px solid #f1f5f9;">
                      <div>
                        <div style="font-size: 0.9rem; font-weight: 700; color: #0f172a;">${lp.name}</div>
                        <div style="font-size: 0.75rem; color: #64748b; margin-top: 2px;">${lp.sku} · Tồn / tối thiểu</div>
                      </div>
                      <span class="badge" style="background:#fef2f2; color:#ef4444; font-size:0.85rem; font-weight:700; padding:4px 10px;">${lp.stockQuantity} / ${lp.minStock}</span>
                    </div>
                  </c:forEach>
                </c:when>
                <c:otherwise>
                  <div style="padding: 24px 10px; text-align: center; color: #64748b; font-size: 0.85rem;">
                    Kho hàng ổn định, chưa có sản phẩm nào chạm đáy tồn kho.
                  </div>
                </c:otherwise>
              </c:choose>

              <!-- Pending Shipments Link Box -->
              <a href="${pageContext.request.contextPath}/products?tab=approvals" style="display: flex; align-items: center; gap: 10px; background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 10px; padding: 12px 14px; color: #334155; font-size: 0.825rem; font-weight: 600;">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#2563eb" stroke-width="2"><path d="M21 16V8a2 2 0 00-1-1.73l-7-4a2 2 0 00-2 0l-7 4A2 2 0 003 8v8a2 2 0 001 1.73l7 4a2 2 0 002 0l7-4A2 2 0 0021 16z"/></svg>
                <span>${pendingPOCount != null ? pendingPOCount : 0} phiếu hàng về chờ duyệt</span>
              </a>
            </div>

            <div style="margin-top: 16px;">
              <a href="${pageContext.request.contextPath}/products" style="display: inline-flex; align-items: center; gap: 6px; font-size: 0.85rem; font-weight: 600; color: #2563eb;">
                <span>Xem toàn bộ danh mục hàng hóa</span>
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg>
              </a>
            </div>
          </div>
        </div>
      </div>

      <!-- BOTTOM ROW: ORDER HISTORY TABLE -->
      <div class="card">
        <div class="card-header">
          <div class="card-title">Lịch sử bán hàng gần đây</div>
          <div style="display: flex; align-items: center; gap: 16px;">
            <a href="${pageContext.request.contextPath}/pos" style="font-size: 0.85rem; font-weight: 600; display: inline-flex; align-items: center; gap: 4px;">
              <span>Mở quầy bán hàng</span>
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
                  <tr>
                    <td colspan="6" style="text-align: center; padding: 40px; color: #94a3b8;">
                      <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" style="margin-bottom:8px;"><circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/><path d="M1 1h4l2.68 13.39a2 2 0 002 1.61h9.72a2 2 0 002-1.61L23 6H6"/></svg>
                      <div style="font-weight: 600;">Chưa có đơn hàng nào được ghi nhận</div>
                      <div style="font-size: 0.75rem;">Các đơn hàng tạo tại quầy POS sẽ hiển thị tại đây theo thời gian thực</div>
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

<script src="${pageContext.request.contextPath}/assets/js/dashboard.js"></script>
<jsp:include page="/common/footer.jsp" />
</body>
</html>
