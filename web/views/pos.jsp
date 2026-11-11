<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="activeMenu" value="pos" />
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
    window.HAS_ACTIVE_SHIFT = ${hasActiveShift ? 'true' : 'false'};
    // Dữ liệu sản phẩm từ CSDL được truyền an toàn qua JSP sang JS reactive engine
    window.catalogData = [
      <c:forEach items="${products}" var="p" varStatus="loop">
        {
          id: "${p.id}",
          sku: "${p.sku}",
          name: "${p.name}",
          spec: "${not empty p.spec ? p.spec : p.unit}",
          size: "${not empty p.size ? p.size : 'M'}",
          color: "${not empty p.color ? p.color : 'Tiêu chuẩn'}",
          category: "${p.category}",
          price: ${p.price},
          stock: ${p.stockQuantity},
          minStock: ${p.minStock},
          unit: "${not empty p.unit ? p.unit : 'Cái'}",
          image: "${not empty p.imageUrl ? p.imageUrl : ''}"
        }${!loop.last ? ',' : ''}
      </c:forEach>
    ];
  </script>
  <style>
    .pos-tab-item {
      display: inline-flex;
      align-items: center;
      gap: 8px;
      padding: 7px 14px;
      border-radius: 8px;
      font-size: 0.825rem;
      font-weight: 600;
      background: #f1f5f9;
      color: #475569;
      border: 1px solid #e2e8f0;
      cursor: pointer;
      white-space: nowrap;
      transition: all 0.15s ease;
    }
    .pos-tab-item:hover {
      background: #e2e8f0;
    }
    .pos-tab-item.active {
      background: #2563eb;
      color: #ffffff;
      border-color: #2563eb;
      box-shadow: 0 2px 4px rgba(37,99,235,0.2);
    }
    .pos-tab-close {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      width: 18px;
      height: 18px;
      border-radius: 50%;
      font-size: 0.75rem;
      line-height: 1;
      background: rgba(0,0,0,0.12);
      color: inherit;
      border: none;
      cursor: pointer;
    }
    .pos-tab-close:hover {
      background: #ef4444;
      color: #fff;
    }
    .pos-tab-add {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      gap: 6px;
      padding: 7px 12px;
      border-radius: 8px;
      font-size: 0.825rem;
      font-weight: 700;
      background: #fff;
      color: #2563eb;
      border: 1px dashed #93c5fd;
      cursor: pointer;
      transition: all 0.15s ease;
    }
    .pos-tab-add:hover {
      background: #eff6ff;
      border-color: #2563eb;
    }
    .pos-search-table th {
      font-size: 0.72rem;
      font-weight: 700;
      color: #64748b;
      letter-spacing: 0.04em;
      text-transform: uppercase;
      padding: 10px 12px;
      background: #f8fafc;
      border-bottom: 1px solid #e2e8f0;
    }
    .pos-search-table td {
      padding: 10px 12px;
      border-bottom: 1px solid #f1f5f9;
      font-size: 0.85rem;
      vertical-align: middle;
    }
    .pos-search-table tr:hover {
      background: #f8fafc;
    }
    .pos-thumb-box {
      width: 40px;
      height: 40px;
      border-radius: 6px;
      background: #f1f5f9;
      display: flex;
      align-items: center;
      justify-content: center;
      overflow: hidden;
      border: 1px solid #e2e8f0;
      flex-shrink: 0;
    }
  </style>
</head>
<body>

<div class="app-container">
  <jsp:include page="/common/sidebar.jsp">
    <jsp:param name="activeMenu" value="pos" />
  </jsp:include>

  <div class="main-content">
    <jsp:include page="/common/header.jsp" />

    <div class="page-body">
      <!-- Page Top Header -->
      <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 20px;">
        <div>
          <h1 style="font-size: 1.75rem; font-weight: 800; color: #0f172a; letter-spacing: -0.02em;">Quầy bán hàng</h1>
          <div style="font-size: 0.85rem; color: #64748b; margin-top: 4px;">
            Thu ngân: <strong><c:out value="${sessionScope.user != null ? sessionScope.user.fullName : 'Lê Lan Anh'}" /></strong> · Ca làm việc hôm nay
          </div>
        </div>
        
        <!-- Shift Lifecycle & Orders Action Bar -->
        <div style="display: flex; gap: 10px; align-items: center;">
          <c:choose>
            <c:when test="${hasActiveShift}">
              <span class="badge badge-success" style="padding: 7px 14px; font-size: 0.825rem; font-weight: 700; display: inline-flex; align-items: center; gap: 6px; background: #ecfdf5; color: #059669; border: 1px solid #a7f3d0;">
                <span style="width: 8px; height: 8px; border-radius: 50%; background: #10b981;"></span>
                Đang trong ca: #${currentShift.shiftCode}
              </span>
              <button type="button" class="btn btn-outline" onclick="openShiftOrdersModal()">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="5" width="20" height="14" rx="2"/><line x1="2" y1="10" x2="22" y2="10"/></svg>
                <span>Đơn trong ca · ${shiftOrderCount != null ? shiftOrderCount : 0}</span>
              </button>
              <button type="button" class="btn btn-outline" onclick="openCloseShiftModal()" style="color: #ef4444; border-color: #fecaca; background: #fff5f5; font-weight: 600;">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0110 0v4"/></svg>
                <span>Kết ca làm việc</span>
              </button>
            </c:when>
            <c:otherwise>
              <span class="badge badge-warning" style="padding: 7px 14px; font-size: 0.825rem; font-weight: 700; display: inline-flex; align-items: center; gap: 6px; background: #fffbeb; color: #d97706; border: 1px solid #fde68a;">
                <span style="width: 8px; height: 8px; border-radius: 50%; background: #f59e0b;"></span>
                Chưa vào ca làm việc
              </span>
              <button type="button" class="btn btn-primary" onclick="openStartShiftModal()" style="background: #16a34a; border-color: #16a34a; font-weight: 700; display: inline-flex; align-items: center; gap: 6px;">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polygon points="5 3 19 12 5 21 5 3"/></svg>
                <span>Bắt đầu ca làm việc</span>
              </button>
            </c:otherwise>
          </c:choose>
        </div>
      </div>

      <!-- POS Main Grid Split -->
      <div class="pos-container">
        <!-- LEFT COLUMN: SEARCH & DETAIL TABLE -->
        <div>
          <!-- Search Box & Scanner -->
          <div style="display: flex; gap: 10px; align-items: center;">
            <div class="input-icon-wrapper" style="flex: 1;">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
              <input type="text" class="form-input" id="posSearchInput" placeholder="Tìm tên sản phẩm hoặc mã SKU..." oninput="searchProducts(this.value)" autocomplete="off">
            </div>
            <button type="button" class="icon-button" style="width: 42px; height: 42px;" title="Quét mã vạch" onclick="alert('Đã sẵn sàng kết nối máy quét mã vạch!')">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M3 7V5a2 2 0 012-2h2M17 3h2a2 2 0 012 2v2M21 17v2a2 2 0 01-2 2h-2M7 21H5a2 2 0 01-2-2v-2"/>
              </svg>
            </button>
          </div>

          <!-- DETAIL SEARCH RESULTS CONTAINER (EMPTY BY DEFAULT TO AVOID CLUTTER) -->
          <div id="productGridContainer" style="margin-top: 16px;">
            <!-- Populated reactively by pos.js: shows detail table when searching, or empty guide when not -->
          </div>

          <!-- Dynamic Overstock Warning Banner -->
          <div id="stockWarningBanner" style="display: none; align-items: center; gap: 10px; background: #fef2f2; border: 1px solid #fca5a5; border-radius: 10px; padding: 12px 16px; margin-top: 16px; color: #b91c1c; font-size: 0.85rem;">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
            <div>Không đủ tồn kho cho <strong id="overstockProdName">sản phẩm</strong>. Giỏ hàng chưa được ghi nhận thành đơn.</div>
          </div>

          <!-- Bottom Notice -->
          <div style="display: flex; align-items: center; gap: 8px; background: #eff6ff; border: 1px solid #bfdbfe; border-radius: 10px; padding: 12px 16px; margin-top: 16px; font-size: 0.8rem; color: #1e40af;">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
            <span>Tồn khả dụng được kiểm tra trước thanh toán. Đơn hàng thành công sẽ tự động trừ tồn kho ngay lập tức.</span>
          </div>
        </div>

        <!-- RIGHT COLUMN: REACTIVE CART WITH MULTI-ORDER TABS -->
        <div class="pos-cart-panel" id="posCartPanel">
          <!-- Order Tabs (Browser-style tabs: Đơn 1, Đơn 2, ...) -->
          <div class="pos-order-tabs" id="orderTabsContainer" style="display: flex; gap: 6px; margin-bottom: 12px; overflow-x: auto; padding-bottom: 4px; border-bottom: 1px solid #e2e8f0;">
            <!-- Populated reactively by pos.js -->
          </div>

          <!-- Cart Header -->
          <div class="pos-cart-header">
            <div>
              <div style="display: flex; align-items: center; gap: 8px;">
                <h3 style="font-size: 1.1rem; font-weight: 700; color: #0f172a;" id="cartTitleHeading">Đơn hàng mới</h3>
                <span class="badge badge-primary" id="cartItemCountBadge">0 sản phẩm</span>
              </div>
              <div style="font-size: 0.75rem; color: #64748b; margin-top: 2px;">Khách lẻ · Giá bán niêm yết</div>
            </div>
            <a href="javascript:void(0)" onclick="clearCart()" style="font-size: 0.8rem; font-weight: 600; color: #ef4444;">Xóa giỏ</a>
          </div>

          <!-- Items Scroll Area -->
          <div class="cart-items-list" id="cartItemsList">
            <!-- Rendered reactively by pos.js -->
          </div>

          <!-- Cart Financial Summary -->
          <div class="cart-summary">
            <div class="summary-row">
              <span>Tạm tính</span>
              <span id="cartSubtotal">0 VNĐ</span>
            </div>
            <div class="summary-row">
              <span>Giảm giá</span>
              <span>0 VNĐ</span>
            </div>

            <div class="summary-total">
              <span class="total-label">Tổng thanh toán</span>
              <span class="total-amount" id="cartTotal">0 VNĐ</span>
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
              <span>Thanh toán · 0 VNĐ</span>
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>

<!-- ==========================================================================
     MODAL: BẮT ĐẦU CA LÀM VIỆC (MỞ CA MỚI)
     ========================================================================== -->
<div class="modal-backdrop" id="startShiftModal" style="display: none;">
  <div class="modal-window" style="max-width: 440px;">
    <div class="modal-header">
      <div>
        <h3 class="modal-title" style="color: #16a34a;">Bắt đầu ca làm việc</h3>
        <div class="modal-sub">Khai báo số tiền mặt trong két để mở phiên bán hàng</div>
      </div>
      <button type="button" class="modal-close" onclick="closeModal('startShiftModal')">&#215;</button>
    </div>

    <form action="${pageContext.request.contextPath}/pos" method="POST">
      <input type="hidden" name="action" value="startShift">
      <div class="modal-body" style="padding: 20px 24px;">
        <div style="background: #f0fdf4; border: 1px solid #bbf7d0; border-radius: 10px; padding: 14px 16px; margin-bottom: 18px; font-size: 0.8rem; color: #166534;">
          <strong>Nhân viên vào ca:</strong> <c:out value="${sessionScope.user != null ? sessionScope.user.fullName : 'Lê Lan Anh'}" />.<br>
          Ca làm việc sẽ duy trì liên tục qua các lần đăng xuất/đăng nhập cho đến khi bạn chủ động nhấn <em>Kết ca</em>.
        </div>

        <div class="form-group" style="margin-bottom: 16px;">
          <label class="form-label" for="openingCashInput">Số tiền mặt ban đầu tại két (VNĐ) *</label>
          <input type="number" id="openingCashInput" name="openingCash" class="form-input" value="1000000" min="0" step="50000" required>
        </div>

        <div class="form-group" style="margin-bottom: 10px;">
          <label class="form-label" for="shiftNoteInput">Ghi chú nhận ca</label>
          <input type="text" id="shiftNoteInput" name="note" class="form-input" placeholder="Ví dụ: Đã kiểm đếm đủ tiền lẻ đầu ca và nhận máy POS">
        </div>
      </div>

      <div class="modal-footer">
        <button type="button" class="btn btn-outline" onclick="closeModal('startShiftModal')">Hủy bỏ</button>
        <button type="submit" class="btn btn-primary" style="background: #16a34a; border-color: #16a34a; font-weight: 700;">
          <span>Vào ca làm việc ngay</span>
        </button>
      </div>
    </form>
  </div>
</div>

<!-- ==========================================================================
     MODAL: KẾT CA LÀM VIỆC & BÀN GIAO TIỀN
     ========================================================================== -->
<div class="modal-backdrop" id="closeShiftModal" style="display: none;">
  <div class="modal-window" style="max-width: 480px;">
    <div class="modal-header">
      <div>
        <h3 class="modal-title" style="color: #dc2626;">Kết ca làm việc</h3>
        <div class="modal-sub">Chốt doanh số ca và bàn giao két tiền cuối ca</div>
      </div>
      <button type="button" class="modal-close" onclick="closeModal('closeShiftModal')">&#215;</button>
    </div>

    <form action="${pageContext.request.contextPath}/pos" method="POST">
      <input type="hidden" name="action" value="closeShift">
      <input type="hidden" name="shiftId" value="${currentShift != null ? currentShift.shiftId : 0}">

      <div class="modal-body" style="padding: 20px 24px;">
        <div style="background: #eff6ff; border: 1px solid #bfdbfe; border-radius: 10px; padding: 14px 18px; margin-bottom: 18px;">
          <div style="display: flex; justify-content: space-between; font-size: 0.85rem; margin-bottom: 6px;">
            <span style="color: #64748b;">Tiền mặt đầu ca:</span>
            <strong style="color: #0f172a;"><fmt:formatNumber value="${currentShift != null ? currentShift.openingCash : 1000000}" pattern="#,###"/> VNĐ</strong>
          </div>
          <div style="display: flex; justify-content: space-between; font-size: 0.85rem; margin-bottom: 6px;">
            <span style="color: #64748b;">Doanh số bán trong ca:</span>
            <strong style="color: #2563eb;"><fmt:formatNumber value="${currentShift != null ? currentShift.totalSales : 0}" pattern="#,###"/> VNĐ</strong>
          </div>
          <div style="border-top: 1px solid #dbeafe; padding-top: 8px; margin-top: 6px; display: flex; justify-content: space-between; font-size: 0.95rem; font-weight: 700;">
            <span style="color: #1e3a8a;">Tiền mặt dự kiến tại két:</span>
            <span style="color: #16a34a;"><fmt:formatNumber value="${(currentShift != null ? currentShift.openingCash : 1000000) + (currentShift != null ? currentShift.totalSales : 0)}" pattern="#,###"/> VNĐ</span>
          </div>
        </div>

        <div class="form-group" style="margin-bottom: 16px;">
          <label class="form-label" for="closingCashInput">Số tiền mặt thực tế tại két (VNĐ) *</label>
          <input type="number" id="closingCashInput" name="closingCash" class="form-input" value="${(currentShift != null ? currentShift.openingCash : 1000000) + (currentShift != null ? currentShift.totalSales : 0)}" min="0" step="1000" required>
        </div>

        <div class="form-group" style="margin-bottom: 10px;">
          <label class="form-label" for="closeNoteInput">Ghi chú bàn giao</label>
          <input type="text" id="closeNoteInput" name="note" class="form-input" value="Bàn giao ca hoàn tất cho quản lý.">
        </div>
      </div>

      <div class="modal-footer">
        <button type="button" class="btn btn-outline" onclick="closeModal('closeShiftModal')">Quay lại</button>
        <button type="submit" class="btn btn-primary" style="background: #dc2626; border-color: #dc2626; font-weight: 700;" onclick="return confirm('Xác nhận kết ca làm việc này? Sau khi kết ca, bạn sẽ cần bấm Bắt đầu ca mới để thanh toán tiếp.');">
          <span>Xác nhận kết ca</span>
        </button>
      </div>
    </form>
  </div>
</div>

<!-- ==========================================================================
     MODAL 1: THANH TOÁN THÀNH CÔNG / IN HÓA ĐƠN
     ========================================================================== -->
<div class="modal-backdrop" id="invoiceModal">
  <div class="modal-window modal-print">
    <div class="modal-header no-print">
      <div>
        <h3 class="modal-title">Hóa đơn bán hàng</h3>
        <div class="modal-sub">Giao dịch đã được ghi nhận vào CSDL SQL Server</div>
      </div>
      <button type="button" class="modal-close" onclick="closeModal('invoiceModal')">&#215;</button>
    </div>

    <div class="modal-body" style="padding: 24px 32px;">
      <!-- Invoice Printable Template -->
      <div class="invoice-box">
        <div class="invoice-brand">
          <div class="brand-title">KIOTFLOW RETAIL</div>
          <div class="brand-sub">HỆ THỐNG THỜI TRANG AN NHIÊN · CHI NHÁNH NGUYỄN TRÃI</div>
          <div class="brand-sub">Đ/c: 124 Nguyễn Trãi, Quận 1, TP. Hồ Chí Minh · Hotline: 1900 6868</div>
        </div>

        <div class="invoice-meta-grid">
          <div>
            <div><strong>Mã hóa đơn:</strong> <span id="invOrderCode">#BH-0000</span></div>
            <div><strong>Thu ngân:</strong> <c:out value="${sessionScope.user != null ? sessionScope.user.fullName : 'Lê Lan Anh'}" /></div>
          </div>
          <div style="text-align: right;">
            <div><strong>Thời gian:</strong> <span id="invDateTime">--/--/---- --:--</span></div>
            <div><strong>Phương thức:</strong> <span id="invPaymentMethod">Tiền mặt</span></div>
          </div>
        </div>

        <table class="invoice-table">
          <thead>
            <tr>
              <th style="width: 50%;">Sản phẩm</th>
              <th style="text-align: center; width: 15%;">SL</th>
              <th style="text-align: right; width: 17%;">Đơn giá</th>
              <th style="text-align: right; width: 18%;">Thành tiền</th>
            </tr>
          </thead>
          <tbody id="invoiceItemsTbody">
            <!-- Dynamic from Cart -->
          </tbody>
        </table>

        <div class="invoice-financial-rows">
          <div class="inv-row">
            <span>Tạm tính hàng hóa:</span>
            <span id="invSubtotal">0 VNĐ</span>
          </div>
          <div class="inv-row">
            <span>Chiết khấu / Giảm giá:</span>
            <span>0 VNĐ</span>
          </div>
          <div class="inv-row-total">
            <span>TỔNG CỘNG THANH TOÁN:</span>
            <span id="invTotalAmount">0 VNĐ</span>
          </div>
        </div>

        <div class="invoice-footer-note">
          <div>Cảm ơn quý khách đã tin tưởng mua sắm tại An Nhiên!</div>
          <div style="font-size: 0.7rem; color: #94a3b8; margin-top: 4px;">Hóa đơn điện tử khởi tạo từ hệ thống KiotFlow · Quý khách vui lòng kiểm tra hàng trước khi rời quầy</div>
        </div>
      </div>
    </div>

    <div class="modal-footer no-print">
      <button type="button" class="btn btn-outline" onclick="closeModal('invoiceModal')">
        <span>Đóng &amp; Tạo đơn mới</span>
      </button>
      <button type="button" class="btn btn-primary" onclick="printInvoice()">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="6 9 6 2 18 2 18 9"/><path d="M6 18H4a2 2 0 01-2-2v-5a2 2 0 012-2h16a2 2 0 012 2v5a2 2 0 01-2 2h-2"/><rect x="6" y="14" width="12" height="8"/></svg>
        <span>In hóa đơn</span>
      </button>
    </div>
  </div>
</div>

<!-- ==========================================================================
     MODAL 2: ĐƠN HÀNG TRONG CA (TRUY VẤN TỪ DATABASE)
     ========================================================================== -->
<div class="modal-backdrop" id="shiftOrdersModal">
  <div class="modal-window">
    <div class="modal-header">
      <div>
        <h3 class="modal-title">Đơn hàng trong ca</h3>
        <div class="modal-sub">
          <c:choose>
            <c:when test="${currentShift != null}">
              Ca: <strong>#${currentShift.shiftCode}</strong> · Người trực: <strong><c:out value="${currentShift.staffName}" /></strong>
            </c:when>
            <c:otherwise>
              <c:out value="${sessionScope.user != null ? sessionScope.user.fullName : 'Lê Lan Anh'}" /> · Hôm nay
            </c:otherwise>
          </c:choose>
        </div>
      </div>
      <button type="button" class="modal-close" onclick="closeModal('shiftOrdersModal')">&#215;</button>
    </div>

    <div class="modal-body">
      <!-- Shift Summary Box -->
      <div style="background: #eff6ff; color: #0f172a; border: 1px solid #bfdbfe; border-radius: 12px; padding: 16px 20px; display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 14px; margin-bottom: 18px;">
        <div>
          <div style="font-size: 0.75rem; color: #64748b; margin-bottom: 4px;">Đơn trong ca</div>
          <div style="font-size: 1.5rem; font-weight: 800; color: #2563eb;">${shiftOrderCount != null ? shiftOrderCount : 0} đơn</div>
        </div>
        <div>
          <div style="font-size: 0.75rem; color: #64748b; margin-bottom: 4px;">Doanh số ca</div>
          <div style="font-size: 1.3rem; font-weight: 800; color: #16a34a;"><fmt:formatNumber value="${currentShift != null ? currentShift.totalSales : 0}" pattern="#,###"/> VNĐ</div>
        </div>
        <div>
          <div style="font-size: 0.75rem; color: #64748b; margin-bottom: 4px;">Tiền đầu ca</div>
          <div style="font-size: 1.15rem; font-weight: 700; color: #475569;"><fmt:formatNumber value="${currentShift != null ? currentShift.openingCash : 0}" pattern="#,###"/> VNĐ</div>
        </div>
      </div>

      <!-- Order Cards List from Database -->
      <div style="display: flex; flex-direction: column; gap: 10px; max-height: 320px; overflow-y: auto;">
        <c:choose>
          <c:when test="${not empty shiftOrders}">
            <c:forEach items="${shiftOrders}" var="so">
              <div style="border: 1px solid #e2e8f0; background: #ffffff; border-radius: 10px; padding: 14px 18px; display: flex; justify-content: space-between; align-items: center;">
                <div>
                  <div style="display: flex; align-items: center; gap: 8px;">
                    <span style="font-size: 0.95rem; font-weight: 700; color: #2563eb;">#${so.code}</span>
                    <span class="badge badge-gray" style="font-size: 0.72rem; padding: 2px 8px;">${so.paymentMethod}</span>
                  </div>
                  <div style="font-size: 0.78rem; color: #475569; margin-top: 4px;">
                    <span>Thời gian: ${so.formattedTime}</span> · 
                    <span>Người thực hiện: <strong style="color: #0f172a;">${not empty so.staffName ? so.staffName : (currentShift != null ? currentShift.staffName : sessionScope.user.fullName)}</strong></span>
                  </div>
                </div>
                <div style="text-align: right;">
                  <div style="font-size: 1rem; font-weight: 700; color: #0f172a;"><fmt:formatNumber value="${so.totalAmount}" pattern="#,###"/> VNĐ</div>
                  <span class="badge badge-success" style="margin-top: 4px;">${so.status}</span>
                </div>
              </div>
            </c:forEach>
          </c:when>
          <c:otherwise>
            <div style="text-align: center; padding: 30px 10px; color: #94a3b8;">
              Chưa có đơn hàng nào trong ca làm việc này.
            </div>
          </c:otherwise>
        </c:choose>
      </div>

      <div style="font-size: 0.75rem; color: #94a3b8; text-align: center; margin-top: 16px;">
        Chỉ hiển thị đơn thuộc ca làm việc hiện tại của bạn. Doanh số ca được cập nhật tự động khi thanh toán.
      </div>
    </div>

    <div class="modal-footer">
      <button type="button" class="btn btn-outline" onclick="closeModal('shiftOrdersModal')">Đóng</button>
    </div>
  </div>
</div>

<script>
  function openStartShiftModal() {
    const m = document.getElementById('startShiftModal');
    if (m) m.style.display = 'flex';
  }
  function openCloseShiftModal() {
    const m = document.getElementById('closeShiftModal');
    if (m) m.style.display = 'flex';
  }
  function openShiftOrdersModal() {
    const m = document.getElementById('shiftOrdersModal');
    if (m) m.style.display = 'flex';
  }
  function closeModal(id) {
    const m = document.getElementById(id);
    if (m) {
      m.style.display = 'none';
      m.classList.remove('show');
    }
    document.body.style.overflow = '';
  }
</script>

<!-- POS Interactive Script (Cache Busted) -->
<script src="${pageContext.request.contextPath}/assets/js/pos.js?v=20261111_v1" charset="UTF-8"></script>
<jsp:include page="/common/footer.jsp" />
</body>
</html>
