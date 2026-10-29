<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="activeMenu" value="pos" />
<c:set var="currentRole" value="staff" />
<c:set var="breadcrumbCurrent" value="Bán hàng" />

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Quầy bán hàng (POS) · Kiotflow</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
  <script>
    window.CONTEXT_PATH = "${pageContext.request.contextPath}";
  </script>
  <style>
    .filter-tab-pill {
      padding: 6px 14px;
      border-radius: 9999px;
      font-size: 0.8rem;
      font-weight: 600;
      background: var(--surface);
      border: 1px solid var(--border);
      color: var(--text-secondary);
      cursor: pointer;
      transition: all 0.15s ease;
    }
    .filter-tab-pill:hover {
      background: var(--surface-alt);
      color: var(--text-main);
    }
    .filter-tab-pill.active {
      background: var(--primary);
      border-color: var(--primary);
      color: #ffffff;
    }
  </style>
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
      <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 20px;">
        <div>
          <h1 style="font-size: 1.75rem; font-weight: 800; color: #0f172a; letter-spacing: -0.02em;">Quầy bán hàng</h1>
          <div style="font-size: 0.85rem; color: #64748b; margin-top: 4px;">Ca sáng · 08:00–14:00 · 27/10/2026</div>
        </div>
        <div style="display: flex; gap: 10px;">
          <!-- Demo Toggle to test overstock simulation -->
          <button type="button" class="btn btn-outline" onclick="simulateOverstockDemo()" style="color:#d97706; border-color:#fde68a;" title="Nhấn để thử nghiệm kịch bản Vượt Tồn Kho theo mockup">
            <span>⚡ Demo Vượt tồn kho</span>
          </button>
          <button type="button" class="btn btn-outline" onclick="openShiftOrdersModal()">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="5" width="20" height="14" rx="2"/><line x1="2" y1="10" x2="22" y2="10"/></svg>
            <span>Đơn trong ca · 3</span>
          </button>
          <button type="button" class="btn btn-outline" onclick="if(confirm('Bạn có chắc chắn muốn kết ca làm việc hiện tại không?')) location.href='${pageContext.request.contextPath}/views/login.jsp'">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4M16 17l5-5-5-5M21 12H9"/></svg>
            <span>Kết ca</span>
          </button>
        </div>
      </div>

      <!-- POS Main Grid Split -->
      <div class="pos-container">
        <!-- LEFT COLUMN: CATALOG & SEARCH -->
        <div>
          <!-- Search Box & Scanner -->
          <div style="display: flex; gap: 10px; align-items: center;">
            <div class="input-icon-wrapper" style="flex: 1;">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
              <input type="text" class="form-input" placeholder="Tìm tên sản phẩm, SKU hoặc quét mã vạch..." oninput="searchProducts(this.value)">
            </div>
            <button type="button" class="icon-button" style="width: 42px; height: 42px;" title="Quét mã vạch" onclick="alert('Đã sẵn sàng kết nối máy quét mã vạch!')">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M3 7V5a2 2 0 012-2h2M17 3h2a2 2 0 012 2v2M21 17v2a2 2 0 01-2 2h-2M7 21H5a2 2 0 01-2-2v-2"/>
              </svg>
            </button>
          </div>

          <!-- Category Filter Pills -->
          <div style="display: flex; gap: 8px; margin-top: 14px;">
            <button type="button" class="filter-tab-pill active" onclick="filterCategory('all', this)">Tất cả · 8</button>
            <button type="button" class="filter-tab-pill" onclick="filterCategory('coffee', this)">Cà phê &amp; trà</button>
            <button type="button" class="filter-tab-pill" onclick="filterCategory('drinks', this)">Đồ uống</button>
            <button type="button" class="filter-tab-pill" onclick="filterCategory('food', this)">Thực phẩm</button>
          </div>

          <!-- Product Cards Grid -->
          <div class="pos-catalog-grid" id="productGridContainer">
            <c:choose>
              <%-- If servlet provided products list --%>
              <c:when test="${not empty products}">
                <c:forEach items="${products}" var="p">
                  <div class="product-card" data-category="${p.category}" data-name="${p.name}" data-sku="${p.sku}">
                    <div class="product-card-img-wrap">
                      <img src="${pageContext.request.contextPath}/assets/images/${p.image}" alt="${p.name}">
                    </div>
                    <div class="product-card-body">
                      <div class="product-title">${p.name}</div>
                      <div class="product-sku-spec">${p.spec} · ${p.sku}</div>
                      <div class="product-card-footer">
                        <div>
                          <div class="product-price"><fmt:formatNumber value="${p.price}" pattern="#,###"/> đ</div>
                          <c:choose>
                            <c:when test="${p.stockQuantity <= p.minStock}">
                              <div class="product-stock-tag low-stock">Có sẵn: ${p.stockQuantity} · Sắp hết</div>
                            </c:when>
                            <c:otherwise>
                              <div class="product-stock-tag">Có sẵn: ${p.stockQuantity}</div>
                            </c:otherwise>
                          </c:choose>
                        </div>
                        <button type="button" class="btn-add-circle" onclick="addToCart('${p.sku}')" title="Thêm vào giỏ">+</button>
                      </div>
                    </div>
                  </div>
                </c:forEach>
              </c:when>

              <%-- Standalone Mock Fallback (Guarantees immediate run) --%>
              <c:otherwise>
                <!-- 1. Cà phê Arabica -->
                <div class="product-card" data-category="coffee" data-name="Cà phê Arabica" data-sku="CF01">
                  <div class="product-card-img-wrap">
                    <img src="${pageContext.request.contextPath}/assets/images/CF01.svg" alt="Cà phê Arabica">
                  </div>
                  <div class="product-card-body">
                    <div class="product-title">Cà phê Arabica</div>
                    <div class="product-sku-spec">Gói 250g · CF01</div>
                    <div class="product-card-footer">
                      <div>
                        <div class="product-price">125.000 đ</div>
                        <div class="product-stock-tag">Có sẵn: 24</div>
                      </div>
                      <button type="button" class="btn-add-circle" onclick="addToCart('CF01')">+</button>
                    </div>
                  </div>
                </div>

                <!-- 2. Trà sen -->
                <div class="product-card" data-category="coffee" data-name="Trà sen" data-sku="TE01">
                  <div class="product-card-img-wrap">
                    <img src="${pageContext.request.contextPath}/assets/images/TE01.svg" alt="Trà sen">
                  </div>
                  <div class="product-card-body">
                    <div class="product-title">Trà sen</div>
                    <div class="product-sku-spec">Hộp 100g · TE01</div>
                    <div class="product-card-footer">
                      <div>
                        <div class="product-price">89.000 đ</div>
                        <div class="product-stock-tag">Có sẵn: 18</div>
                      </div>
                      <button type="button" class="btn-add-circle" onclick="addToCart('TE01')">+</button>
                    </div>
                  </div>
                </div>

                <!-- 3. Sữa yến mạch -->
                <div class="product-card" data-category="drinks" data-name="Sữa yến mạch" data-sku="MK01">
                  <div class="product-card-img-wrap">
                    <img src="${pageContext.request.contextPath}/assets/images/MK01.svg" alt="Sữa yến mạch">
                  </div>
                  <div class="product-card-body">
                    <div class="product-title">Sữa yến mạch</div>
                    <div class="product-sku-spec">Hộp 1L · MK01</div>
                    <div class="product-card-footer">
                      <div>
                        <div class="product-price">59.000 đ</div>
                        <div class="product-stock-tag low-stock">Có sẵn: 8 · Sắp hết</div>
                      </div>
                      <button type="button" class="btn-add-circle" onclick="addToCart('MK01')">+</button>
                    </div>
                  </div>
                </div>

                <!-- 4. Mật ong hoa nhãn -->
                <div class="product-card" data-category="food" data-name="Mật ong hoa nhãn" data-sku="HN01">
                  <div class="product-card-img-wrap">
                    <img src="${pageContext.request.contextPath}/assets/images/HN01.svg" alt="Mật ong hoa nhãn">
                  </div>
                  <div class="product-card-body">
                    <div class="product-title">Mật ong hoa nhãn</div>
                    <div class="product-sku-spec">Chai 500ml · HN01</div>
                    <div class="product-card-footer">
                      <div>
                        <div class="product-price">145.000 đ</div>
                        <div class="product-stock-tag">Có sẵn: 12</div>
                      </div>
                      <button type="button" class="btn-add-circle" onclick="addToCart('HN01')">+</button>
                    </div>
                  </div>
                </div>

                <!-- 5. Granola hạt -->
                <div class="product-card" data-category="food" data-name="Granola hạt" data-sku="GR01">
                  <div class="product-card-img-wrap">
                    <img src="${pageContext.request.contextPath}/assets/images/GR01.svg" alt="Granola hạt">
                  </div>
                  <div class="product-card-body">
                    <div class="product-title">Granola hạt</div>
                    <div class="product-sku-spec">Gói 300g · GR01</div>
                    <div class="product-card-footer">
                      <div>
                        <div class="product-price">99.000 đ</div>
                        <div class="product-stock-tag low-stock">Có sẵn: 6 · Sắp hết</div>
                      </div>
                      <button type="button" class="btn-add-circle" onclick="addToCart('GR01')">+</button>
                    </div>
                  </div>
                </div>

                <!-- 6. Bánh quy bơ -->
                <div class="product-card" data-category="food" data-name="Bánh quy bơ" data-sku="CK01">
                  <div class="product-card-img-wrap">
                    <img src="${pageContext.request.contextPath}/assets/images/CK01.svg" alt="Bánh quy bơ">
                  </div>
                  <div class="product-card-body">
                    <div class="product-title">Bánh quy bơ</div>
                    <div class="product-sku-spec">Hộp 200g · CK01</div>
                    <div class="product-card-footer">
                      <div>
                        <div class="product-price">65.000 đ</div>
                        <div class="product-stock-tag">Có sẵn: 32</div>
                      </div>
                      <button type="button" class="btn-add-circle" onclick="addToCart('CK01')">+</button>
                    </div>
                  </div>
                </div>
              </c:otherwise>
            </c:choose>
          </div>

          <!-- Pagination -->
          <div style="display: flex; justify-content: space-between; align-items: center; margin-top: 20px; font-size: 0.8rem; color: #64748b;">
            <div>Hiển thị 1–6 trong 8 sản phẩm</div>
            <div style="display: flex; gap: 6px;">
              <button type="button" class="btn btn-primary" style="padding: 4px 10px; font-size: 0.75rem;">1</button>
              <button type="button" class="btn btn-outline" style="padding: 4px 10px; font-size: 0.75rem;" onclick="filterCategory('drinks', null)">2</button>
              <button type="button" class="btn btn-outline" style="padding: 4px 8px; font-size: 0.75rem;">&gt;</button>
            </div>
          </div>

          <!-- Dynamic Overstock Warning Banner -->
          <div id="stockWarningBanner" style="display: none; align-items: center; gap: 10px; background: #fef2f2; border: 1px solid #fca5a5; border-radius: 10px; padding: 12px 16px; margin-top: 16px; color: #b91c1c; font-size: 0.85rem;">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
            <div>Không đủ tồn kho cho <strong id="overstockProdName">Sữa yến mạch</strong>. Giỏ hàng chưa được ghi nhận thành đơn.</div>
          </div>

          <!-- Bottom Notice -->
          <div style="display: flex; align-items: center; gap: 8px; background: #eff6ff; border: 1px solid #bfdbfe; border-radius: 10px; padding: 12px 16px; margin-top: 16px; font-size: 0.8rem; color: #1e40af;">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
            <span>Tồn khả dụng được kiểm tra trước thanh toán. Nhân viên chỉ được bán hàng trong phạm vi ca làm việc.</span>
          </div>
        </div>

        <!-- RIGHT COLUMN: REACTIVE CART -->
        <div class="pos-cart-panel" id="posCartPanel">
          <!-- Cart Header -->
          <div class="pos-cart-header">
            <div>
              <div style="display: flex; align-items: center; gap: 8px;">
                <h3 style="font-size: 1.1rem; font-weight: 700; color: #0f172a;">Đơn hàng mới</h3>
                <span class="badge badge-primary" id="cartItemCountBadge">4 sản phẩm</span>
              </div>
              <div style="font-size: 0.75rem; color: #64748b; margin-top: 2px;">Khách lẻ · Giá bán lẻ</div>
            </div>
            <a href="javascript:void(0)" onclick="alert('Tính năng chọn khách hàng thành viên')" style="font-size: 0.8rem; font-weight: 600;">Thêm khách hàng</a>
          </div>

          <!-- Items Scroll Area -->
          <div class="cart-items-list" id="cartItemsList">
            <!-- Rendered reactively by pos.js -->
          </div>

          <!-- Cart Financial Summary -->
          <div class="cart-summary">
            <div class="summary-row">
              <span>Tạm tính</span>
              <span id="cartSubtotal">408.000 đ</span>
            </div>
            <div class="summary-row">
              <span>Giảm giá</span>
              <span>0 đ</span>
            </div>

            <div class="summary-total">
              <span class="total-label">Tổng thanh toán</span>
              <span class="total-amount" id="cartTotal">408.000 đ</span>
            </div>

            <!-- Overstock Alert Text -->
            <div id="checkoutWarningText" style="display: none; font-size: 0.75rem; color: #dc2626; margin-bottom: 10px;">
              Điều chỉnh số lượng về mức tồn trước khi thanh toán.
            </div>

            <div style="font-size: 0.72rem; color: #64748b; margin-bottom: 12px;">
              Tổng tiền tự động cập nhật theo số lượng.
            </div>

            <!-- Checkout Action Button -->
            <button type="button" class="btn btn-primary" id="checkoutBtn" onclick="processCheckout()" style="width: 100%; padding: 14px;">
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="1" y="4" width="22" height="16" rx="2" ry="2"/><line x1="1" y1="10" x2="23" y2="10"/></svg>
              <span>Thanh toán · 408.000 đ</span>
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>

<!-- ==========================================================================
     MODAL 1: THANH TOÁN THÀNH CÔNG / IN HÓA ĐƠN
     ========================================================================== -->
<div class="modal-backdrop" id="invoiceModal">
  <div class="modal-window printable-receipt">
    <div class="modal-header no-print">
      <div>
        <h3 class="modal-title">Thanh toán thành công</h3>
        <div class="modal-sub">Hóa đơn #BH-1042 · 27/10/2026, 10:24</div>
      </div>
      <button type="button" class="modal-close" onclick="closeModal('invoiceModal')">&times;</button>
    </div>

    <div class="modal-body invoice-slip">
      <!-- Store Header -->
      <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 20px;">
        <div>
          <div class="store-brand">AN NHIÊN</div>
          <div style="font-size: 0.8rem; color: #64748b;">128 Nguyễn Trãi, TP. Hồ Chí Minh</div>
          <div style="font-size: 0.75rem; color: #64748b;">Thu ngân: Lê Lan Anh · Ca sáng 08:00–14:00</div>
        </div>
        <span class="badge badge-success" style="padding: 6px 12px;">Đã thanh toán</span>
      </div>

      <!-- Itemized Table -->
      <div style="border-top: 1px solid #e2e8f0; border-bottom: 1px solid #e2e8f0; padding: 10px 0; margin-bottom: 16px;">
        <div style="display: flex; justify-content: space-between; font-size: 0.72rem; font-weight: 700; color: #94a3b8; text-transform: uppercase; margin-bottom: 8px;">
          <span>SẢN PHẨM / SỐ LƯỢNG</span>
          <span>THÀNH TIỀN</span>
        </div>

        <div class="bill-line-item">
          <div>
            <div style="font-weight: 600; color: #0f172a;">Cà phê Arabica</div>
            <div style="font-size: 0.75rem; color: #64748b;">2 × 125.000 đ</div>
          </div>
          <div style="font-weight: 600;">250.000 đ</div>
        </div>

        <div class="bill-line-item">
          <div>
            <div style="font-weight: 600; color: #0f172a;">Sữa yến mạch</div>
            <div style="font-size: 0.75rem; color: #64748b;">1 × 59.000 đ</div>
          </div>
          <div style="font-weight: 600;">59.000 đ</div>
        </div>

        <div class="bill-line-item">
          <div>
            <div style="font-weight: 600; color: #0f172a;">Granola hạt</div>
            <div style="font-size: 0.75rem; color: #64748b;">1 × 99.000 đ</div>
          </div>
          <div style="font-weight: 600;">99.000 đ</div>
        </div>
      </div>

      <!-- Financial Calculation -->
      <div style="display: flex; justify-content: space-between; font-size: 0.85rem; margin-bottom: 6px;">
        <span>Tạm tính · 4 sản phẩm</span>
        <span>408.000 đ</span>
      </div>
      <div style="display: flex; justify-content: space-between; font-size: 0.85rem; margin-bottom: 12px;">
        <span>Giảm giá</span>
        <span>0 đ</span>
      </div>
      <div style="display: flex; justify-content: space-between; align-items: baseline; font-size: 1.1rem; font-weight: 800; color: #0f172a; margin-bottom: 20px;">
        <span>Tổng thanh toán</span>
        <span style="font-size: 1.6rem; color: #2563eb;">408.000 đ</span>
      </div>

      <!-- Payment Method -->
      <div class="no-print" style="display: grid; grid-template-columns: 1fr 1fr; gap: 10px; margin-bottom: 16px;">
        <button type="button" class="btn" style="border: 1.5px solid #2563eb; background: #eff6ff; color: #2563eb;">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
          <span>Tiền mặt</span>
        </button>
        <button type="button" class="btn btn-outline" style="color: #64748b;">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>
          <span>Chuyển khoản</span>
        </button>
      </div>

      <div style="display: flex; justify-content: space-between; font-size: 0.85rem; padding-bottom: 14px; border-bottom: 1px solid #f1f5f9;">
        <span style="color: #64748b;">Khách đưa: 500.000 đ</span>
        <span style="font-weight: 600; color: #0f172a;">Tiền thừa: 92.000 đ</span>
      </div>

      <!-- Sync Status -->
      <div style="display: flex; align-items: center; gap: 8px; background: #eff6ff; border-radius: 8px; padding: 10px 14px; margin-top: 16px; font-size: 0.78rem; color: #1e40af;">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 16V8a2 2 0 00-1-1.73l-7-4a2 2 0 00-2 0l-7 4A2 2 0 003 8v8a2 2 0 001 1.73l7 4a2 2 0 002 0l7-4A2 2 0 0021 16z"/></svg>
        <span>Đã ghi nhận thanh toán và trừ 2 CF01, 1 MK01, 1 GR01 khỏi kho.</span>
      </div>
    </div>

    <div class="modal-footer no-print">
      <button type="button" class="btn btn-outline" onclick="closeModal('invoiceModal')">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
        <span>Xem hóa đơn</span>
      </button>
      <button type="button" class="btn btn-primary" onclick="printInvoice()">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="6 9 6 2 18 2 18 9"/><path d="M6 18H4a2 2 0 01-2-2v-5a2 2 0 012-2h16a2 2 0 012 2v5a2 2 0 01-2 2h-2"/><rect x="6" y="14" width="12" height="8"/></svg>
        <span>In hóa đơn</span>
      </button>
    </div>
  </div>
</div>

<!-- ==========================================================================
     MODAL 2: ĐƠN HÀNG TRONG CA
     ========================================================================== -->
<div class="modal-backdrop" id="shiftOrdersModal">
  <div class="modal-window">
    <div class="modal-header">
      <div>
        <h3 class="modal-title">Đơn hàng trong ca</h3>
        <div class="modal-sub">Ca sáng · 27/10/2026 · Lê Lan Anh</div>
      </div>
      <button type="button" class="modal-close" onclick="closeModal('shiftOrdersModal')">&times;</button>
    </div>

    <div class="modal-body">
      <!-- Shift Summary Dark Box -->
      <div style="background: #0f172a; color: #ffffff; border-radius: 12px; padding: 18px 24px; display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 18px;">
        <div>
          <div style="font-size: 0.75rem; color: #94a3b8; margin-bottom: 4px;">Đơn đã thanh toán</div>
          <div style="font-size: 1.75rem; font-weight: 800;">3 đơn</div>
        </div>
        <div>
          <div style="font-size: 0.75rem; color: #94a3b8; margin-bottom: 4px;">Doanh thu trong ca</div>
          <div style="font-size: 1.75rem; font-weight: 800; color: #60a5fa;">1.254.000 <span style="text-decoration: underline;">đ</span></div>
        </div>
      </div>

      <!-- Search Input -->
      <div class="input-icon-wrapper" style="margin-bottom: 16px;">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
        <input type="text" class="form-input" placeholder="Tìm mã đơn trong ca">
      </div>

      <!-- Order Cards List -->
      <div style="display: flex; flex-direction: column; gap: 10px;">
        <!-- Order #BH-1042 -->
        <div style="border: 1.5px solid #2563eb; background: #ffffff; border-radius: 10px; padding: 14px 18px; display: flex; justify-content: space-between; align-items: center;">
          <div>
            <div style="font-size: 0.95rem; font-weight: 700; color: #2563eb;">#BH-1042</div>
            <div style="font-size: 0.75rem; color: #64748b; margin-top: 2px;">10:24 · Tiền mặt</div>
          </div>
          <div style="text-align: right;">
            <div style="font-size: 1rem; font-weight: 700; color: #0f172a;">408.000 đ</div>
            <span class="badge badge-success" style="margin-top: 4px;">Đã thanh toán</span>
          </div>
        </div>

        <!-- Order #BH-1041 -->
        <div style="border: 1px solid #e2e8f0; background: #ffffff; border-radius: 10px; padding: 14px 18px; display: flex; justify-content: space-between; align-items: center;">
          <div>
            <div style="font-size: 0.95rem; font-weight: 700; color: #0f172a;">#BH-1041</div>
            <div style="font-size: 0.75rem; color: #64748b; margin-top: 2px;">09:52 · Chuyển khoản</div>
          </div>
          <div style="text-align: right;">
            <div style="font-size: 1rem; font-weight: 700; color: #0f172a;">354.000 đ</div>
            <span class="badge badge-success" style="margin-top: 4px;">Đã thanh toán</span>
          </div>
        </div>

        <!-- Order #BH-1040 -->
        <div style="border: 1px solid #e2e8f0; background: #ffffff; border-radius: 10px; padding: 14px 18px; display: flex; justify-content: space-between; align-items: center;">
          <div>
            <div style="font-size: 0.95rem; font-weight: 700; color: #0f172a;">#BH-1040</div>
            <div style="font-size: 0.75rem; color: #64748b; margin-top: 2px;">09:15 · Tiền mặt</div>
          </div>
          <div style="text-align: right;">
            <div style="font-size: 1rem; font-weight: 700; color: #0f172a;">492.000 đ</div>
            <span class="badge badge-success" style="margin-top: 4px;">Đã thanh toán</span>
          </div>
        </div>
      </div>

      <div style="font-size: 0.75rem; color: #94a3b8; text-align: center; margin-top: 16px;">
        Chỉ hiển thị đơn thuộc ca của bạn. Doanh thu được ghi nhận khi thanh toán thành công.
      </div>
    </div>

    <div class="modal-footer">
      <button type="button" class="btn btn-outline" onclick="closeModal('shiftOrdersModal')">Đóng</button>
    </div>
  </div>
</div>

<!-- POS Interactive Script -->
<script src="${pageContext.request.contextPath}/assets/js/pos.js"></script>
<jsp:include page="/common/footer.jsp" />

