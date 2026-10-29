/**
 * KIOTFLOW - Products Management & Stock Inflow Approvals
 */

// Tab Switcher (Hàng hóa <-> Duyệt hàng về)
function switchProductTab(tabName) {
  const productsTabBtn = document.getElementById('tabBtnProducts');
  const approvalsTabBtn = document.getElementById('tabBtnApprovals');
  const productsView = document.getElementById('productsTableView');
  const approvalsView = document.getElementById('approvalsTableView');

  if (tabName === 'approvals') {
    productsTabBtn.classList.remove('active');
    approvalsTabBtn.classList.add('active');
    productsView.style.display = 'none';
    approvalsView.style.display = 'block';
  } else {
    approvalsTabBtn.classList.remove('active');
    productsTabBtn.classList.add('active');
    approvalsView.style.display = 'none';
    productsView.style.display = 'block';
  }
}

// Open Product Edit Modal with Data
function openProductEditModal(sku, name, category, unit, costPrice, sellingPrice, stock, minStock, image) {
  document.getElementById('modalProductSku').value = sku;
  document.getElementById('modalProductName').value = name;
  document.getElementById('modalProductCategory').value = category;
  document.getElementById('modalProductUnit').value = unit;
  document.getElementById('modalProductCost').value = costPrice;
  document.getElementById('modalProductPrice').value = sellingPrice;
  document.getElementById('modalProductStock').value = stock;
  document.getElementById('modalProductMinStock').value = minStock;

  const contextPath = window.CONTEXT_PATH || '';
  document.getElementById('productImagePreview').src = contextPath + '/assets/images/' + (image || 'CF01.svg');
  document.getElementById('modalProductSubtitle').textContent = `${sku} · ${name} · Cập nhật thông tin trong danh mục`;

  checkStockThresholdWarning();
  openModal('productEditModal');
}

// Trigger New Product Modal
function openNewProductModal() {
  document.getElementById('modalProductSku').value = '';
  document.getElementById('modalProductName').value = '';
  document.getElementById('modalProductCost').value = '';
  document.getElementById('modalProductPrice').value = '';
  document.getElementById('modalProductStock').value = '0';
  document.getElementById('modalProductMinStock').value = '10';
  document.getElementById('modalProductSubtitle').textContent = 'Thêm sản phẩm mới vào danh mục hàng hóa';
  openModal('productEditModal');
}

// Live Warning in Modal if Stock <= MinStock
function checkStockThresholdWarning() {
  const stock = parseInt(document.getElementById('modalProductStock').value) || 0;
  const minStock = parseInt(document.getElementById('modalProductMinStock').value) || 0;
  const warningEl = document.getElementById('modalStockWarning');

  if (stock <= minStock) {
    warningEl.style.display = 'flex';
  } else {
    warningEl.style.display = 'none';
  }
}

// Handle Image File Selection & Preview
function previewSelectedImage(input) {
  if (input.files && input.files[0]) {
    const reader = new FileReader();
    reader.onload = function(e) {
      document.getElementById('productImagePreview').src = e.target.result;
    };
    reader.readAsDataURL(input.files[0]);
  }
}

// Inflow Approvals Actions
function approveInflow(ticketId, productName, qty) {
  if (confirm(`Xác nhận DUYỆT phiếu ${ticketId}?\nCộng +${qty} ${productName} vào tồn kho ngay lập tức.`)) {
    alert(`Đã duyệt thành công phiếu ${ticketId}! Số lượng tồn kho đã được cập nhật.`);
    const row = document.getElementById(`ticket-row-${ticketId}`);
    if (row) {
      row.style.opacity = '0.4';
      row.style.pointerEvents = 'none';
    }
  }
}

// Open Reject Inflow Modal
function openRejectModal(ticketId, productName, supplier, sender, qty, currentStock) {
  document.getElementById('rejectTicketIdTitle').textContent = ticketId;
  document.getElementById('rejectTicketSub').textContent = `${productName} · Nhà cung cấp ${supplier} · Người gửi: ${sender}`;
  document.getElementById('rejectQtyDisplay').textContent = `${qty} đơn vị`;
  document.getElementById('rejectStockDisplay').textContent = `${currentStock} đơn vị`;
  document.getElementById('rejectReasonInput').value = '';
  document.getElementById('rejectReasonError').style.display = 'none';
  document.getElementById('rejectReasonInput').classList.remove('is-invalid');
  openModal('rejectTicketModal');
}

// Submit Rejection with Validation
function submitRejection() {
  const reasonInput = document.getElementById('rejectReasonInput');
  const errorEl = document.getElementById('rejectReasonError');

  if (!reasonInput.value.trim()) {
    reasonInput.classList.add('is-invalid');
    errorEl.style.display = 'flex';
    reasonInput.focus();
    return;
  }

  const ticketId = document.getElementById('rejectTicketIdTitle').textContent;
  alert(`Đã TỪ CHỐI phiếu ${ticketId}.\nLý do: "${reasonInput.value.trim()}" đã được ghi vào nhật ký và gửi thông báo.`);
  closeModal('rejectTicketModal');

  const row = document.getElementById(`ticket-row-${ticketId}`);
  if (row) {
    row.style.opacity = '0.4';
    row.style.pointerEvents = 'none';
  }
}

// URL param listener to switch to tab if ?tab=approvals
document.addEventListener('DOMContentLoaded', function() {
  const urlParams = new URLSearchParams(window.location.search);
  if (urlParams.get('tab') === 'approvals') {
    switchProductTab('approvals');
  }
});

