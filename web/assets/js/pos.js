/**
 * KIOTFLOW POS - Point of Sale & Reactive Cart Engine
 * Connects directly to Java Servlet Backend (/pos) with JDBC Transactions
 */

// Lấy danh mục sản phẩm được truyền động từ JSP/CSDL
const catalogData = window.catalogData || [];

// Giỏ hàng ban đầu (khởi tạo rỗng)
let cart = [];
let activeCategory = 'all';

// Helper format tiền tệ VNĐ
function formatVND(amount) {
  return new Intl.NumberFormat('vi-VN').format(amount) + ' đ';
}

// Thêm vào giỏ
function addToCart(sku) {
  const prod = catalogData.find(p => p.sku === sku);
  if (!prod) return;

  const existing = cart.find(item => item.sku === sku);
  if (existing) {
    existing.quantity += 1;
  } else {
    cart.push({ sku: sku, quantity: 1 });
  }
  renderCart();
}

// Thay đổi số lượng
function updateCartQty(sku, change) {
  const item = cart.find(item => item.sku === sku);
  if (!item) return;

  item.quantity += change;
  if (item.quantity <= 0) {
    removeFromCart(sku);
    return;
  }
  renderCart();
}

// Xóa sản phẩm khỏi giỏ
function removeFromCart(sku) {
  cart = cart.filter(item => item.sku !== sku);
  renderCart();
}

// Làm trống giỏ hàng
function clearCart() {
  cart = [];
  renderCart();
}

// Engine cập nhật giao diện giỏ hàng và kiểm soát tồn kho tức thì
function renderCart() {
  const cartContainer = document.getElementById('cartItemsList');
  const cartPanel = document.getElementById('posCartPanel');
  const cartCountBadge = document.getElementById('cartItemCountBadge');
  const cartSubtotalEl = document.getElementById('cartSubtotal');
  const cartTotalEl = document.getElementById('cartTotal');
  const checkoutBtn = document.getElementById('checkoutBtn');
  const stockWarningBanner = document.getElementById('stockWarningBanner');
  const overstockProdName = document.getElementById('overstockProdName');
  const checkoutWarningText = document.getElementById('checkoutWarningText');

  if (!cartContainer) return;

  if (cart.length === 0) {
    cartContainer.innerHTML = `
      <div style="text-align:center; padding: 40px 10px; color:#94a3b8;">
        <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" style="margin-bottom:8px;"><circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/><path d="M1 1h4l2.68 13.39a2 2 0 002 1.61h9.72a2 2 0 002-1.61L23 6H6"/></svg>
        <p style="font-weight:600; font-size:0.9rem;">Giỏ hàng trống</p>
        <p style="font-size:0.75rem;">Chọn sản phẩm bên trái để bắt đầu tạo đơn</p>
      </div>
    `;
    if (cartCountBadge) cartCountBadge.textContent = '0 sản phẩm';
    if (cartSubtotalEl) cartSubtotalEl.textContent = '0 đ';
    if (cartTotalEl) {
      cartTotalEl.textContent = '0 đ';
      cartTotalEl.classList.remove('text-danger');
    }
    if (cartPanel) cartPanel.classList.remove('has-stock-error');
    if (stockWarningBanner) stockWarningBanner.style.display = 'none';
    if (checkoutWarningText) checkoutWarningText.style.display = 'none';
    if (checkoutBtn) {
      checkoutBtn.disabled = true;
      checkoutBtn.className = 'btn btn-disabled';
      checkoutBtn.style.width = '100%';
      checkoutBtn.style.padding = '14px';
      checkoutBtn.innerHTML = `<span>Thanh toán · 0 đ</span>`;
    }
    return;
  }

  let subtotal = 0;
  let totalItemsCount = 0;
  let hasOverstock = false;
  let overstockedProductName = '';
  let html = '';

  cart.forEach(item => {
    const prod = catalogData.find(p => p.sku === item.sku);
    if (!prod) return;

    const isOverstock = item.quantity > prod.stock;
    const itemSubtotal = prod.price * item.quantity;
    subtotal += itemSubtotal;
    totalItemsCount += item.quantity;

    if (isOverstock) {
      hasOverstock = true;
      overstockedProductName = prod.name;
    }

    const contextPath = window.CONTEXT_PATH || '';
    const imgUrl = contextPath + '/assets/images/' + (prod.image || 'CF01.svg');

    html += `
      <div class="cart-item-card ${isOverstock ? 'is-overstock' : ''}" id="cart-item-${prod.sku}">
        <div class="cart-item-header">
          <img src="${imgUrl}" alt="${prod.name}" class="cart-item-thumb">
          <div class="cart-item-info">
            <div class="cart-item-title">${prod.name}</div>
            <div class="cart-item-spec">${prod.spec || ''} · ${formatVND(prod.price)}</div>
          </div>
          <button type="button" class="cart-item-remove" onclick="removeFromCart('${prod.sku}')" title="Xóa khỏi giỏ">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 01-2 2H7a2 2 0 01-2-2V6m3 0V4a2 2 0 012-2h4a2 2 0 012 2v2"/></svg>
          </button>
        </div>

        <div class="cart-item-controls">
          <div class="stepper-group">
            <button type="button" class="stepper-btn" onclick="updateCartQty('${prod.sku}', -1)">−</button>
            <input type="text" class="stepper-val" value="${item.quantity}" readonly>
            <button type="button" class="stepper-btn" onclick="updateCartQty('${prod.sku}', 1)">+</button>
          </div>
          <div class="cart-item-subtotal">${formatVND(itemSubtotal)}</div>
        </div>

        ${isOverstock ? `
          <div class="cart-item-error-msg" style="color:#ef4444; font-size:0.75rem; margin-top:6px;">
            Chỉ còn ${prod.stock} ${prod.unit}. Số lượng ${item.quantity} vượt tồn kho ${item.quantity - prod.stock} ${prod.unit}.
          </div>
        ` : ''}
      </div>
    `;
  });

  cartContainer.innerHTML = html;
  if (cartCountBadge) cartCountBadge.textContent = totalItemsCount + ' sản phẩm';
  if (cartSubtotalEl) cartSubtotalEl.textContent = formatVND(subtotal);
  if (cartTotalEl) cartTotalEl.textContent = formatVND(subtotal);

  // Khóa nút thanh toán nếu phát hiện sản phẩm vượt tồn kho
  if (hasOverstock) {
    if (cartPanel) cartPanel.classList.add('has-stock-error');
    if (cartTotalEl) cartTotalEl.classList.add('text-danger');
    if (stockWarningBanner) {
      stockWarningBanner.style.display = 'flex';
      overstockProdName.textContent = overstockedProductName;
    }
    if (checkoutWarningText) checkoutWarningText.style.display = 'block';

    if (checkoutBtn) {
      checkoutBtn.disabled = true;
      checkoutBtn.className = 'btn btn-disabled';
      checkoutBtn.style.width = '100%';
      checkoutBtn.style.padding = '14px';
      checkoutBtn.innerHTML = `
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0110 0v4"/></svg>
        <span>Không thể thanh toán</span>
      `;
    }
  } else {
    if (cartPanel) cartPanel.classList.remove('has-stock-error');
    if (cartTotalEl) cartTotalEl.classList.remove('text-danger');
    if (stockWarningBanner) stockWarningBanner.style.display = 'none';
    if (checkoutWarningText) checkoutWarningText.style.display = 'none';

    if (checkoutBtn) {
      checkoutBtn.disabled = false;
      checkoutBtn.className = 'btn btn-primary';
      checkoutBtn.style.width = '100%';
      checkoutBtn.style.padding = '14px';
      checkoutBtn.innerHTML = `
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="1" y="4" width="22" height="16" rx="2" ry="2"/><line x1="1" y1="10" x2="23" y2="10"/></svg>
        <span>Thanh toán · ${formatVND(subtotal)}</span>
      `;
    }
  }
}

// Lọc sản phẩm theo danh mục
function filterCategory(cat, element) {
  activeCategory = cat;
  document.querySelectorAll('.filter-tab-pill').forEach(el => el.classList.remove('active'));
  if (element) element.classList.add('active');

  const cards = document.querySelectorAll('.product-card');
  cards.forEach(card => {
    const cardCat = card.getAttribute('data-category');
    if (cat === 'all' || cardCat === cat) {
      card.style.display = 'flex';
    } else {
      card.style.display = 'none';
    }
  });
}

// Tìm kiếm sản phẩm
function searchProducts(query) {
  const q = query.trim().toLowerCase();
  const cards = document.querySelectorAll('.product-card');
  cards.forEach(card => {
    const title = (card.getAttribute('data-name') || '').toLowerCase();
    const sku = (card.getAttribute('data-sku') || '').toLowerCase();
    if (title.includes(q) || sku.includes(q)) {
      card.style.display = 'flex';
    } else {
      card.style.display = 'none';
    }
  });
}

// Xử lý gửi đơn hàng lên Backend Java Servlet (/pos)
function processCheckout() {
  if (cart.length === 0) {
    alert('Giỏ hàng đang trống!');
    return;
  }

  const checkoutBtn = document.getElementById('checkoutBtn');
  if (checkoutBtn && checkoutBtn.disabled) return;

  const contextPath = window.CONTEXT_PATH || '';
  const postUrl = contextPath + '/pos';

  // Chuẩn bị dữ liệu form
  const params = new URLSearchParams();
  params.append('paymentMethod', 'Tiền mặt');
  cart.forEach(item => {
    params.append('productId', item.sku);
    params.append('quantity', item.quantity);
  });

  if (checkoutBtn) {
    checkoutBtn.disabled = true;
    checkoutBtn.innerHTML = '<span>Đang lập đơn &amp; trừ kho...</span>';
  }

  fetch(postUrl, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
    },
    body: params.toString()
  })
  .then(res => res.json())
  .then(data => {
    if (data.success) {
      // Cập nhật modal hóa đơn
      const subTitleEl = document.getElementById('invoiceModalSub');
      if (subTitleEl) {
        const now = new Date();
        subTitleEl.textContent = 'Hóa đơn #' + data.orderCode + ' · ' + now.toLocaleTimeString('vi-VN', {hour: '2-digit', minute:'2-digit'}) + ', ' + now.toLocaleDateString('vi-VN');
      }

      const itemsContainer = document.getElementById('invoiceItemsContainer');
      if (itemsContainer) {
        let billHtml = '';
        cart.forEach(item => {
          const prod = catalogData.find(p => p.sku === item.sku);
          if (prod) {
            billHtml += `
              <div class="bill-line-item" style="display:flex; justify-content:space-between; margin-bottom:8px; font-size:0.85rem;">
                <div>
                  <div style="font-weight:600; color:#0f172a;">${prod.name}</div>
                  <div style="font-size:0.75rem; color:#64748b;">${item.quantity} × ${formatVND(prod.price)}</div>
                </div>
                <div style="font-weight:600;">${formatVND(item.quantity * prod.price)}</div>
              </div>
            `;
            // Cập nhật tồn kho client
            prod.stock -= item.quantity;
          }
        });
        itemsContainer.innerHTML = billHtml;
      }

      const totalEl = document.getElementById('invoiceTotalAmount');
      if (totalEl) totalEl.textContent = formatVND(data.totalAmount);

      // Mở modal hóa đơn
      openModal('invoiceModal');

      // Làm trống giỏ hàng sau khi thanh toán thành công
      cart = [];
      renderCart();
    } else {
      alert(data.message || 'Thanh toán thất bại!');
      renderCart();
    }
  })
  .catch(err => {
    console.error('Checkout error:', err);
    alert('Lỗi kết nối tới máy chủ khi tạo đơn hàng!');
    renderCart();
  });
}

// In hóa đơn
function printInvoice() {
  window.print();
}

// Mở Modal đơn trong ca
function openShiftOrdersModal() {
  openModal('shiftOrdersModal');
}

// Helper thử kịch bản vượt tồn kho
function simulateOverstockDemo() {
  if (catalogData.length === 0) return;
  const target = catalogData[0];
  const item = cart.find(p => p.sku === target.sku);
  if (item) {
    item.quantity = target.stock + 5;
  } else {
    cart.push({ sku: target.sku, quantity: target.stock + 5 });
  }
  renderCart();
}

document.addEventListener('DOMContentLoaded', function() {
  renderCart();
});
