<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="userRole" value="${empty sessionScope.userRole ? (empty sessionScope.user.role ? (empty currentRole ? 'manager' : currentRole) : sessionScope.user.role.toLowerCase()) : sessionScope.userRole.toLowerCase()}" />
<c:set var="isStaff" value="${userRole eq 'staff'}" />
<c:set var="activeMenu" value="products" />
<c:set var="breadcrumbCurrent" value="Hàng hóa" />

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Quản lý hàng hóa · Kiotflow</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>

<div class="app-container">
  <jsp:include page="/common/sidebar.jsp">
    <jsp:param name="activeMenu" value="products" />
  </jsp:include>

  <div class="main-content">
    <jsp:include page="/common/header.jsp">
      <jsp:param name="breadcrumbCurrent" value="Hàng hóa" />
    </jsp:include>

    <div class="page-body">
      <!-- Page Top Header -->
      <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 24px;">
        <div>
          <h1 style="font-size: 1.85rem; font-weight: 800; color: #0f172a; letter-spacing: -0.02em;">Danh mục hàng hóa</h1>
          <div style="font-size: 0.85rem; color: #64748b; margin-top: 4px;">
            ${totalProductsCount != null ? totalProductsCount : 0} sản phẩm · ${totalUnits != null ? totalUnits : 0} đơn vị tồn kho · Giá trị vốn <fmt:formatNumber value="${totalInventoryCapital != null ? totalInventoryCapital : 0}" pattern="#,###"/> đ
          </div>
        </div>
        <div style="display: flex; gap: 10px;">
          <a href="${pageContext.request.contextPath}/products" class="btn btn-outline" title="Làm mới danh sách">
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="23 4 23 10 17 10"/><polyline points="1 20 1 14 7 14"/><path d="M3.51 9a9 9 0 0114.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0020.49 15"/></svg>
            <span>Đồng bộ</span>
          </a>
          <button type="button" class="btn btn-outline" onclick="alert('Đang trích xuất danh sách hàng hóa ra file Excel...')">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4M7 10l5 5 5-5M12 15V3"/></svg>
            <span>Xuất danh sách</span>
          </button>
          <c:if test="${!isStaff}">
            <button type="button" class="btn btn-primary" onclick="openNewProductModal()">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
              <span>Thêm hàng hóa</span>
            </button>
          </c:if>
        </div>
      </div>

      <!-- PRODUCTS INVENTORY TABLE VIEW -->
      <div class="card">
        <!-- Filter Bar -->
        <div style="padding: 18px 20px; display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--border); flex-wrap: wrap; gap: 12px;">
          <div style="display: flex; gap: 12px; align-items: center; flex: 1; max-width: 650px;">
            <div class="input-icon-wrapper" style="flex: 1;">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
              <input type="text" class="form-input" placeholder="Tìm tên sản phẩm hoặc SKU..." id="filterProductInput" oninput="filterProductTable(this.value)">
            </div>
            <select class="form-select" style="width: 180px;" onchange="filterByCategory(this.value)">
              <option value="">Tất cả nhóm hàng</option>
              <option value="Áo sơ mi">Áo sơ mi</option>
              <option value="Áo thun">Áo thun / Polo</option>
              <option value="Quần">Quần Jeans / Tây</option>
              <option value="Váy đầm">Váy đầm</option>
              <option value="Áo khoác">Áo khoác</option>
            </select>
          </div>
          <div>
            <span style="font-size: 0.8rem; color: #64748b;">
              Cảnh báo chạm đáy: <strong style="color: #dc2626;">${lowStockCount != null ? lowStockCount : 0} SP</strong>
            </span>
          </div>
        </div>

        <!-- Table -->
        <div class="table-responsive">
          <table class="custom-table" id="productsTable">
            <thead>
              <tr>
                <th style="width: 60px;">ẢNH</th>
                <th>MÃ SKU</th>
                <th>TÊN HÀNG HÓA</th>
                <th>NHÓM HÀNG</th>
                <th>SIZE / MÀU</th>
                <th>ĐƠN VỊ</th>
                <th style="text-align: right;">GIÁ VỐN</th>
                <th style="text-align: right;">GIÁ BÁN</th>
                <th style="text-align: center;">TỒN KHO</th>
                <th style="text-align: center;">TỒN TỐI THIỂU</th>
                <th style="text-align: center;">TRẠNG THÁI</th>
                <c:if test="${!isStaff}">
                  <th style="text-align: right;">THAO TÁC</th>
                </c:if>
              </tr>
            </thead>
            <tbody>
              <c:choose>
                <c:when test="${not empty products}">
                  <c:forEach items="${products}" var="p">
                    <tr class="product-row" data-name="${p.name}" data-sku="${p.sku}" data-category="${p.category}">
                      <td>
                        <div style="width: 40px; height: 40px; border-radius: 8px; background: #f1f5f9; display: flex; align-items: center; justify-content: center; overflow: hidden; border: 1px solid #e2e8f0;">
                          <c:choose>
                            <c:when test="${not empty p.imageUrl and (p.imageUrl.startsWith('http://') or p.imageUrl.startsWith('https://'))}">
                              <img src="${p.imageUrl}" alt="${p.name}" style="width: 100%; height: 100%; object-fit: cover;">
                            </c:when>
                            <c:otherwise>
                              <span style="font-size: 1.1rem; color: #475569; font-weight: 700;">👕</span>
                            </c:otherwise>
                          </c:choose>
                        </div>
                      </td>
                      <td style="font-weight: 700; color: #2563eb;">${p.sku}</td>
                      <td>
                        <div style="font-weight: 600; color: #0f172a;">${p.name}</div>
                      </td>
                      <td>
                        <span class="badge" style="background: #f1f5f9; color: #475569;">${p.category}</span>
                      </td>
                      <td style="font-size: 0.85rem; color: #334155;">
                        ${not empty p.spec ? p.spec : 'M · Tiêu chuẩn'}
                      </td>
                      <td>${p.unit != null ? p.unit : 'Cái'}</td>
                      <td style="text-align: right; font-weight: 500; color: #64748b;">
                        <fmt:formatNumber value="${p.costPrice}" pattern="#,###"/> đ
                      </td>
                      <td style="text-align: right; font-weight: 700; color: #0f172a;">
                        <fmt:formatNumber value="${p.price}" pattern="#,###"/> đ
                      </td>
                      <td style="text-align: center; font-weight: 700; ${p.stockQuantity <= p.minStock ? 'color: #dc2626;' : 'color: #059669;'}">
                        ${p.stockQuantity}
                      </td>
                      <td style="text-align: center; color: #64748b;">${p.minStock}</td>
                      <td style="text-align: center;">
                        <c:choose>
                          <c:when test="${p.stockQuantity <= p.minStock}">
                            <span class="badge badge-danger">Chạm đáy</span>
                          </c:when>
                          <c:otherwise>
                            <span class="badge badge-success">An toàn</span>
                          </c:otherwise>
                        </c:choose>
                      </td>
                      <c:if test="${!isStaff}">
                        <td style="text-align: right;">
                          <button type="button" class="btn btn-outline" style="padding: 5px 12px; font-size: 0.8rem;" 
                                  onclick="openEditModal('${p.sku}', '${p.name}', '${p.category}', '${p.unit}', '${p.spec}', ${p.costPrice}, ${p.price}, ${p.stockQuantity}, ${p.minStock}, '${p.imageUrl}')">
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M11 4H4a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 013 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                            <span>Sửa</span>
                          </button>
                        </td>
                      </c:if>
                    </tr>
                  </c:forEach>
                </c:when>
                <c:otherwise>
                  <tr>
                    <td colspan="${isStaff ? 11 : 12}" style="text-align: center; padding: 48px; color: #94a3b8;">
                      Chưa có sản phẩm nào trong kho hàng.
                    </td>
                  </tr>
                </c:otherwise>
              </c:choose>
            </tbody>
          </table>
        </div>

        <!-- Pagination Bar -->
        <div style="display: flex; justify-content: space-between; align-items: center; padding: 16px 20px; border-top: 1px solid var(--border); font-size: 0.8rem; color: #64748b;">
          <div>Hiển thị ${products != null ? products.size() : 0} sản phẩm trong kho</div>
        </div>
      </div>
    </div>
  </div>
</div>

<!-- ==========================================================================
     MODAL: CHỈNH SỬA & THÊM HÀNG HÓA (CHỈ QUẢN LÝ)
     ========================================================================== -->
<c:if test="${!isStaff}">
<div class="modal-backdrop" id="productEditModal" style="display: none;">
  <div class="modal-window" style="max-width: 780px; width: 92%; max-height: 90vh; overflow-y: auto;">
    <div class="modal-header">
      <div>
        <h3 class="modal-title" id="modalProductTitle">Thông tin hàng hóa</h3>
        <div class="modal-sub" id="modalProductSubtitle">Cập nhật thông tin trong danh mục</div>
      </div>
      <button type="button" class="modal-close" onclick="closeModal('productEditModal')">&times;</button>
    </div>

    <form action="${pageContext.request.contextPath}/products" method="POST">
      <input type="hidden" name="action" value="save">
      <div class="modal-body" style="padding: 20px 24px;">
        <!-- Hàng 1: Mã SKU & Tên sản phẩm -->
        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 14px;">
          <div class="form-group" style="margin-bottom: 0;">
            <label class="form-label" for="modalProductSku">Mã SKU *</label>
            <input type="text" id="modalProductSku" name="sku" class="form-input" placeholder="Ví dụ: SM03" required>
          </div>
          <div class="form-group" style="margin-bottom: 0;">
            <label class="form-label" for="modalProductName">Tên sản phẩm *</label>
            <input type="text" id="modalProductName" name="name" class="form-input" placeholder="Ví dụ: Áo Sơ Mi Lụa Hàn Quốc" required>
          </div>
        </div>

        <!-- Hàng 2: Nhóm hàng & Đơn vị tính -->
        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 14px;">
          <div class="form-group" style="margin-bottom: 0;">
            <label class="form-label" for="modalProductCategory">Nhóm hàng thời trang</label>
            <select id="modalProductCategory" name="category" class="form-select">
              <option value="Áo sơ mi">Áo sơ mi</option>
              <option value="Áo thun">Áo thun / Polo</option>
              <option value="Quần">Quần Jeans / Quần Tây</option>
              <option value="Váy đầm">Váy đầm</option>
              <option value="Áo khoác">Áo khoác</option>
            </select>
          </div>
          <div class="form-group" style="margin-bottom: 0;">
            <label class="form-label" for="modalProductUnit">Đơn vị tính</label>
            <input type="text" id="modalProductUnit" name="unit" class="form-input" value="Cái" placeholder="Cái, Bộ, Chiếc">
          </div>
        </div>

        <!-- Hàng 3: Kích cỡ (Size) và Màu sắc (Color) -->
        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 14px;">
          <div class="form-group" style="margin-bottom: 0;">
            <label class="form-label" for="modalProductSize">Kích cỡ (Size)</label>
            <select id="modalProductSize" name="size" class="form-select">
              <option value="S">Size S</option>
              <option value="M" selected>Size M</option>
              <option value="L">Size L</option>
              <option value="XL">Size XL</option>
              <option value="XXL">Size XXL</option>
              <option value="29">Size 29</option>
              <option value="30">Size 30</option>
              <option value="31">Size 31</option>
              <option value="32">Size 32</option>
              <option value="Freesize">Freesize</option>
            </select>
          </div>
          <div class="form-group" style="margin-bottom: 0;">
            <label class="form-label" for="modalProductColor">Màu sắc (Color)</label>
            <input type="text" id="modalProductColor" name="color" class="form-input" placeholder="Ví dụ: Trắng, Đen, Be, Xanh Navy">
          </div>
        </div>

        <!-- Hàng 4: Giá nhập & Giá bán -->
        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 14px;">
          <div class="form-group" style="margin-bottom: 0;">
            <label class="form-label" for="modalProductCost">Giá nhập (đ) *</label>
            <input type="number" id="modalProductCost" name="costPrice" class="form-input" placeholder="200000" required>
          </div>
          <div class="form-group" style="margin-bottom: 0;">
            <label class="form-label" for="modalProductPrice">Giá bán (đ) *</label>
            <input type="number" id="modalProductPrice" name="price" class="form-input" placeholder="350000" required>
          </div>
        </div>

        <!-- Hàng 5: Tồn kho hiện tại & Mức tồn tối thiểu -->
        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 14px;">
          <div class="form-group" style="margin-bottom: 0;">
            <label class="form-label" for="modalProductStock">Tồn kho hiện tại *</label>
            <input type="number" id="modalProductStock" name="stockQuantity" class="form-input" value="30" required>
          </div>
          <div class="form-group" style="margin-bottom: 0;">
            <label class="form-label" for="modalProductMinStock">Mức tồn tối thiểu *</label>
            <input type="number" id="modalProductMinStock" name="minStock" class="form-input" value="5" required>
          </div>
        </div>

        <!-- Hàng 6: Link hình ảnh (URL trên mạng hoặc để trống) -->
        <div class="form-group" style="margin-bottom: 10px;">
          <label class="form-label" for="modalProductImageUrl">Link hình ảnh (URL mạng hoặc để trống)</label>
          <input type="text" id="modalProductImageUrl" name="imageUrl" class="form-input" placeholder="https://... hoặc để trống">
          <div style="font-size: 0.72rem; color: #94a3b8; margin-top: 4px;">Bạn có thể dán link ảnh trực tuyến từ web hoặc để trống.</div>
        </div>
      </div>

      <div class="modal-footer">
        <button type="button" class="btn btn-outline" onclick="closeModal('productEditModal')">Hủy</button>
        <button type="submit" class="btn btn-primary">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
          <span>Lưu thông tin</span>
        </button>
      </div>
    </form>
  </div>
</div>
</c:if>

<script>
  function openNewProductModal() {
    document.getElementById('modalProductTitle').textContent = 'Thêm hàng hóa mới';
    document.getElementById('modalProductSubtitle').textContent = 'Tạo sản phẩm mới trong kho hàng SQL Server';
    document.getElementById('modalProductSku').value = '';
    document.getElementById('modalProductSku').readOnly = false;
    document.getElementById('modalProductName').value = '';
    document.getElementById('modalProductColor').value = '';
    document.getElementById('modalProductCost').value = '';
    document.getElementById('modalProductPrice').value = '';
    document.getElementById('modalProductStock').value = '20';
    document.getElementById('modalProductMinStock').value = '5';
    document.getElementById('modalProductImageUrl').value = '';
    document.getElementById('productEditModal').style.display = 'flex';
  }

  function openEditModal(sku, name, category, unit, spec, cost, price, stock, minStock, img) {
    document.getElementById('modalProductTitle').textContent = 'Chỉnh sửa: ' + name;
    document.getElementById('modalProductSubtitle').textContent = 'Mã SKU: ' + sku;
    document.getElementById('modalProductSku').value = sku;
    document.getElementById('modalProductSku').readOnly = true;
    document.getElementById('modalProductName').value = name;
    document.getElementById('modalProductCategory').value = category;
    document.getElementById('modalProductUnit').value = unit || 'Cái';
    document.getElementById('modalProductCost').value = cost;
    document.getElementById('modalProductPrice').value = price;
    document.getElementById('modalProductStock').value = stock;
    document.getElementById('modalProductMinStock').value = minStock;
    document.getElementById('modalProductImageUrl').value = (img && !img.endsWith('.svg')) ? img : '';

    if (spec) {
      if (spec.includes('Size S')) document.getElementById('modalProductSize').value = 'S';
      else if (spec.includes('Size M') || spec.startsWith('M')) document.getElementById('modalProductSize').value = 'M';
      else if (spec.includes('Size L') || spec.startsWith('L')) document.getElementById('modalProductSize').value = 'L';
      else if (spec.includes('Size XL') || spec.startsWith('XL')) document.getElementById('modalProductSize').value = 'XL';
      else if (spec.includes('Size XXL')) document.getElementById('modalProductSize').value = 'XXL';
      else if (spec.includes('31')) document.getElementById('modalProductSize').value = '31';
      else if (spec.includes('32')) document.getElementById('modalProductSize').value = '32';
      
      const parts = spec.split('·');
      if (parts.length > 1) {
        document.getElementById('modalProductColor').value = parts[1].trim();
      } else {
        const hyphenParts = spec.split('-');
        if (hyphenParts.length > 1) {
          document.getElementById('modalProductColor').value = hyphenParts[1].trim();
        }
      }
    }
    document.getElementById('productEditModal').style.display = 'flex';
  }

  function closeModal(id) {
    document.getElementById(id).style.display = 'none';
  }

  function filterProductTable(query) {
    const q = query.trim().toLowerCase();
    document.querySelectorAll('.product-row').forEach(row => {
      const name = (row.getAttribute('data-name') || '').toLowerCase();
      const sku = (row.getAttribute('data-sku') || '').toLowerCase();
      row.style.display = (name.includes(q) || sku.includes(q)) ? '' : 'none';
    });
  }

  function filterByCategory(cat) {
    document.querySelectorAll('.product-row').forEach(row => {
      const rowCat = row.getAttribute('data-category') || '';
      row.style.display = (!cat || rowCat.includes(cat)) ? '' : 'none';
    });
  }
</script>

<jsp:include page="/common/footer.jsp" />
</body>
</html>
