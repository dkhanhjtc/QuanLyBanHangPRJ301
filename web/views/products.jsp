<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="activeMenu" value="products" />
<c:set var="breadcrumbCurrent" value="Hàng hóa" />

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Quản lý hàng hóa · Kiotflow</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
  <script>
    window.CONTEXT_PATH = "${pageContext.request.contextPath}";
  </script>
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
          <h1 style="font-size: 1.85rem; font-weight: 800; color: #0f172a; letter-spacing: -0.02em;">Quản lý hàng hóa</h1>
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
          <button type="button" class="btn btn-primary" onclick="openNewProductModal()">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
            <span>Thêm hàng hóa</span>
          </button>
        </div>
      </div>

      <!-- Tab Buttons Navigation -->
      <div class="sub-nav-tabs">
        <button type="button" class="sub-nav-tab active" id="tabBtnProducts" onclick="switchProductTab('products')">
          <span>Hàng hóa</span>
        </button>
        <button type="button" class="sub-nav-tab" id="tabBtnApprovals" onclick="switchProductTab('approvals')">
          <span>Duyệt hàng về</span>
          <span class="badge badge-primary" style="font-size: 0.7rem; padding: 2px 7px;">${pendingPOCount != null ? pendingPOCount : 0}</span>
        </button>
      </div>

      <!-- ====================================================================
           TAB 1: PRODUCTS INVENTORY TABLE VIEW
           ==================================================================== -->
      <div id="productsTableView">
        <div class="card">
          <!-- Filter Bar -->
          <div style="padding: 18px 20px; display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--border); flex-wrap: wrap; gap: 12px;">
            <div style="display: flex; gap: 12px; align-items: center; flex: 1; max-width: 650px;">
              <div class="input-icon-wrapper" style="flex: 1;">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                <input type="text" class="form-input" placeholder="Tìm tên sản phẩm hoặc SKU..." id="filterProductInput" oninput="filterProductTable(this.value)">
              </div>
              <select class="form-select" style="width: auto; font-size: 0.85rem;" onchange="location.href='${pageContext.request.contextPath}/products?category=' + this.value">
                <option value="all" ${param.category == null || param.category eq 'all' ? 'selected' : ''}>Tất cả nhóm hàng</option>
                <option value="coffee" ${param.category eq 'coffee' ? 'selected' : ''}>Cà phê &amp; trà</option>
                <option value="drinks" ${param.category eq 'drinks' ? 'selected' : ''}>Đồ uống</option>
                <option value="food" ${param.category eq 'food' ? 'selected' : ''}>Thực phẩm</option>
              </select>
            </div>
            <div>
              <span class="badge" style="background: #fef2f2; color: #ef4444; font-size: 0.8rem; padding: 6px 12px; font-weight: 700;">
                ${lowStockCount != null ? lowStockCount : 0} hàng chạm đáy
              </span>
            </div>
          </div>

          <!-- Inventory Table (Truy vấn từ CSDL, Không hardcode) -->
          <div class="table-responsive">
            <table class="custom-table" id="productMasterTable">
              <thead>
                <tr>
                  <th style="width: 50px;">Ảnh</th>
                  <th>SKU</th>
                  <th>Tên sản phẩm</th>
                  <th>Giá nhập</th>
                  <th>Giá bán</th>
                  <th>Tồn kho</th>
                  <th>Tối thiểu</th>
                  <th>Trạng thái</th>
                  <th style="text-align: right;">Thao tác</th>
                </tr>
              </thead>
              <tbody>
                <c:choose>
                  <c:when test="${not empty products}">
                    <c:forEach items="${products}" var="p">
                      <tr class="product-data-row" data-name="${p.name}" data-sku="${p.sku}">
                        <td>
                          <img src="${pageContext.request.contextPath}/assets/images/${p.imageUrl != null ? p.imageUrl : 'CF01.svg'}" alt="${p.name}" style="width: 36px; height: 36px; border-radius: 6px; object-fit: cover;">
                        </td>
                        <td style="font-weight: 600; color: #0f172a;">${p.sku}</td>
                        <td>
                          <div style="font-weight: 600; color: #0f172a;">${p.name}</div>
                          <div style="font-size: 0.72rem; color: #64748b;">${p.spec != null ? p.spec : p.unit} · ${p.category}</div>
                        </td>
                        <td><fmt:formatNumber value="${p.costPrice}" pattern="#,###"/> đ</td>
                        <td style="font-weight: 600;"><fmt:formatNumber value="${p.price}" pattern="#,###"/> đ</td>
                        
                        <!-- Reactive Stock Quantity highlighting -->
                        <td style="font-weight: 700; ${p.stockQuantity <= p.minStock ? 'color: #ef4444;' : 'color: #0f172a;'}">
                          ${p.stockQuantity}
                        </td>
                        <td>${p.minStock}</td>
                        <td>
                          <c:choose>
                            <c:when test="${p.stockQuantity <= p.minStock}">
                              <span class="badge badge-danger">Chạm đáy</span>
                            </c:when>
                            <c:otherwise>
                              <span class="badge badge-success">Đủ hàng</span>
                            </c:otherwise>
                          </c:choose>
                        </td>
                        <td style="text-align: right;">
                          <button type="button" class="btn btn-outline" style="padding: 4px 8px;" onclick="openProductEditModal('${p.sku}', '${p.name}', '${p.category}', '${p.unit}', '${p.costPrice}', '${p.price}', '${p.stockQuantity}', '${p.minStock}', '${not empty p.imageUrl ? p.imageUrl : ''}')" title="Chỉnh sửa">
                            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 013 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>
                          </button>
                        </td>
                      </tr>
                    </c:forEach>
                  </c:when>
                  <c:otherwise>
                    <tr>
                      <td colspan="9" style="text-align: center; padding: 48px 10px; color: #94a3b8;">
                        <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" style="margin-bottom:8px;"><rect x="2" y="7" width="20" height="14" rx="2"/><path d="M16 21V5a2 2 0 00-2-2h-4a2 2 0 00-2 2v16"/></svg>
                        <div style="font-weight: 600;">Không tìm thấy sản phẩm nào trong kho</div>
                        <div style="font-size: 0.75rem;">Nhấn "Thêm hàng hóa" để thêm sản phẩm mới vào danh mục</div>
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

        <!-- Footnote Info -->
        <div style="display: flex; align-items: center; gap: 8px; font-size: 0.8rem; color: #64748b; margin-top: 16px;">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
          <span>Nhãn “Chạm đáy” xuất hiện khi Tồn kho &le; Mức tồn tối thiểu. Chỉ hàng về đã duyệt mới được cộng vào tồn kho.</span>
        </div>
      </div>

      <!-- ====================================================================
           TAB 2: STOCK INFLOW APPROVALS VIEW (DUYỆT HÀNG VỀ)
           ==================================================================== -->
      <div id="approvalsTableView" style="display: none;">
        <!-- 3 Stat Cards -->
        <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; margin-bottom: 20px;">
          <div class="card" style="padding: 20px; display: flex; align-items: center; gap: 16px;">
            <div style="width: 44px; height: 44px; border-radius: 10px; background: #eff6ff; color: #2563eb; display: flex; align-items: center; justify-content: center;">
              <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/></svg>
            </div>
            <div>
              <div style="font-size: 0.75rem; color: #64748b;">Phiếu chờ duyệt</div>
              <div style="font-size: 1.5rem; font-weight: 800; color: #0f172a;">${pendingPOCount != null ? pendingPOCount : 0} phiếu</div>
            </div>
          </div>

          <div class="card" style="padding: 20px; display: flex; align-items: center; gap: 16px;">
            <div style="width: 44px; height: 44px; border-radius: 10px; background: #eff6ff; color: #2563eb; display: flex; align-items: center; justify-content: center;">
              <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="7" width="20" height="14" rx="2"/><path d="M16 21V5a2 2 0 00-2-2h-4a2 2 0 00-2 2v16"/></svg>
            </div>
            <div>
              <div style="font-size: 0.75rem; color: #64748b;">Số lượng chờ nhập</div>
              <div style="font-size: 1.5rem; font-weight: 800; color: #0f172a;">${pendingQty != null ? pendingQty : 0} đơn vị</div>
            </div>
          </div>

          <div class="card" style="padding: 20px; display: flex; align-items: center; gap: 16px;">
            <div style="width: 44px; height: 44px; border-radius: 10px; background: #eff6ff; color: #2563eb; display: flex; align-items: center; justify-content: center;">
              <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="1" y="4" width="22" height="16" rx="2"/><line x1="1" y1="10" x2="23" y2="10"/></svg>
            </div>
            <div>
              <div style="font-size: 0.75rem; color: #64748b;">Tổng giá trị nhập đề nghị</div>
              <div style="font-size: 1.5rem; font-weight: 800; color: #0f172a;"><fmt:formatNumber value="${pendingCost != null ? pendingCost : 0}" pattern="#,###"/> <span style="text-decoration: underline;">đ</span></div>
            </div>
          </div>
        </div>

        <!-- Inflow Table Card (Truy vấn từ CSDL, Không hardcode) -->
        <div class="card" style="margin-bottom: 24px;">
          <div style="padding: 16px 20px; display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--border);">
            <div style="font-size: 0.95rem; font-weight: 700; color: #0f172a;">
              Danh sách phiếu hàng về chờ quyết định
            </div>
            <div style="font-size: 0.8rem; color: #64748b; font-weight: 500;">
              Chỉ Quản lý được duyệt
            </div>
          </div>

          <div class="table-responsive">
            <table class="custom-table">
              <thead>
                <tr>
                  <th>Phiếu nhập</th>
                  <th>Nhà cung cấp</th>
                  <th>Hàng thực nhận</th>
                  <th>Số lượng</th>
                  <th>Người gửi</th>
                  <th>Tồn sau duyệt</th>
                  <th style="text-align: right;">Quyết định</th>
                </tr>
              </thead>
              <tbody>
                <c:choose>
                  <c:when test="${not empty pendingPOs}">
                    <c:forEach items="${pendingPOs}" var="po">
                      <tr id="ticket-row-${po.code}">
                        <td>
                          <div style="font-weight: 700; color: #2563eb;">${po.code}</div>
                          <div style="font-size: 0.72rem; color: #64748b;">${po.formattedDate}</div>
                          <span class="badge badge-warning" style="margin-top: 4px; font-size: 0.7rem;">Chờ duyệt</span>
                        </td>
                        <td>
                          <div style="font-weight: 600; color: #0f172a;">${po.supplierName}</div>
                        </td>
                        <td>
                          <div style="font-weight: 600; color: #0f172a;">${po.productName}</div>
                          <div style="font-size: 0.72rem; color: #64748b;">${po.productId} · <fmt:formatNumber value="${po.totalCost}" pattern="#,###"/> đ</div>
                        </td>
                        <td style="font-weight: 700; color: #0f172a;">+${po.totalQuantity}</td>
                        <td style="color: #0f172a;">${po.createdByName}</td>
                        <td>
                          <div style="font-weight: 700; color: #2563eb;">${po.stockBefore} &rarr; ${po.stockAfter}</div>
                          <div style="font-size: 0.7rem; color: #94a3b8;">Chưa cộng kho</div>
                        </td>
                        <td style="text-align: right;">
                          <form action="${pageContext.request.contextPath}/products" method="POST" style="display:inline;">
                            <input type="hidden" name="action" value="approve_inflow">
                            <input type="hidden" name="poId" value="${po.id}">
                            <input type="hidden" name="poCode" value="${po.code}">
                            <button type="submit" class="btn btn-primary" style="padding: 6px 14px; font-size: 0.8rem;" onclick="return confirm('Xác nhận DUYỆT phiếu ${po.code} và cộng +${po.totalQuantity} vào tồn kho?')">
                              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                              <span>Duyệt</span>
                            </button>
                          </form>
                          <button type="button" class="btn btn-danger-outline" style="padding: 6px 14px; font-size: 0.8rem;" onclick="openRejectModal('${po.id}', '${po.code}', '${po.productName}', '${po.supplierName}', '${po.createdByName}', ${po.totalQuantity}, ${po.stockBefore})">
                            <span>Từ chối</span>
                          </button>
                        </td>
                      </tr>
                    </c:forEach>
                  </c:when>
                  <c:otherwise>
                    <tr>
                      <td colspan="7" style="text-align: center; padding: 48px 10px; color: #94a3b8;">
                        <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" style="margin-bottom:8px;"><polyline points="20 6 9 17 4 12"/></svg>
                        <div style="font-weight: 600;">Không có phiếu nhập kho nào đang chờ duyệt</div>
                        <div style="font-size: 0.75rem;">Khi có hàng về gửi từ nhà cung cấp, thông tin sẽ xuất hiện tại đây</div>
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
</div>

<!-- ==========================================================================
     MODAL: CHỈNH SỬA & THÊM HÀNG HÓA
     ========================================================================== -->
<div class="modal-backdrop" id="productEditModal">
  <div class="modal-window" style="max-width: 650px;">
    <div class="modal-header">
      <div>
        <h3 class="modal-title">Thông tin hàng hóa</h3>
        <div class="modal-sub" id="modalProductSubtitle">Cập nhật thông tin trong danh mục</div>
      </div>
      <button type="button" class="modal-close" onclick="closeModal('productEditModal')">&times;</button>
    </div>

    <form action="${pageContext.request.contextPath}/products" method="POST">
      <input type="hidden" name="action" value="save">
      <div class="modal-body">
        <!-- Form Rows Grid -->
        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 14px;">
          <div class="form-group">
            <label class="form-label" for="modalProductSku">Mã SKU *</label>
            <input type="text" id="modalProductSku" name="sku" class="form-input" placeholder="Ví dụ: CF01" required>
          </div>
          <div class="form-group">
            <label class="form-label" for="modalProductName">Tên sản phẩm *</label>
            <input type="text" id="modalProductName" name="name" class="form-input" placeholder="Ví dụ: Cà phê Arabica" required>
          </div>
        </div>

        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 14px;">
          <div class="form-group">
            <label class="form-label" for="modalProductCategory">Nhóm hàng thời trang</label>
            <select id="modalProductCategory" name="category" class="form-select">
              <option value="Áo sơ mi">Áo sơ mi</option>
              <option value="Áo thun">Áo thun / Polo</option>
              <option value="Quần">Quần Jeans / Quần Tây</option>
              <option value="Váy đầm">Váy đầm</option>
              <option value="Áo khoác">Áo khoác</option>
              <option value="Khác">Phụ kiện / Khác</option>
            </select>
          </div>
        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 14px;">
          <div class="form-group">
            <label class="form-label" for="modalProductUnit">Đơn vị tính</label>
            <input type="text" id="modalProductUnit" name="unit" class="form-input" placeholder="Ví dụ: Cái, Bộ, Chiếc">
          </div>
          <div class="form-group">
            <label class="form-label" for="modalProductSupplier">Nhà cung cấp / Xưởng may</label>
            <select id="modalProductSupplier" name="supplierId" class="form-select">
              <option value="">-- Chọn Nhà cung cấp --</option>
              <c:forEach items="${suppliers}" var="sup">
                <option value="${sup.supplierId}">${sup.supplierName} (${sup.supplierCode})</option>
              </c:forEach>
            </select>
          </div>
        </div>

        <!-- Biến thể Kích cỡ (Size) và Màu sắc (Color) cho thời trang -->
        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 14px;">
          <div class="form-group">
            <label class="form-label" for="modalProductSize">Kích cỡ (Size)</label>
            <select id="modalProductSize" name="size" class="form-select">
              <option value="">-- Chọn Size --</option>
              <option value="S">Size S</option>
              <option value="M">Size M</option>
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
          <div class="form-group">
            <label class="form-label" for="modalProductColor">Màu sắc (Color)</label>
            <input type="text" id="modalProductColor" name="color" class="form-input" placeholder="Ví dụ: Trắng, Đen, Be, Xanh Navy">
          </div>
        </div>

        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 14px;">
          <div class="form-group">
            <label class="form-label" for="modalProductCost">Giá nhập (đ) *</label>
            <input type="number" id="modalProductCost" name="costPrice" class="form-input" placeholder="85000" required>
          </div>
          <div class="form-group">
            <label class="form-label" for="modalProductPrice">Giá bán (đ) *</label>
            <input type="number" id="modalProductPrice" name="price" class="form-input" placeholder="125000" required>
          </div>
        </div>

        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 14px;">
          <div class="form-group">
            <label class="form-label" for="modalProductStock">Tồn kho hiện tại *</label>
            <input type="number" id="modalProductStock" name="stockQuantity" class="form-input" oninput="checkStockThresholdWarning()" required>
          </div>
          <div class="form-group">
            <label class="form-label" for="modalProductMinStock">Mức tồn tối thiểu *</label>
            <input type="number" id="modalProductMinStock" name="minStock" class="form-input" oninput="checkStockThresholdWarning()" required>
          </div>
        </div>

        <!-- Dynamic Stock Warning Banner -->
        <div id="modalStockWarning" style="display: none; align-items: center; gap: 10px; background: #fffbeb; border: 1px solid #fde68a; border-radius: 10px; padding: 12px 14px; margin-top: 8px; font-size: 0.8rem; color: #b45309;">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
          <span>Tồn kho hiện tại bằng hoặc dưới mức tối thiểu. Sản phẩm sẽ được gắn nhãn “Chạm đáy”.</span>
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

<!-- ==========================================================================
     MODAL: TỪ CHỐI PHIẾU NHẬP HÀNG (REJECTION REASON)
     ========================================================================== -->
<div class="modal-backdrop" id="rejectTicketModal">
  <div class="modal-window">
    <div class="modal-header">
      <div>
        <h3 class="modal-title">Từ chối phiếu <span id="rejectTicketIdTitle">PN-025</span></h3>
        <div class="modal-sub" id="rejectTicketSub">Nhập lý do từ chối phiếu hàng về</div>
      </div>
      <button type="button" class="modal-close" onclick="closeModal('rejectTicketModal')">&times;</button>
    </div>

    <form action="${pageContext.request.contextPath}/products" method="POST" id="rejectForm">
      <input type="hidden" name="action" value="reject_inflow">
      <input type="hidden" name="poId" id="rejectPoIdInput">
      <input type="hidden" name="poCode" id="rejectPoCodeInput">

      <div class="modal-body">
        <!-- Summary Box -->
        <div style="display: grid; grid-template-columns: 1fr 1fr; background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 12px; padding: 16px; margin-bottom: 20px;">
          <div>
            <div style="font-size: 0.75rem; color: #64748b;">Số lượng đề nghị</div>
            <div style="font-size: 1.35rem; font-weight: 800; color: #0f172a;" id="rejectQtyDisplay">0 đơn vị</div>
          </div>
          <div>
            <div style="font-size: 0.75rem; color: #64748b;">Tồn kho hiện tại</div>
            <div style="font-size: 1.35rem; font-weight: 800; color: #0f172a;" id="rejectStockDisplay">0 đơn vị</div>
          </div>
        </div>

        <!-- Textarea Reason with Validation -->
        <div class="form-group">
          <label class="form-label" for="rejectReasonInput">Lý do từ chối *</label>
          <textarea id="rejectReasonInput" name="rejectReason" class="form-textarea" rows="4" placeholder="Nhập lý do cụ thể để người gửi kiểm tra lại..." required></textarea>
        </div>

        <!-- Warning Box -->
        <div style="display: flex; align-items: flex-start; gap: 10px; background: #fffbeb; border: 1px solid #fde68a; border-radius: 10px; padding: 12px 14px; margin-top: 14px; font-size: 0.8rem; color: #b45309;">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="flex-shrink:0; margin-top:2px;"><path d="M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
          <div>Phiếu bị từ chối sẽ không cộng số lượng vào kho. Lý do được ghi lại trong Nhật ký hoạt động.</div>
        </div>
      </div>

      <div class="modal-footer">
        <button type="button" class="btn btn-outline" onclick="closeModal('rejectTicketModal')">Hủy</button>
        <button type="submit" class="btn btn-primary">Xác nhận từ chối</button>
      </div>
    </form>
  </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/products.js"></script>
<script>
  function openRejectModal(id, code, productName, supplier, sender, qty, currentStock) {
    document.getElementById('rejectPoIdInput').value = id;
    document.getElementById('rejectPoCodeInput').value = code;
    document.getElementById('rejectTicketIdTitle').textContent = code;
    document.getElementById('rejectTicketSub').textContent = productName + ' · Nhà cung cấp ' + supplier + ' · Người gửi: ' + sender;
    document.getElementById('rejectQtyDisplay').textContent = qty + ' đơn vị';
    document.getElementById('rejectStockDisplay').textContent = currentStock + ' đơn vị';
    document.getElementById('rejectReasonInput').value = '';
    openModal('rejectTicketModal');
  }

  function filterProductTable(query) {
    var q = query.trim().toLowerCase();
    var rows = document.querySelectorAll('.product-data-row');
    rows.forEach(function(row) {
      var name = (row.getAttribute('data-name') || '').toLowerCase();
      var sku = (row.getAttribute('data-sku') || '').toLowerCase();
      if (name.indexOf(q) !== -1 || sku.indexOf(q) !== -1) {
        row.style.display = '';
      } else {
        row.style.display = 'none';
      }
    });
  }
</script>
<jsp:include page="/common/footer.jsp" />
</body>
</html>
