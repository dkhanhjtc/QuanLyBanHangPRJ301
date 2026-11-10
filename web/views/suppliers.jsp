<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="userRole" value="${not empty requestScope.userRole ? requestScope.userRole : (empty sessionScope.userRole ? (empty sessionScope.user.role ? (empty currentRole ? 'manager' : currentRole) : sessionScope.user.role.toLowerCase()) : sessionScope.userRole.toLowerCase())}" />
<c:set var="isStaff" value="${not empty requestScope.isStaff ? requestScope.isStaff : (userRole eq 'staff' || sessionScope.user.role eq 'STAFF')}" />
<c:set var="activeMenu" value="suppliers" />
<c:set var="breadcrumbCurrent" value="Nhà cung cấp" />

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Quản lý Nhà cung cấp · Kiotflow</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>

<div class="app-container">
  <jsp:include page="/common/sidebar.jsp">
    <jsp:param name="activeMenu" value="suppliers" />
  </jsp:include>

  <div class="main-content">
    <jsp:include page="/common/header.jsp">
      <jsp:param name="breadcrumbCurrent" value="Nhà cung cấp" />
    </jsp:include>

    <div class="page-body">
      <!-- Page Top Header -->
      <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 24px; flex-wrap: wrap; gap: 12px;">
        <div>
          <h1 style="font-size: 1.85rem; font-weight: 800; color: #0f172a; letter-spacing: -0.02em;">Nhà cung cấp &amp; Xưởng may</h1>
          <div style="font-size: 0.85rem; color: #64748b; margin-top: 4px;">
            Quản lý danh sách đối tác cung ứng, xưởng may gia công và liên hệ nhập hàng.
          </div>
        </div>
        <div style="display: flex; gap: 10px;">
          <a href="${pageContext.request.contextPath}/suppliers" class="btn btn-outline" title="Làm mới">
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="23 4 23 10 17 10"/><polyline points="1 20 1 14 7 14"/><path d="M3.51 9a9 9 0 0114.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0020.49 15"/></svg>
            <span>Đồng bộ</span>
          </a>
          <button type="button" class="btn btn-primary" onclick="openNewSupplierModal()">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
            <span>+ Thêm nhà cung cấp</span>
          </button>
        </div>
      </div>

      <!-- KPI Summary Cards -->
      <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; margin-bottom: 24px;">
        <div class="card" style="padding: 18px 24px;">
          <div style="font-size: 0.75rem; color: #64748b; text-transform: uppercase; font-weight: 700; margin-bottom: 4px;">Tổng số đối tác</div>
          <div style="font-size: 1.85rem; font-weight: 800; color: #0f172a;">${totalSuppliers != null ? totalSuppliers : 0}</div>
        </div>
        <div class="card" style="padding: 18px 24px;">
          <div style="font-size: 0.75rem; color: #64748b; text-transform: uppercase; font-weight: 700; margin-bottom: 4px;">Đang hợp tác (Active)</div>
          <div style="font-size: 1.85rem; font-weight: 800; color: #059669;">${activeSuppliers != null ? activeSuppliers : 0}</div>
        </div>
        <div class="card" style="padding: 18px 24px;">
          <div style="font-size: 0.75rem; color: #64748b; text-transform: uppercase; font-weight: 700; margin-bottom: 4px;">Kênh nhập hàng chính</div>
          <div style="font-size: 1.15rem; font-weight: 700; color: #2563eb; margin-top: 6px;">Xưởng May &amp; Dệt Vải</div>
        </div>
      </div>

      <!-- Main Suppliers Card -->
      <div class="card">
        <!-- Filter Bar -->
        <div style="padding: 18px 20px; display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--border); flex-wrap: wrap; gap: 12px;">
          <form action="${pageContext.request.contextPath}/suppliers" method="GET" style="display: flex; gap: 10px; flex: 1; max-width: 500px;">
            <div class="input-icon-wrapper" style="flex: 1;">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
              <input type="text" name="q" class="form-input" placeholder="Tìm theo tên nhà cung cấp, mã đối tác, SĐT..." value="${param.q}">
            </div>
            <button type="submit" class="btn btn-outline" style="padding: 0 16px;">Tìm kiếm</button>
          </form>
          <div style="font-size: 0.8rem; color: #64748b;">
            Hiển thị <strong>${suppliers != null ? suppliers.size() : 0}</strong> đối tác cung ứng
          </div>
        </div>

        <!-- Table -->
        <div class="table-responsive">
          <table class="custom-table">
            <thead>
              <tr>
                <th style="width: 130px;">MÃ ĐỐI TÁC</th>
                <th>TÊN NHÀ CUNG CẤP / XƯỞNG MAY</th>
                <th>SỐ ĐIỆN THOẠI</th>
                <th>ĐỊA CHỈ</th>
                <th style="text-align: center; width: 130px;">TRẠNG THÁI</th>
                <th style="text-align: right; width: 160px;">THAO TÁC</th>
              </tr>
            </thead>
            <tbody>
              <c:choose>
                <c:when test="${not empty suppliers}">
                  <c:forEach items="${suppliers}" var="s">
                    <tr>
                      <td style="font-weight: 700; color: #2563eb;">${s.supplierCode}</td>
                      <td>
                        <div style="font-weight: 700; color: #0f172a; font-size: 0.95rem;">${s.supplierName}</div>
                      </td>
                      <td style="font-weight: 600; color: #334155;">
                        <c:out value="${not empty s.contactPhone ? s.contactPhone : '-'}" />
                      </td>
                      <td style="color: #64748b; font-size: 0.85rem;">
                        <c:out value="${not empty s.address ? s.address : 'Chưa cập nhật'}" />
                      </td>
                      <td style="text-align: center;">
                        <c:choose>
                          <c:when test="${s.status eq 'ACTIVE'}">
                            <span class="badge badge-success">Đang hợp tác</span>
                          </c:when>
                          <c:otherwise>
                            <span class="badge badge-gray">Ngừng hợp tác</span>
                          </c:otherwise>
                        </c:choose>
                      </td>
                      <td style="text-align: right;">
                        <div style="display: inline-flex; gap: 6px; justify-content: flex-end;">
                          <button type="button" class="btn btn-outline" style="padding: 5px 12px; font-size: 0.8rem;"
                                  onclick="openEditSupplierModal(${s.supplierId}, '${s.supplierCode}', '<c:out value="${s.supplierName}"/>', '<c:out value="${s.contactPhone}"/>', '<c:out value="${s.address}"/>', '${s.status}')">
                            <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M11 4H4a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 013 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                            <span>Sửa</span>
                          </button>
                          <button type="button" class="btn btn-outline" style="padding: 5px 10px; font-size: 0.8rem; color: #dc2626; border-color: #fecaca; background: #fff5f5;"
                                  onclick="openDeleteSupplierModal(${s.supplierId}, '<c:out value="${s.supplierName}"/>')">
                            <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
                            <span>Xóa</span>
                          </button>
                        </div>
                      </td>
                    </tr>
                  </c:forEach>
                </c:when>
                <c:otherwise>
                  <tr>
                    <td colspan="6" style="text-align: center; padding: 48px; color: #94a3b8;">
                      Chưa có nhà cung cấp / xưởng may nào trong danh sách.
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
     MODAL: THÊM / SỬA NHÀ CUNG CẤP
     ========================================================================== -->
<div class="modal-backdrop" id="supplierModal" style="display: none;">
  <div class="modal-window" style="max-width: 600px; width: 92%;">
    <div class="modal-header">
      <div>
        <h3 class="modal-title" id="supplierModalTitle">Thêm nhà cung cấp mới</h3>
        <div class="modal-sub">Thông tin đối tác cung ứng &amp; xưởng may gia công</div>
      </div>
      <button type="button" class="modal-close" onclick="closeModal('supplierModal')">&times;</button>
    </div>

    <form action="${pageContext.request.contextPath}/suppliers" method="POST">
      <input type="hidden" name="action" value="save">
      <input type="hidden" name="supplierId" id="modalSupplierId" value="">

      <div class="modal-body" style="padding: 20px 24px;">
        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 14px;">
          <div class="form-group" style="margin-bottom: 0;">
            <label class="form-label" for="modalSupplierCode">Mã đối tác</label>
            <input type="text" id="modalSupplierCode" name="supplierCode" class="form-input" placeholder="Tự sinh nếu bỏ trống (NCC-xxx)">
          </div>
          <div class="form-group" style="margin-bottom: 0;">
            <label class="form-label" for="modalSupplierPhone">Số điện thoại liên hệ *</label>
            <input type="text" id="modalSupplierPhone" name="contactPhone" class="form-input" placeholder="Ví dụ: 0908889999" required>
          </div>
        </div>

        <div class="form-group" style="margin-bottom: 14px;">
          <label class="form-label" for="modalSupplierName">Tên nhà cung cấp / Xưởng may *</label>
          <input type="text" id="modalSupplierName" name="supplierName" class="form-input" placeholder="Ví dụ: Xưởng May Tân Bình Fashion" required>
        </div>

        <div class="form-group" style="margin-bottom: 14px;">
          <label class="form-label" for="modalSupplierAddress">Địa chỉ xưởng / Trụ sở</label>
          <input type="text" id="modalSupplierAddress" name="address" class="form-input" placeholder="Ví dụ: Quận Tân Bình, TP. Hồ Chí Minh">
        </div>

        <div class="form-group" style="margin-bottom: 0;">
          <label class="form-label" for="modalSupplierStatus">Trạng thái hợp tác</label>
          <select id="modalSupplierStatus" name="status" class="form-select">
            <option value="ACTIVE">Đang hợp tác (Active)</option>
            <option value="INACTIVE">Tạm ngưng hợp tác (Inactive)</option>
          </select>
        </div>
      </div>

      <div class="modal-footer" style="padding: 16px 24px; border-top: 1px solid var(--border); display: flex; justify-content: flex-end; gap: 10px;">
        <button type="button" class="btn btn-outline" onclick="closeModal('supplierModal')">Hủy bỏ</button>
        <button type="submit" class="btn btn-primary" id="supplierModalSubmitBtn">Lưu nhà cung cấp</button>
      </div>
    </form>
  </div>
</div>

<!-- ==========================================================================
     MODAL: XÁC NHẬN XÓA NHÀ CUNG CẤP
     ========================================================================== -->
<div class="modal-backdrop" id="deleteSupplierModal" style="display: none;">
  <div class="modal-window" style="max-width: 440px; width: 90%;">
    <div class="modal-header">
      <h3 class="modal-title" style="color: #dc2626;">Xác nhận xóa nhà cung cấp</h3>
      <button type="button" class="modal-close" onclick="closeModal('deleteSupplierModal')">&times;</button>
    </div>
    <form action="${pageContext.request.contextPath}/suppliers" method="POST">
      <input type="hidden" name="action" value="delete">
      <input type="hidden" name="supplierId" id="deleteSupplierId" value="">

      <div class="modal-body" style="padding: 20px 24px; font-size: 0.9rem; color: #475569; line-height: 1.5;">
        Bạn có chắc chắn muốn xóa đối tác <strong id="deleteSupplierName" style="color: #0f172a;"></strong>?<br>
        Nếu đối tác này đã có phiếu nhập hàng trước đó, hệ thống sẽ tự động chuyển sang trạng thái <em>Ngừng hợp tác</em> để bảo toàn lịch sử kho.
      </div>
      <div class="modal-footer" style="padding: 14px 24px; display: flex; justify-content: flex-end; gap: 10px; border-top: 1px solid var(--border);">
        <button type="button" class="btn btn-outline" onclick="closeModal('deleteSupplierModal')">Hủy</button>
        <button type="submit" class="btn btn-primary" style="background: #dc2626; border-color: #dc2626;">Đồng ý xóa</button>
      </div>
    </form>
  </div>
</div>

<script>
  function openNewSupplierModal() {
    document.getElementById('supplierModalTitle').textContent = 'Thêm nhà cung cấp mới';
    document.getElementById('modalSupplierId').value = '';
    document.getElementById('modalSupplierCode').value = '';
    document.getElementById('modalSupplierName').value = '';
    document.getElementById('modalSupplierPhone').value = '';
    document.getElementById('modalSupplierAddress').value = '';
    document.getElementById('modalSupplierStatus').value = 'ACTIVE';
    document.getElementById('supplierModalSubmitBtn').textContent = 'Thêm mới';
    document.getElementById('supplierModal').style.display = 'flex';
  }

  function openEditSupplierModal(id, code, name, phone, address, status) {
    document.getElementById('supplierModalTitle').textContent = 'Chỉnh sửa: ' + name;
    document.getElementById('modalSupplierId').value = id;
    document.getElementById('modalSupplierCode').value = code;
    document.getElementById('modalSupplierName').value = name;
    document.getElementById('modalSupplierPhone').value = phone;
    document.getElementById('modalSupplierAddress').value = address;
    document.getElementById('modalSupplierStatus').value = status;
    document.getElementById('supplierModalSubmitBtn').textContent = 'Cập nhật';
    document.getElementById('supplierModal').style.display = 'flex';
  }

  function openDeleteSupplierModal(id, name) {
    document.getElementById('deleteSupplierId').value = id;
    document.getElementById('deleteSupplierName').textContent = name;
    document.getElementById('deleteSupplierModal').style.display = 'flex';
  }

  function closeModal(modalId) {
    const m = document.getElementById(modalId);
    if (m) {
      m.style.display = 'none';
      m.classList.remove('show');
    }
    document.body.style.overflow = '';
  }
</script>

<jsp:include page="/common/footer.jsp" />
</body>
</html>

