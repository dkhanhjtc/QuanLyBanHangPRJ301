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
          <button type="button" class="btn btn-primary" onclick="openNewInboundModal()">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
            <span>+ Tạo phiếu nhập hàng</span>
          </button>
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
          <div style="font-size: 2rem; font-weight: 800; color: #16a34a;"><fmt:formatNumber value="${pendingTotalCost != null ? pendingTotalCost : 0}" pattern="#,###"/> VNĐ</div>
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
                      <td style="text-align: right; font-weight: 700; color: #0f172a;"><fmt:formatNumber value="${po.totalCost}" pattern="#,###"/> VNĐ</td>
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

<!-- ==========================================================================
     MODAL: TẠO PHIẾU NHẬP HÀNG VỀ KHO (TỪ NHÀ CUNG CẤP / XƯỞNG MAY)
     ========================================================================== -->
<div class="modal-backdrop" id="newInboundModal" style="display: none;">
  <div class="modal-window" style="max-width: 780px; width: 92%; max-height: 90vh; overflow-y: auto;">
    <div class="modal-header">
      <div>
        <h3 class="modal-title">Tạo phiếu nhập hàng về kho</h3>
        <div class="modal-sub">Ghi nhận lô hàng mới từ đối tác xưởng may hoặc nhà cung cấp</div>
      </div>
      <button type="button" class="modal-close" onclick="closeNewInboundModal()">&#215;</button>
    </div>

    <form action="${pageContext.request.contextPath}/inbound-shipments" method="POST">
      <input type="hidden" name="action" value="create_inflow">

      <div class="modal-body" style="padding: 20px 24px;">
        <!-- Hàng 1: Mã phiếu nhập & Ngày tạo -->
        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 14px;">
          <div class="form-group" style="margin-bottom: 0;">
            <label class="form-label" for="inboundPoCode">Mã phiếu nhập (Tự động) *</label>
            <input type="text" id="inboundPoCode" name="poCode" class="form-input" style="font-weight: 700; color: #2563eb;" required>
          </div>
          <div class="form-group" style="margin-bottom: 0;">
            <label class="form-label">Người lập phiếu</label>
            <input type="text" class="form-input" value="${not empty sessionScope.user.fullName ? sessionScope.user.fullName : 'Nguyễn Minh Hà'}" readonly style="background: #f8fafc; color: #475569;">
          </div>
        </div>

        <!-- HÀNG RIÊNG (DEDICATED ROW): Nhà cung cấp / Xưởng may -->
        <div class="form-group" style="margin-bottom: 14px;">
          <label class="form-label" for="inboundSupplierSelect">Nhà cung cấp / Xưởng may liên kết *</label>
          <select id="inboundSupplierSelect" name="supplierName" class="form-select" style="width: 100%; font-weight: 500;" required>
            <option value="">-- Chọn Nhà cung cấp hoặc Xưởng may --</option>
            <c:forEach items="${suppliers}" var="sup">
              <option value="${sup.supplierName}">${sup.supplierName} (${sup.supplierCode}) · SĐT: ${sup.contactPhone}</option>
            </c:forEach>
          </select>
        </div>

        <!-- Hàng 3: Chọn sản phẩm nhập kho -->
        <div class="form-group" style="margin-bottom: 14px;">
          <label class="form-label" for="inboundProductSelect">Sản phẩm cần nhập về *</label>
          <select id="inboundProductSelect" name="productId" class="form-select" style="width: 100%;" onchange="onProductSelectChange(this)" required>
            <option value="">-- Chọn mặt hàng thời trang trong danh mục --</option>
            <c:forEach items="${products}" var="p">
              <option value="${p.sku}" data-cost="${p.costPrice}" data-name="${p.name}" data-stock="${p.stockQuantity}">
                ${p.name} (${p.sku}) · Size/Màu: ${p.spec} · Tồn hiện tại: ${p.stockQuantity}
              </option>
            </c:forEach>
          </select>
        </div>

        <!-- Hàng 4: Số lượng nhập & Giá vốn nhập đề nghị -->
        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 14px;">
          <div class="form-group" style="margin-bottom: 0;">
            <label class="form-label" for="inboundQty">Số lượng nhập (đơn vị: Cái) *</label>
            <input type="number" id="inboundQty" name="quantity" class="form-input" value="30" min="1" oninput="calculateTotalInflow()" required>
          </div>
          <div class="form-group" style="margin-bottom: 0;">
            <label class="form-label" for="inboundCost">Đơn giá nhập (VNĐ) *</label>
            <input type="number" id="inboundCost" name="costPrice" class="form-input" placeholder="200000" min="0" step="1000" oninput="calculateTotalInflow()" required>
          </div>
        </div>

        <!-- Tóm tắt tổng tiền nhập dự kiến -->
        <div style="background: #eff6ff; border: 1px solid #bfdbfe; border-radius: 10px; padding: 12px 16px; margin-bottom: 14px; display: flex; justify-content: space-between; align-items: center;">
          <div style="font-size: 0.85rem; color: #1e40af; font-weight: 600;">Tổng giá trị lô hàng nhập dự kiến:</div>
          <div style="font-size: 1.25rem; font-weight: 800; color: #1d4ed8;" id="inboundTotalCostPreview">0 đ</div>
        </div>

        <!-- Hàng 5: Ghi chú nhập hàng -->
        <div class="form-group" style="margin-bottom: 0;">
          <label class="form-label" for="inboundNote">Ghi chú phiếu nhập</label>
          <input type="text" id="inboundNote" name="note" class="form-input" placeholder="Ví dụ: Nhập bổ sung sào trưng bày, hàng giao đợt 1...">
        </div>
      </div>

      <div class="modal-footer">
        <button type="button" class="btn btn-outline" onclick="closeNewInboundModal()">Hủy</button>
        <button type="submit" class="btn btn-primary">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
          <span>Lập phiếu nhập</span>
        </button>
      </div>
    </form>
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
      <button type="button" class="modal-close" onclick="closeRejectModal()">&#215;</button>
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
  function openNewInboundModal() {
    const code = 'PN-' + Math.floor(1000 + Math.random() * 9000);
    document.getElementById('inboundPoCode').value = code;
    document.getElementById('inboundQty').value = '30';
    calculateTotalInflow();
    document.getElementById('newInboundModal').style.display = 'flex';
  }

  function closeNewInboundModal() {
    closeModal('newInboundModal');
  }

  function onProductSelectChange(sel) {
    const opt = sel.options[sel.selectedIndex];
    if (opt && opt.getAttribute('data-cost')) {
      document.getElementById('inboundCost').value = opt.getAttribute('data-cost');
    }
    calculateTotalInflow();
  }

  function calculateTotalInflow() {
    const qty = parseInt(document.getElementById('inboundQty').value || '0', 10);
    const cost = parseFloat(document.getElementById('inboundCost').value || '0');
    const total = qty * cost;
    document.getElementById('inboundTotalCostPreview').textContent = new Intl.NumberFormat('vi-VN').format(total) + ' đ';
  }

  function openRejectModal(id, code) {
    document.getElementById('rejectPoIdInput').value = id;
    document.getElementById('rejectPoCodeInput').value = code;
    document.getElementById('rejectTicketIdTitle').textContent = code;
    document.getElementById('rejectTicketModal').style.display = 'flex';
  }
  function closeRejectModal() {
    closeModal('rejectTicketModal');
  }
</script>

<jsp:include page="/common/footer.jsp" />
</body>
</html>

