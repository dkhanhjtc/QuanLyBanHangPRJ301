/**
 * KIOTFLOW POS - Point of Sale & Reactive Cart Engine
 * Handles real-time inventory threshold checking, overstock validation,
 * automatic total computation, and invoice printing.
 */

// Initial mock products database for client-side reactive store
const catalogData = [
  { id: 1, sku: 'CF01', name: 'Cà phê Arabica', spec: 'Gói 250g', category: 'coffee', price: 125000, stock: 24, minStock: 10, unit: 'gói', image: 'CF01.svg' },
  { id: 2, sku: 'TE01', name: 'Trà sen', spec: 'Hộp 100g', category: 'coffee', price: 89000, stock: 18, minStock: 8, unit: 'hộp', image: 'TE01.svg' },
  { id: 3, sku: 'MK01', name: 'Sữa yến mạch', spec: 'Hộp 1L', category: 'drinks', price: 59000, stock: 8, minStock: 8, unit: 'hộp', image: 'MK01.svg' },
  { id: 4, sku: 'HN01', name: 'Mật ong hoa nhãn', spec: 'Chai 500ml', category: 'food', price: 145000, stock: 12, minStock: 5, unit: 'chai', image: 'HN01.svg' },
  { id: 5, sku: 'GR01', name: 'Granola hạt', spec: 'Gói 300g', category: 'food', price: 99000, stock: 6, minStock: 6, unit: 'gói', image: 'GR01.svg' },
  { id: 6, sku: 'CK01', name: 'Bánh quy bơ', spec: 'Hộp 200g', category: 'food', price: 65000, stock: 32, minStock: 10, unit: 'hộp', image: 'CK01.svg' },
  { id: 7, sku: 'WA01', name: 'Nước khoáng', spec: 'Chai 500ml', category: 'drinks', price: 10000, stock: 48, minStock: 12, unit: 'chai', image: 'WA01.svg' },
  { id: 8, sku: 'CC01', name: 'Cacao nguyên chất', spec: 'Gói 200g', category: 'coffee', price: 105000, stock: 15, minStock: 5, unit: 'gói', image: 'CC01.svg' }
];

// Initial Cart matching Mockup (2 CF01, 1 MK01, 1 GR01)
let cart = [
  { sku: 'CF01', quantity: 2 },
  { sku: 'MK01', quantity: 1 },
  { sku: 'GR01', quantity: 1 }
];

let activeCategory = 'all';

// Add to Cart
function addToCart(sku) {
  const existing = cart.find(item => item.sku === sku);
  if (existing) {
    existing.quantity += 1;
  } else {
    cart.push({ sku: sku, quantity: 1 });
  }
  renderCart();
}

// Update Quantity
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

// Remove Item
function removeFromCart(sku) {
  cart = cart.filter(item => item.sku !== sku);
  renderCart();
}

// Clear Cart
function clearCart() {
  cart = [];
  renderCart();
}

// Core Render & Validation Engine
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
    cartCountBadge.textContent = '0 sản phẩm';
    cartSubtotalEl.textContent = '0 đ';
    cartTotalEl.textContent = '0 đ';
    cartTotalEl.classList.remove('text-danger');
    cartPanel.classList.remove('has-stock-error');
    if (stockWarningBanner) stockWarningBanner.style.display = 'none';
    if (checkoutWarningText) checkoutWarningText.style.display = 'none';
    checkoutBtn.disabled = true;
    checkoutBtn.className = 'btn btn-disabled';
    checkoutBtn.innerHTML = `<span>Thanh toán · 0 đ</span>`;
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
    const imgUrl = contextPath + '/assets/images/' + prod.image;

    html += `
      <div class="cart-item-card ${isOverstock ? 'is-overstock' : ''}" id="cart-item-${prod.sku}">
        <div class="cart-item-header">
          <img src="${imgUrl}" alt="${prod.name}" class="cart-item-thumb">
          <div class="cart-item-info">
            <div class="cart-item-title">${prod.name}</div>
            <div class="cart-item-spec">${prod.spec} · ${formatVND(prod.price)}</div>
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
          <div class="cart-item-error-msg">
            Chỉ còn ${prod.stock} ${prod.unit}. Số lượng ${item.quantity} vượt tồn kho ${item.quantity - prod.stock} ${prod.unit}.
          </div>
        ` : ''}
      </div>
    `;
  });

  cartContainer.innerHTML = html;
  cartCountBadge.textContent = totalItemsCount + ' sản phẩm';
  cartSubtotalEl.textContent = formatVND(subtotal);
  cartTotalEl.textContent = formatVND(subtotal);

  // Apply Reactive Inventory Lockout
  if (hasOverstock) {
    cartPanel.classList.add('has-stock-error');
    cartTotalEl.classList.add('text-danger');
    if (stockWarningBanner) {
      stockWarningBanner.style.display = 'flex';
      overstockProdName.textContent = overstockedProductName;
    }
    if (checkoutWarningText) {
      checkoutWarningText.style.display = 'block';
    }
    checkoutBtn.disabled = true;
    checkoutBtn.className = 'btn btn-disabled';
    checkoutBtn.style.width = '100%';
    checkoutBtn.style.padding = '14px';
    checkoutBtn.innerHTML = `
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0110 0v4"/></svg>
      <span>Không thể thanh toán</span>
    `;
  } else {
    cartPanel.classList.remove('has-stock-error');
    cartTotalEl.classList.remove('text-danger');
    if (stockWarningBanner) {
      stockWarningBanner.style.display = 'none';
    }
    if (checkoutWarningText) {
      checkoutWarningText.style.display = 'none';
    }
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

// Category Filter
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

// Product Search
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

// Trigger Checkout Modal
function processCheckout() {
  if (cart.length === 0) return;
  openModal('invoiceModal');
}

// Trigger Print
function printInvoice() {
  window.print();
}

// Open Shift Orders Modal
function openShiftOrdersModal() {
  openModal('shiftOrdersModal');
}

// Helper to simulate Overstock scenario for demo
function simulateOverstockDemo() {
  const item = cart.find(p => p.sku === 'MK01');
  if (item) {
    item.quantity = 9; // Stock is 8 -> triggers error
  } else {
    cart.push({ sku: 'MK01', quantity: 9 });
  }
  renderCart();
}

document.addEventListener('DOMContentLoaded', function() {
  renderCart();
});

