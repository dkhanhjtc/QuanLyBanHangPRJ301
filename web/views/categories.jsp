<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="userRole" value="${not empty requestScope.userRole ? requestScope.userRole : (empty sessionScope.userRole ? (empty sessionScope.user.role ? (empty currentRole ? 'manager' : currentRole) : sessionScope.user.role.toLowerCase()) : sessionScope.userRole.toLowerCase())}" />
<c:set var="isStaff" value="${not empty requestScope.isStaff ? requestScope.isStaff : (userRole eq 'staff' || sessionScope.user.role eq 'STAFF')}" />
<c:set var="activeMenu" value="categories" />
<c:set var="breadcrumbCurrent" value="Danh mục hàng hóa" />

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Danh mục hàng hóa · Kiotflow</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>

<div class="app-container">
  <jsp:include page="/common/sidebar.jsp">
    <jsp:param name="activeMenu" value="categories" />
  </jsp:include>

  <div class="main-content">
    <jsp:include page="/common/header.jsp">
      <jsp:param name="breadcrumbCurrent" value="Danh mục hàng hóa" />
    </jsp:include>

    <div class="page-body">
      <!-- Page Top Header -->
      <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 24px; flex-wrap: wrap; gap: 12px;">
        <div>
          <h1 style="font-size: 1.85rem; font-weight: 800; color: #0f172a; letter-spacing: -0.02em;">Danh mục nhóm hàng</h1>
          <div style="font-size: 0.85rem; color: #64748b; margin-top: 4px;">
            Phân loại ngành hàng thời trang, cấu trúc danh mục và quản lý số lượng sản phẩm.
          </div>
        </div>
        <div style="display: flex; gap: 10px;">
          <a href="${pageContext.request.contextPath}/categories" class="btn btn-outline" title="Làm mới">
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="23 4 23 10 17 10"/><polyline points="1 20 1 14 7 14"/><path d="M3.51 9a9 9 0 0114.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0020.49 15"/></svg>
            <span>Đồng bộ</span>
          </a>
          <button type="button" class="btn btn-primary" onclick="openNewCategoryModal()">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
            <span>+ Thêm danh mục</span>
          </button>
        </div>
      </div>

      <!-- KPI Summary Cards -->
      <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; margin-bottom: 24px;">
        <div class="card" style="padding: 18px 24px;">
          <div style="font-size: 0.75rem; color: #64748b; text-transform: uppercase; font-weight: 700; margin-bottom: 4px;">Tổng số nhóm hàng</div>
          <div style="font-size: 1.85rem; font-weight: 800; color: #0f172a;">${totalCategories != null ? totalCategories : 0}</div>
        </div>
        <div class="card" style="padding: 18px 24px;">
          <div style="font-size: 0.75rem; color: #64748b; text-transform: uppercase; font-weight: 700; margin-bottom: 4px;">Sản phẩm đang phân nhóm</div>
          <div style="font-size: 1.85rem; font-weight: 800; color: #2563eb;">${totalProductsInCats != null ? totalProductsInCats : 0}</div>
        </div>
        <div class="card" style="padding: 18px 24px;">
          <div style="font-size: 0.75rem; color: #64748b; text-transform: uppercase; font-weight: 700; margin-bottom: 4px;">Quy chuẩn ngành</div>
          <div style="font-size: 1.15rem; font-weight: 700; color: #059669; margin-top: 6px;">Thời trang &amp; May mặc</div>
        </div>
      </div>

      <!-- Main Categories Card -->
      <div class="card">
        <!-- Filter Bar -->
        <div style="padding: 18px 20px; display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--border); flex-wrap: wrap; gap: 12px;">
          <form action="${pageContext.request.contextPath}/categories" method="GET" style="display: flex; gap: 10px; flex: 1; max-width: 500px;">
            <div class="input-icon-wrapper" style="flex: 1;">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
              <input type="text" name="q" class="form-input" placeholder="Tìm theo tên nhóm hàng, mô tả..." value="${param.q}">
            </div>
            <button type="submit" class="btn btn-outline" style="padding: 0 16px;">Tìm kiếm</button>
          </form>
          <div style="font-size: 0.8rem; color: #64748b;">
            Hiển thị <strong>${categories != null ? categories.size() : 0}</strong> danh mục
          </div>
        </div>

        <!-- Table -->
        <div class="table-responsive">
          <table class="custom-table">
            <thead>
              <tr>
                <th style="width: 80px;">MÃ ID</th>
                <th>TÊN NHÓM HÀNG / DANH MỤC</th>
                <th>MÔ TẢ CHI TIẾT</th>
                <th style="text-align: center; width: 160px;">SỐ LƯỢNG MẶT HÀNG</th>
                <th style="text-align: right; width: 160px;">THAO TÁC</th>
              </tr>
            </thead>
            <tbody>
              <c:choose>
                <c:when test="${not empty categories}">
                  <c:forEach items="${categories}" var="c">
                    <tr>
                      <td style="font-weight: 700; color: #64748b;">#${c.categoryId}</td>
                      <td>
                        <div style="font-weight: 700; color: #0f172a; font-size: 0.95rem;">
                          <c:out value="${c.categoryName}" />
                        </div>
                      </td>
                      <td style="color: #64748b; font-size: 0.85rem;">
                        <c:out value="${not empty c.description ? c.description : 'Chưa có mô tả'}" />
                      </td>
                      <td style="text-align: center;">
                        <span class="badge badge-primary" style="font-size: 0.8rem; padding: 4px 10px;">
                          ${c.productCount} sản phẩm
                        </span>
                      </td>
                      <td style="text-align: right;">
                        <div style="display: inline-flex; gap: 6px; justify-content: flex-end;">
                          <button type="button" class="btn btn-outline" style="padding: 5px 12px; font-size: 0.8rem;"
                                  onclick="openEditCategoryModal(${c.categoryId}, '<c:out value="${c.categoryName}"/>', '<c:out value="${c.description}"/>')">
                            <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M11 4H4a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 013 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                            <span>Sửa</span>
                          </button>
                          <c:if test="${c.categoryId != 1}">
                            <button type="button" class="btn btn-outline" style="padding: 5px 10px; font-size: 0.8rem; color: #dc2626; border-color: #fecaca; background: #fff5f5;"
                                    onclick="openDeleteCategoryModal(${c.categoryId}, '<c:out value="${c.categoryName}"/>', ${c.productCount})">
                              <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
                              <span>Xóa</span>
                            </button>
                          </c:if>
                        </div>
                      </td>
                    </tr>
                  </c:forEach>
                </c:when>
                <c:otherwise>
                  <tr>
                    <td colspan="5" style="text-align: center; padding: 48px; color: #94a3b8;">
                      Chưa có danh mục nhóm hàng nào.
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
     MODAL: THÊM / SỬA DANH MỤC
     ========================================================================== -->
<div class="modal-backdrop" id="categoryModal" style="display: none;">
  <div class="modal-window" style="max-width: 520px; width: 92%;">
    <div class="modal-header">
      <div>
        <h3 class="modal-title" id="categoryModalTitle">Thêm danh mục mới</h3>
        <div class="modal-sub">Cấu trúc nhóm hàng hóa trong kho &amp; quầy bán</div>
      </div>
      <button type="button" class="modal-close" onclick="closeModal('categoryModal')">&times;</button>
    </div>

    <form action="${pageContext.request.contextPath}/categories" method="POST">
      <input type="hidden" name="action" value="save">
      <input type="hidden" name="categoryId" id="modalCategoryId" value="">

      <div class="modal-body" style="padding: 20px 24px;">
        <div class="form-group" style="margin-bottom: 14px;">
          <label class="form-label" for="modalCategoryName">Tên danh mục / Nhóm hàng *</label>
          <input type="text" id="modalCategoryName" name="categoryName" class="form-input" placeholder="Ví dụ: Phụ kiện thời trang, Giày dép..." required>
        </div>

        <div class="form-group" style="margin-bottom: 0;">
          <label class="form-label" for="modalCategoryDesc">Mô tả nhóm hàng</label>
          <textarea id="modalCategoryDesc" name="description" class="form-input" rows="3" placeholder="Mô tả tóm tắt về loại sản phẩm thuộc nhóm này..."></textarea>
        </div>
      </div>

      <div class="modal-footer" style="padding: 16px 24px; border-top: 1px solid var(--border); display: flex; justify-content: flex-end; gap: 10px;">
        <button type="button" class="btn btn-outline" onclick="closeModal('categoryModal')">Hủy bỏ</button>
        <button type="submit" class="btn btn-primary" id="categoryModalSubmitBtn">Lưu danh mục</button>
      </div>
    </form>
  </div>
</div>

<!-- ==========================================================================
     MODAL: XÁC NHẬN XÓA DANH MỤC
     ========================================================================== -->
<div class="modal-backdrop" id="deleteCategoryModal" style="display: none;">
  <div class="modal-window" style="max-width: 440px; width: 90%;">
    <div class="modal-header">
      <h3 class="modal-title" style="color: #dc2626;">Xác nhận xóa danh mục</h3>
      <button type="button" class="modal-close" onclick="closeModal('deleteCategoryModal')">&times;</button>
    </div>
    <form action="${pageContext.request.contextPath}/categories" method="POST">
      <input type="hidden" name="action" value="delete">
      <input type="hidden" name="categoryId" id="deleteCategoryId" value="">

      <div class="modal-body" style="padding: 20px 24px; font-size: 0.9rem; color: #475569; line-height: 1.5;">
        Bạn có chắc muốn xóa nhóm hàng <strong id="deleteCategoryName" style="color: #0f172a;"></strong>?<br>
        <span id="deleteCategoryWarning" style="color: #b45309; font-size: 0.825rem; margin-top: 6px; display: block;"></span>
      </div>
      <div class="modal-footer" style="padding: 14px 24px; display: flex; justify-content: flex-end; gap: 10px; border-top: 1px solid var(--border);">
        <button type="button" class="btn btn-outline" onclick="closeModal('deleteCategoryModal')">Hủy</button>
        <button type="submit" class="btn btn-primary" style="background: #dc2626; border-color: #dc2626;">Đồng ý xóa</button>
      </div>
    </form>
  </div>
</div>

<script>
  function openNewCategoryModal() {
    document.getElementById('categoryModalTitle').textContent = 'Thêm danh mục mới';
    document.getElementById('modalCategoryId').value = '';
    document.getElementById('modalCategoryName').value = '';
    document.getElementById('modalCategoryDesc').value = '';
    document.getElementById('categoryModalSubmitBtn').textContent = 'Thêm mới';
    document.getElementById('categoryModal').style.display = 'flex';
  }

  function openEditCategoryModal(id, name, desc) {
    document.getElementById('categoryModalTitle').textContent = 'Chỉnh sửa: ' + name;
    document.getElementById('modalCategoryId').value = id;
    document.getElementById('modalCategoryName').value = name;
    document.getElementById('modalCategoryDesc').value = desc !== 'null' ? desc : '';
    document.getElementById('categoryModalSubmitBtn').textContent = 'Cập nhật';
    document.getElementById('categoryModal').style.display = 'flex';
  }

  function openDeleteCategoryModal(id, name, count) {
    document.getElementById('deleteCategoryId').value = id;
    document.getElementById('deleteCategoryName').textContent = name;
    const warning = document.getElementById('deleteCategoryWarning');
    if (count > 0) {
      warning.textContent = 'Lưu ý: Đang có ' + count + ' sản phẩm thuộc nhóm này. Khi xóa, các sản phẩm sẽ được tự động chuyển về danh mục mặc định #1.';
    } else {
      warning.textContent = 'Danh mục này chưa có sản phẩm nào liên kết.';
    }
    document.getElementById('deleteCategoryModal').style.display = 'flex';
  }

  function closeModal(modalId) {
    document.getElementById(modalId).style.display = 'none';
  }
</script>

<jsp:include page="/common/footer.jsp" />
</body>
</html>
