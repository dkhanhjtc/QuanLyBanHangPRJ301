/**
 * KIOTFLOW POS - Point of Sale Reactive Engine
 * Supports Multi-order Tabs, Search Detail Table, and Variant Switching
 */

// Lấy danh mục sản phẩm từ JSP
const catalogData = window.catalogData || [];

// Multi-order Tabs Management
let orderTabs = [
  { id: 1, name: '\u0110\u01A1n 1', cart: [] }
];
let activeTabId = 1;
let tabCounter = 1;

function getActiveTab() {
  let tab = orderTabs.find(t => t.id === activeTabId);
  if (!tab) {
    if (orderTabs.length === 0) {
      tabCounter++;
      tab = { id: tabCounter, name: '\u0110\u01A1n ' + tabCounter, cart: [] };
      orderTabs.push(tab);
    } else {
      tab = orderTabs[0];
    }
    activeTabId = tab.id;
  }
  return tab;
}

function getActiveCart() {
  return getActiveTab().cart;
}

// Format VND currency
function formatVND(amount) {
  return new Intl.NumberFormat('vi-VN').format(amount) + ' VNĐ';
}

// Render Order Tabs Bar
function renderOrderTabs() {
  const container = document.getElementById('orderTabsContainer');
  if (!container) return;

  let html = '';
  orderTabs.forEach(tab => {
    const isActive = tab.id === activeTabId;
    const count = tab.cart.reduce((sum, it) => sum + it.quantity, 0);
    const badgeText = count > 0 ? ' (' + count + ')' : '';
    
    html += '<div class="pos-tab-item ' + (isActive ? 'active' : '') + '" onclick="switchOrderTab(' + tab.id + ')">';
    html += '<span>' + tab.name + badgeText + '</span>';
    if (orderTabs.length > 1) {
      html += '<button type="button" class="pos-tab-close" onclick="closeOrderTab(' + tab.id + ', event)" title="\u0110\u00F3ng \u0111\u01A1n">&times;</button>';
    }
    html += '</div>';
  });

  html += '<button type="button" class="pos-tab-add" onclick="createNewOrderTab()" title="Th\u00EAm \u0111\u01A1n h\u00E0ng m\u1EDBi">';
  html += '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>';
  html += '<span>+ Th\u00EAm \u0111\u01A1n</span>';
  html += '</button>';

  container.innerHTML = html;
}

// Switch between tabs
function switchOrderTab(tabId) {
  activeTabId = tabId;
  renderOrderTabs();
  renderCart();
}

// Add new order tab
function createNewOrderTab() {
  tabCounter++;
  const newTab = { id: tabCounter, name: '\u0110\u01A1n ' + tabCounter, cart: [] };
  orderTabs.push(newTab);
  activeTabId = newTab.id;
  renderOrderTabs();
  renderCart();
}

// Close order tab
function closeOrderTab(tabId, event) {
  if (event) event.stopPropagation();
  if (orderTabs.length <= 1) return;

  const idx = orderTabs.findIndex(t => t.id === tabId);
  if (idx !== -1) {
    orderTabs.splice(idx, 1);
    if (activeTabId === tabId) {
      activeTabId = orderTabs[Math.max(0, idx - 1)].id;
    }
    renderOrderTabs();
    renderCart();
  }
}

// Search and render Detail Table (Nothing shown when empty to avoid clutter)
function searchProducts(query) {
  const container = document.getElementById('productGridContainer');
  if (!container) return;

  const q = (query || '').trim().toLowerCase();

  // If search bar is empty -> Show clean placeholder message
  if (!q) {
    container.innerHTML = `
      <div style="background: #ffffff; border: 1px dashed #cbd5e1; border-radius: 12px; padding: 50px 24px; text-align: center;">
        <div style="font-size: 2.2rem; margin-bottom: 8px;">\uD83D\uDD0D</div>
        <div style="font-weight: 700; color: #0f172a; font-size: 1.05rem;">T\u00ECm ki\u1EBFm s\u1EA3n ph\u1EA9m b\u00E1n h\u00E0ng</div>
        <div style="font-size: 0.85rem; color: #64748b; margin-top: 6px; max-width: 480px; margin-left: auto; margin-right: auto; line-height: 1.5;">
          Nh\u1EADp t\u00EAn s\u1EA3n ph\u1EA9m ho\u1EB7c m\u00E3 SKU tr\u00EAn thanh t\u00ECm ki\u1EBFm \u0111\u1EC3 hi\u1EC3n th\u1ECB chi ti\u1EBFt (SKU, \u1EA2nh, T\u00EAn, Size, M\u00E0u s\u1EAFc, Gi\u00E1 b\u00E1n, T\u1ED3n kho) v\u00E0 th\u00EAm v\u00E0o \u0111\u01A1n h\u00E0ng.
        </div>
      </div>
    `;
    return;
  }

  // Filter matching products
  const matches = catalogData.filter(p => {
    const name = (p.name || '').toLowerCase();
    const sku = (p.sku || '').toLowerCase();
    const cat = (p.category || '').toLowerCase();
    return name.includes(q) || sku.includes(q) || cat.includes(q);
  });

  if (matches.length === 0) {
    container.innerHTML = `
      <div style="background: #ffffff; border: 1px solid #e2e8f0; border-radius: 12px; padding: 40px 20px; text-align: center; color: #64748b;">
        <div style="font-size: 1.8rem; margin-bottom: 6px;">\u26A0\uFE0F</div>
        <div style="font-weight: 600; color: #0f172a;">Kh\u00F4ng t\u00ECm th\u1EA5y s\u1EA3n ph\u1EA9m n\u00E0o</div>
        <div style="font-size: 0.8rem; margin-top: 4px;">Kh\u00F4ng c\u00F3 m\u1EB7t h\u00E0ng n\u00E0o tr\u00F9ng kh\u1EDBp v\u1EDBi t\u1EEB kh\u00F3a "<strong>${escapeHtml(query)}</strong>".</div>
      </div>
    `;
    return;
  }

  // Render Compact Detail Table
  let html = `
    <div class="card" style="margin-top: 0; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);">
      <div style="padding: 12px 16px; border-bottom: 1px solid #e2e8f0; font-size: 0.8rem; color: #64748b; font-weight: 600;">
        T\u00ECm th\u1EA5y <strong style="color: #2563eb;">${matches.length}</strong> s\u1EA3n ph\u1EA9m ph\u00F9 h\u1EE3p:
      </div>
      <div class="table-responsive">
        <table class="custom-table pos-search-table" style="margin-bottom: 0;">
          <thead>
            <tr>
              <th style="width: 52px; text-align: center;">\u1EA2NH</th>
              <th>M\u00C3 SKU</th>
              <th>T\u00CAN S\u1EA2N PH\u1EA8M</th>
              <th>SIZE</th>
              <th>M\u00C0U S\u1EAFC</th>
              <th style="text-align: right;">GI\u00C1 B\u00C1N</th>
              <th style="text-align: center;">T\u1ED2N KHO</th>
              <th style="text-align: right; width: 110px;">THAO T\u00C1C</th>
            </tr>
          </thead>
          <tbody>
  `;

  matches.forEach(p => {
    const isImageValid = p.image && (p.image.startsWith('http://') || p.image.startsWith('https://'));
    const imgHtml = isImageValid
      ? `<img src="${p.image}" alt="${escapeHtml(p.name)}" style="width: 100%; height: 100%; object-fit: cover;" onerror="this.outerHTML='<span style=\\'font-size:1.2rem;\\'>\uD83D\uDC55</span>'">`
      : `<span style="font-size: 1.2rem;">\uD83D\uDC55</span>`;

    const isLowStock = p.stock <= p.minStock;
    const isOutOfStock = p.stock <= 0;

    html += `
      <tr>
        <td style="text-align: center;">
          <div class="pos-thumb-box" style="margin: 0 auto;">
            ${imgHtml}
          </div>
        </td>
        <td style="font-weight: 700; color: #2563eb;">${escapeHtml(p.sku)}</td>
        <td>
          <div style="font-weight: 600; color: #0f172a;">${escapeHtml(p.name)}</div>
          <div style="font-size: 0.72rem; color: #64748b;">${escapeHtml(p.category || 'Th\u1EDDi trang')}</div>
        </td>
        <td>
          <span class="badge" style="background: #f1f5f9; color: #334155;">${escapeHtml(p.size || 'M')}</span>
        </td>
        <td style="color: #475569; font-size: 0.85rem;">
          ${escapeHtml(p.color || 'Ti\u00EAu chu\u1EA9n')}
        </td>
        <td style="text-align: right; font-weight: 700; color: #0f172a;">
          ${formatVND(p.price)}
        </td>
        <td style="text-align: center;">
          <span class="badge ${isOutOfStock ? 'badge-danger' : (isLowStock ? 'badge-warning' : 'badge-success')}">
            ${p.stock}
          </span>
        </td>
        <td style="text-align: right;">
          <button type="button" class="btn btn-primary" style="padding: 5px 12px; font-size: 0.8rem; font-weight: 600;" 
                  onclick="addToCart('${p.id || p.sku}')" ${isOutOfStock ? 'disabled title="H\u1EBFt h\u00E0ng"' : ''}>
            <span>+ Th\u00EAm</span>
          </button>
        </td>
      </tr>
    `;
  });

  html += `
          </tbody>
        </table>
      </div>
    </div>
  `;

  container.innerHTML = html;
}

// Add product to active cart
function addToCart(idOrSku) {
  const prod = catalogData.find(p => (p.id && String(p.id) === String(idOrSku)) || p.sku === idOrSku);
  if (!prod) return;

  const cart = getActiveCart();
  const existing = cart.find(item => (item.id && String(item.id) === String(prod.id)) || item.sku === prod.sku);

  if (existing) {
    existing.quantity += 1;
  } else {
    cart.push({
      id: prod.id,
      sku: prod.sku,
      name: prod.name,
      quantity: 1,
      size: prod.size || 'M',
      color: prod.color || 'Tiêu chuẩn'
    });
  }

  renderOrderTabs();
  renderCart();
}

// Update quantity
function updateCartQty(index, change) {
  const cart = getActiveCart();
  if (index < 0 || index >= cart.length) return;

  cart[index].quantity += change;
  if (cart[index].quantity <= 0) {
    cart.splice(index, 1);
  }

  renderOrderTabs();
  renderCart();
}

// Set quantity directly
function setCartQty(index, val) {
  const cart = getActiveCart();
  if (index < 0 || index >= cart.length) return;

  const q = parseInt(val, 10);
  if (isNaN(q) || q <= 0) {
    cart.splice(index, 1);
  } else {
    cart[index].quantity = q;
  }

  renderOrderTabs();
  renderCart();
}

// Remove from cart
function removeFromCart(index) {
  const cart = getActiveCart();
  if (index >= 0 && index < cart.length) {
    cart.splice(index, 1);
  }
  renderOrderTabs();
  renderCart();
}

// Change size or color variant directly in cart
function changeCartItemVariant(index, field, value) {
  const cart = getActiveCart();
  if (index >= 0 && index < cart.length) {
    cart[index][field] = value;
  }
}

// Clear active cart
function clearCart() {
  const cart = getActiveCart();
  cart.length = 0;
  renderOrderTabs();
  renderCart();
}

// Render Cart Panel
function renderCart() {
  const cart = getActiveCart();
  const cartContainer = document.getElementById('cartItemsList');
  const cartCountBadge = document.getElementById('cartItemCountBadge');
  const cartSubtotalEl = document.getElementById('cartSubtotal');
  const cartTotalEl = document.getElementById('cartTotal');
  const checkoutBtn = document.getElementById('checkoutBtn');
  const cartPanel = document.getElementById('posCartPanel');
  const stockWarningBanner = document.getElementById('stockWarningBanner');
  const overstockProdName = document.getElementById('overstockProdName');
  const checkoutWarningText = document.getElementById('checkoutWarningText');
  const cartTitleHeading = document.getElementById('cartTitleHeading');

  if (cartTitleHeading) {
    cartTitleHeading.textContent = getActiveTab().name;
  }

  if (!cartContainer) return;

  // Empty cart state
  if (cart.length === 0) {
    cartContainer.innerHTML = `
      <div class="cart-empty-state" style="padding: 40px 16px; text-align: center; color: #94a3b8;">
        <svg width="44" height="44" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" style="margin-bottom: 12px; stroke: #94a3b8;">
          <circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/>
          <path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"/>
        </svg>
        <div style="font-weight: 700; color: #64748b; font-size: 0.95rem;">Gi\u1ECF h\u00E0ng tr\u1ED1ng</div>
        <div style="font-size: 0.8rem; margin-top: 4px; color: #94a3b8;">Nh\u1EADp t\u00ECm s\u1EA3n ph\u1EA9m b\u00EAn tr\u00E1i \u0111\u1EC3 b\u1EAFt \u0111\u1EA7u t\u1EA1o \u0111\u01A1n</div>
      </div>
    `;

    if (cartCountBadge) cartCountBadge.textContent = '0 s\u1EA3n ph\u1EA9m';
    if (cartSubtotalEl) cartSubtotalEl.textContent = '0 \u0111';
    if (cartTotalEl) cartTotalEl.textContent = '0 \u0111';

    if (checkoutBtn) {
      checkoutBtn.disabled = true;
      checkoutBtn.className = 'btn btn-disabled';
      checkoutBtn.innerHTML = `
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="1" y="4" width="22" height="16" rx="2" ry="2"/><line x1="1" y1="10" x2="23" y2="10"/></svg>
        <span>Thanh to\u00E1n \u00B7 0 \u0111</span>
      `;
    }

    if (stockWarningBanner) stockWarningBanner.style.display = 'none';
    if (checkoutWarningText) checkoutWarningText.style.display = 'none';
    if (cartPanel) cartPanel.classList.remove('has-stock-error');
    return;
  }

  let html = '';
  let subtotal = 0;
  let totalItemsCount = 0;
  let hasOverstock = false;
  let overstockedProductName = '';

  cart.forEach((item, index) => {
    const prod = catalogData.find(p => (p.id && item.id && String(p.id) === String(item.id)) || p.sku === item.sku);
    if (!prod) return;

    const itemSubtotal = prod.price * item.quantity;
    subtotal += itemSubtotal;
    totalItemsCount += item.quantity;

    const isOverstock = item.quantity > prod.stock;
    if (isOverstock) {
      hasOverstock = true;
      overstockedProductName = prod.name;
    }

    const isImageValid = prod.image && (prod.image.startsWith('http://') || prod.image.startsWith('https://'));
    const imgHtml = isImageValid
      ? `<img src="${prod.image}" alt="${escapeHtml(prod.name)}" class="cart-item-thumb" onerror="this.outerHTML='<span style=\\'font-size:1.4rem;\\'>👕</span>'">`
      : `<div class="cart-item-thumb" style="display:flex;align-items:center;justify-content:center;font-size:1.3rem;background:#f1f5f9;">👕</div>`;

    html += `
      <div class="cart-item-card ${isOverstock ? 'is-overstock' : ''}" id="cart-item-${prod.sku}">
        <div class="cart-item-header">
          ${imgHtml}
          <div class="cart-item-info">
            <div class="cart-item-title" style="font-weight: 700; color: #0f172a;">${escapeHtml(prod.name)}</div>
            <div style="font-size: 0.75rem; color: #2563eb; font-weight: 600;">${prod.sku} · ${formatVND(prod.price)}</div>
            
            <!-- Real Size and Color tags directly from product database -->
            <div style="display: flex; gap: 8px; margin-top: 6px; align-items: center; font-size: 0.75rem;">
              <span class="badge" style="background: #f1f5f9; color: #334155; font-weight: 700; padding: 2px 8px;">Size: ${escapeHtml(prod.size || 'M')}</span>
              <span class="badge" style="background: #f8fafc; border: 1px solid #e2e8f0; color: #475569; padding: 2px 8px;">Màu: ${escapeHtml(prod.color || 'Tiêu chuẩn')}</span>
              <span style="color: #64748b; font-size: 0.72rem;">(Tồn: <strong style="color: #059669;">${prod.stock}</strong>)</span>
            </div>
          </div>
          <button type="button" class="cart-item-remove" onclick="removeFromCart(${index})" title="Xóa khỏi giỏ">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 01-2 2H7a2 2 0 01-2-2V6m3 0V4a2 2 0 012-2h4a2 2 0 012 2v2"/></svg>
          </button>
        </div>

        <div class="cart-item-controls" style="margin-top: 8px;">
          <div class="stepper-group">
            <button type="button" class="stepper-btn" onclick="updateCartQty(${index}, -1)">&minus;</button>
            <input type="number" class="stepper-input ${isOverstock ? 'input-error' : ''}" value="${item.quantity}" min="1" onchange="setCartQty(${index}, this.value)">
            <button type="button" class="stepper-btn" onclick="updateCartQty(${index}, 1)">+</button>
          </div>
          <div class="cart-item-total ${isOverstock ? 'text-danger' : ''}">${formatVND(itemSubtotal)}</div>
        </div>

        ${isOverstock ? `
          <div class="overstock-msg" style="margin-top: 6px; color: #dc2626; font-size: 0.75rem; display: flex; align-items: center; gap: 4px;">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
            <span>V\u01B0\u1EE3t t\u1ED3n kho! Ch\u1EC9 c\u00F2n ${prod.stock} ${prod.unit || 'c\u00E1i'} trong kho.</span>
          </div>
        ` : ''}
      </div>
    `;
  });

  cartContainer.innerHTML = html;

  if (cartCountBadge) cartCountBadge.textContent = totalItemsCount + ' s\u1EA3n ph\u1EA9m';
  if (cartSubtotalEl) cartSubtotalEl.textContent = formatVND(subtotal);

  if (cartTotalEl) {
    cartTotalEl.textContent = formatVND(subtotal);
    if (hasOverstock) cartTotalEl.classList.add('text-danger');
    else cartTotalEl.classList.remove('text-danger');
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
        <span>Kh\u00F4ng th\u1EC3 thanh to\u00E1n \u00B7 V\u01B0\u1EE3t t\u1ED3n kho</span>
      `;
    } else {
      checkoutBtn.disabled = false;
      checkoutBtn.className = 'btn btn-primary';
      checkoutBtn.style.width = '100%';
      checkoutBtn.style.padding = '14px';
      checkoutBtn.innerHTML = `
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="1" y="4" width="22" height="16" rx="2" ry="2"/><line x1="1" y1="10" x2="23" y2="10"/></svg>
        <span>Thanh to\u00E1n \u00B7 ${formatVND(subtotal)}</span>
      `;
    }
  }
}

// Process Checkout
function processCheckout() {
  if (!window.HAS_ACTIVE_SHIFT) {
    alert('\u26A0\uFE0F B\u1EA1n ch\u01B0a v\u00E0o ca l\u00E0m vi\u1EC7c! Vui l\u00F2ng nh\u1EA5n "B\u1EAFt \u0111\u1EA7u ca l\u00E0m vi\u1EC7c" \u0111\u1EC3 m\u1EDF ca tr\u01B0\u1EDBc khi thanh to\u00E1n.');
    if (typeof openStartShiftModal === 'function') {
      openStartShiftModal();
    }
    return;
  }

  const cart = getActiveCart();
  if (cart.length === 0) {
    alert('Gi\u1ECF h\u00E0ng \u0111ang tr\u1ED1ng!');
    return;
  }

  const btn = document.getElementById('checkoutBtn');
  if (btn) {
    btn.disabled = true;
    btn.innerHTML = '<span>\u0110ang x\u1EED l\u00FD thanh to\u00E1n...</span>';
  }

  // Build items parameter
  const itemsParam = cart.map(i => (i.id || i.sku) + ':' + i.quantity).join(',');
  const params = new URLSearchParams();
  params.append('items', itemsParam);
  params.append('paymentMethod', 'Ti\u1EC1n m\u1EB7t');

  fetch((window.CONTEXT_PATH || '') + '/pos', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
    },
    body: params.toString()
  })
  .then(res => res.json())
  .then(data => {
    if (data.success) {
      alert('\u2705 Thanh to\u00E1n th\u00E0nh c\u00F4ng!\nM\u00E3 \u0111\u01A1n h\u00E0ng: #' + data.orderCode + '\nT\u1ED5ng ti\u1EC1n: ' + formatVND(data.totalAmount));
      window.location.reload();
    } else {
      alert('\u274C L\u1ED7i thanh to\u00E1n: ' + (data.message || 'Kh\u00F4ng th\u1EC3 ho\u00E0n t\u1EA5t \u0111\u01A1n h\u00E0ng'));
      if (btn) {
        btn.disabled = false;
        renderCart();
      }
    }
  })
  .catch(err => {
    console.error('Checkout error:', err);
    alert('\u274C Kh\u00F4ng th\u1EC3 k\u1EBFt n\u1ED1i \u0111\u1EBFn m\u00E1y ch\u1EE7. Vui l\u00F2ng ki\u1EC3m tra l\u1EA1i!');
    renderCart();
  });
}

// Utility: escape HTML
function escapeHtml(str) {
  if (!str) return '';
  return String(str)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}

// Initialization on DOM loaded
document.addEventListener('DOMContentLoaded', () => {
  renderOrderTabs();
  renderCart();
  searchProducts(''); // Shows clean empty state by default
});
