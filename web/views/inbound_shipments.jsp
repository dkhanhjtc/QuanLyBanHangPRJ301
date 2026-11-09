<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="activeMenu" value="inbound" />
<c:set var="breadcrumbCurrent" value="Duyệt hàng về" />

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Duyệt hàng về · Kiotflow</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>

<div class="app-container">
  <jsp:include page="/common/sidebar.jsp">
    <jsp:param name="activeMenu" value="inbound" />
  </jsp:include>

  <div class="main-content">
    <jsp:include page="/common/header.jsp">
      <jsp:param name="breadcrumbCurrent" value="Duyệt hàng về" />
    </jsp:include>

    <div class="page-body">
      <!-- Page Top Header -->
      <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 24px;">
        <div>
          <h1 style="font-size: 1.85rem; font-weight: 800; color: #0f172a; letter-spacing: -0.02em;">Duyệt hàng về kho</h1>
          <div style="font-size: 0.85rem; color: #64748b; margin-top: 4px;">
            Quản lý và phê duyệt các lô hàng nhập từ nhà cung cấp &amp; xưởng may trước khi cộng tồn kho.
          </div>
        </div>
        <div style="display: flex; gap: 10px;">
          <a href="${pageContext.request.contextPath}/inbound-shipments" class="btn btn-outline" title="Đồng bộ danh sách">
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="23 4 23 10 17 10"/><polyline points="1 20 1 14 7 14"/><path d="M3.51 9a9 9 0 0114.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0020.49 15"/></svg>
            <span>Đồng bộ</span>
          </a>
        </div>
      </div>

      <!-- Stats Summary Cards -->
      <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; margin-bottom: 24px;">
        <div class="card" style="padding: 18px 24px;">
          <div style="font-size: 0.75rem; color: #64748b; margin-bottom: 4px;">Phiếu chờ duyệt</div>
          <div style="font-size: 2rem; font-weight: 800; color: #2563eb;">${pendingPOCount != null ? pendingPOCount : 0}</div>
        </div>
        <div class="card" style="padding: 18px 24px;">
          <div style="font-size: 0.75rem; color: #64748b; margin-bottom: 4px;">Số lượng nhập dự kiến</div>
          <div style="font-size: 2rem; font-weight: 800; color: #0f172a;">${pendingUnits != null ? pendingUnits : 0} <span style="font-size: 1rem; font-weight: 500; color: #64748b;">đơn vị</span></div>
        </div>
        <div class="card" style="padding: 18px 24px;">
          <div style="font-size: 0.75rem; color: #64748b; margin-bottom: 4px;">Tổng giá trị nhập</div>
          <div style="font-size: 2rem; font-weight: 800; color: #16a34a;"><fmt:formatNumber value="${pendingTotalCost != null ? pendingTotalCost : 0}" pattern="#,###"/> đ</div>
        </div>
      </div>

      <!-- Inbound Shipments Table Card -->
      <div class="card">
        <div class="card-header">
          <div>
            <div class="card-title">Danh sách phiếu nhập hàng chờ duyệt</div>
            <div class="card-subtitle">Khi nhấn Duyệt, số lượng sẽ được tự động cộng ngay vào tồn kho trong CSDL SQL Server</div>
          </div>
        </div>

        <div class="table-responsive">
          <table class="custom-table">
            <thead>
              <tr>
                <th>MÃ PHIẾU</th>
                <th>SẢN PHẨM</th>
                <th>NHÀ CUNG CẤP / XƯỞNG</th>
                <th style="text-align: center;">SL NHẬP</th>
                <th style="text-align: right;">TỔNG TIỀN</th>
                <th>NGƯỜI TẠO</th>
                <th>THỜI GIAN</th>
                <th style="text-align: center;">TRẠNG THÁI</th>
                <th style="text-align: right;">THAO TÁC</th>
              </tr>
            </thead>
            <tbody>
              <c:choose>
                <c:when test="${not empty pendingPOs}">
                  <c:forEach items="${pendingPOs}" var="po">
                    <tr>
                      <td style="font-weight: 700; color: #2563eb;">#${po.code}</td>
                      <td>
                        <div style="font-weight: 700; color: #0f172a;">${po.productName}</div>
                        <div style="font-size: 0.72rem; color: #64748b;">Mã SP: ${po.productId}</div>
                      </td>
                      <td style="font-weight: 500; color: #334155;">${po.supplierName}</td>
                      <td style="text-align: center; font-weight: 700; color: #059669;">+${po.totalQuantity}</td>
                      <td style="text-align: right; font-weight: 700; color: #0f172a;"><fmt:formatNumber value="${po.totalCost}" pattern="#,###"/> đ</td>
                      <td><span class="badge badge-gray">${po.createdByName}</span></td>
                      <td style="font-size: 0.8rem; color: #64748b;">${po.formattedDate}</td>
                      <td style="text-align: center;">
                        <span class="badge badge-warning">Chờ duyệt</span>
                        <div style="font-size: 0.7rem; color: #94a3b8; margin-top: 2px;">Chưa cộng kho</div>
                      </td>
                      <td style="text-align: right;">
                        <form action="${pageContext.request.contextPath}/inbound-shipments" method="POST" style="display:inline;">
                          <input type="hidden" name="action" value="approve_inflow">
                          <input type="hidden" name="poId" value="${po.id}">
                          <input type="hidden" name="poCode" value="${po.code}">
                          <button type="submit" class="btn btn-primary" style="padding: 6px 14px; font-size: 0.8rem;" onclick="return confirm('Xác nhận DUYỆT phiếu nhập #${po.code}? Hàng sẽ được cộng ngay vào kho.');">
                            <span>Duyệt</span>
                          </button>
                        </form>
                        <button type="button" class="btn btn-danger-outline" style="padding: 6px 14px; font-size: 0.8rem; margin-left: 4px;" onclick="openRejectModal('${po.id}', '${po.code}', '${po.productName}', '${po.supplierName}', '${po.createdByName}', ${po.totalQuantity}, ${po.stockBefore})">
                          <span>Từ chối</span>
                        </button>
                      </td>
                    </tr>
                  </c:forEach>
                </c:when>
                <c:otherwise>
                  <tr>
                    <td colspan="9" style="text-align: center; padding: 48px; color: #94a3b8;">
                      <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" style="margin-bottom:8px;"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 14 14"/></svg>
                      <div style="font-weight: 600; font-size: 1rem;">Không có phiếu nhập kho nào chờ duyệt</div>
                      <div style="font-size: 0.8rem; margin-top: 4px;">Tất cả hàng về đã được duyệt hoặc chưa phát sinh đợt giao mới.</div>
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

<!-- MODAL: TỪ CHỐI PHIẾU NHẬP HÀNG -->
<div class="modal-backdrop" id="rejectTicketModal" style="display: none;">
  <div class="modal-window">
    <div class="modal-header">
      <div>
        <h3 class="modal-title">Từ chối phiếu <span id="rejectTicketIdTitle">PN-025</span></h3>
        <div class="modal-sub">Nhập lý do từ chối phiếu hàng về</div>
      </div>
      <button type="button" class="modal-close" onclick="closeRejectModal()">&times;</button>
    </div>

    <form action="${pageContext.request.contextPath}/inbound-shipments" method="POST">
      <input type="hidden" name="action" value="reject_inflow">
      <input type="hidden" name="poId" id="rejectPoIdInput">
      <input type="hidden" name="poCode" id="rejectPoCodeInput">

      <div class="modal-body" style="padding: 20px 24px;">
        <div class="form-group">
          <label class="form-label" for="rejectReasonInput">Lý do từ chối *</label>
          <textarea id="rejectReasonInput" name="rejectReason" class="form-textarea" rows="3" placeholder="Ví dụ: Sai mẫu vải, đường may lỗi hoặc số lượng giao không đúng hợp đồng..." required></textarea>
        </div>
      </div>

      <div class="modal-footer">
        <button type="button" class="btn btn-outline" onclick="closeRejectModal()">Hủy</button>
        <button type="submit" class="btn btn-primary" style="background:#dc2626; border-color:#dc2626;">Xác nhận từ chối</button>
      </div>
    </form>
  </div>
</div>

<script>
  function openRejectModal(id, code) {
    document.getElementById('rejectPoIdInput').value = id;
    document.getElementById('rejectPoCodeInput').value = code;
    document.getElementById('rejectTicketIdTitle').textContent = code;
    document.getElementById('rejectTicketModal').style.display = 'flex';
  }
  function closeRejectModal() {
    document.getElementById('rejectTicketModal').style.display = 'none';
  }
</script>

<jsp:include page="/common/footer.jsp" />
</body>
</html>
