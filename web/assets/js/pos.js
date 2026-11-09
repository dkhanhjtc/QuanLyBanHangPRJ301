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
        <p style="font-weight:600; font-size:0.9rem; color:#475569;">Giỏ hàng trống</p>
        <p style="font-size:0.75rem; color:#94a3b8;">Chọn sản phẩm bên trái để bắt đầu tạo đơn</p>
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
    const imgUrl = contextPath + '/assets/images/' + (prod.image || 'CC01.svg');

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
            <input type="number" class="stepper-input ${isOverstock ? 'input-error' : ''}" value="${item.quantity}" min="1" onchange="setCartQty('${prod.sku}', this.value)">
            <button type="button" class="stepper-btn" onclick="updateCartQty('${prod.sku}', 1)">+</button>
          </div>
          <div class="cart-item-total ${isOverstock ? 'text-danger' : ''}">${formatVND(itemSubtotal)}</div>
        </div>

        ${isOverstock ? `
          <div class="overstock-msg">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
            <span>Vượt tồn kho! Chỉ còn ${prod.stock} ${prod.unit || 'cái'} trong kho.</span>
          </div>
        ` : ''}
      </div>
    `;
  });

  cartContainer.innerHTML = html;

  if (cartCountBadge) cartCountBadge.textContent = totalItemsCount + ' sản phẩm';
  if (cartSubtotalEl) cartSubtotalEl.textContent = formatVND(subtotal);

  if (cartTotalEl) {
    cartTotalEl.textContent = formatVND(subtotal);
    if (hasOverstock) {
      cartTotalEl.classList.add('text-danger');
    } else {
      cartTotalEl.classList.remove('text-danger');
    }
  }

  if (cartPanel) {
    if (hasOverstock) cartPanel.classList.add('has-stock-error');
    else cartPanel.classList.remove('has-stock-error');
  }

  if (stockWarningBanner) {
    stockWarningBanner.style.display = hasOverstock ? 'flex' : 'none';
  }
  if (overstockProdName) {
    overstockProdName.textContent = overstockedProductName;
  }
  if (checkoutWarningText) {
    checkoutWarningText.style.display = hasOverstock ? 'block' : 'none';
  }

  if (checkoutBtn) {
    if (hasOverstock) {
      checkoutBtn.disabled = true;
      checkoutBtn.className = 'btn btn-disabled';
      checkoutBtn.style.width = '100%';
      checkoutBtn.style.padding = '14px';
      checkoutBtn.innerHTML = `
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
        <span>Không thể thanh toán · Vượt tồn kho</span>
      `;
    } else {
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

// Nhập trực tiếp số lượng trong ô input
function setCartQty(sku, val) {
  let q = parseInt(val, 10);
  if (isNaN(q) || q <= 0) q = 1;

  const item = cart.find(item => item.sku === sku);
  if (item) {
    item.quantity = q;
    renderCart();
  }
}

// Lọc sản phẩm theo Category Tabs
function filterCategory(cat, btn) {
  activeCategory = cat;
  document.querySelectorAll('.filter-tab-pill').forEach(el => el.classList.remove('active'));
  if (btn) btn.classList.add('active');

  const cards = document.querySelectorAll('.product-card');
  cards.forEach(card => {
    const cardCat = card.getAttribute('data-category');
    if (cat === 'all' || cardCat === cat || (cardCat && cardCat.includes(cat))) {
      card.style.display = 'flex';
    } else {
      card.style.display = 'none';
    }
  });
}

// Tìm kiếm sản phẩm theo tên / SKU realtime
function searchProducts(keyword) {
  const q = keyword.trim().toLowerCase();
  const cards = document.querySelectorAll('.product-card');
  cards.forEach(card => {
    const name = (card.getAttribute('data-name') || '').toLowerCase();
    const sku = (card.getAttribute('data-sku') || '').toLowerCase();
    const matchesQuery = name.includes(q) || sku.includes(q);
    const matchesCat = (activeCategory === 'all' || (card.getAttribute('data-category') || '').includes(activeCategory));

    if (matchesQuery && matchesCat) {
      card.style.display = 'flex';
    } else {
      card.style.display = 'none';
    }
  });
}

// Xử lý gửi thanh toán AJAX tới PosServlet (/pos)
function processCheckout() {
  if (window.HAS_ACTIVE_SHIFT === false) {
    alert('Bạn chưa bắt đầu ca làm việc! Vui lòng bấm "Bắt đầu ca làm việc" trước khi thanh toán.');
    if (typeof openStartShiftModal === 'function') openStartShiftModal();
    return;
  }

  if (cart.length === 0) {
    alert('Giỏ hàng đang trống! Vui lòng chọn sản phẩm.');
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
      const invCode = document.getElementById('invOrderCode');
      if (invCode) invCode.textContent = '#' + data.orderCode;

      const invDateTime = document.getElementById('invDateTime');
      if (invDateTime) {
        const now = new Date();
        invDateTime.textContent = now.toLocaleDateString('vi-VN') + ' ' + now.toLocaleTimeString('vi-VN', {hour: '2-digit', minute:'2-digit'});
      }

      const tbody = document.getElementById('invoiceItemsTbody');
      if (tbody) {
        let rowsHtml = '';
        cart.forEach(item => {
          const prod = catalogData.find(p => p.sku === item.sku);
          if (prod) {
            rowsHtml += `
              <tr>
                <td><strong>${prod.name}</strong><br><span style="font-size:0.75rem; color:#64748b;">${prod.spec || ''}</span></td>
                <td style="text-align: center;">${item.quantity}</td>
                <td style="text-align: right;">${formatVND(prod.price)}</td>
                <td style="text-align: right; font-weight: 700;">${formatVND(item.quantity * prod.price)}</td>
              </tr>
            `;
            // Cập nhật tồn kho client
            prod.stock -= item.quantity;
          }
        });
        tbody.innerHTML = rowsHtml;
      }

      const invSub = document.getElementById('invSubtotal');
      if (invSub) invSub.textContent = formatVND(data.totalAmount);

      const invTot = document.getElementById('invTotalAmount');
      if (invTot) invTot.textContent = formatVND(data.totalAmount);

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

// Helpers quản lý Modal
function openModal(modalId) {
  const modal = document.getElementById(modalId);
  if (modal) modal.style.display = 'flex';
}

function closeModal(modalId) {
  const modal = document.getElementById(modalId);
  if (modal) modal.style.display = 'none';
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
