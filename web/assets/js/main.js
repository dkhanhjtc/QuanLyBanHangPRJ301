/**
 * KIOTFLOW - Global Application JavaScript
 */

// Dropdown Toggle
function toggleUserDropdown(event) {
  event.stopPropagation();
  const alertDropdown = document.getElementById('stockAlertDropdown');
  if (alertDropdown) alertDropdown.style.display = 'none';

  const dropdown = document.getElementById('userDropdown');
  if (dropdown) {
    dropdown.style.display = (dropdown.style.display === 'block') ? 'none' : 'block';
  }
}

// Stock Alert Dropdown Toggle
function toggleStockAlertDropdown(event) {
  event.stopPropagation();
  const userDropdown = document.getElementById('userDropdown');
  if (userDropdown) userDropdown.style.display = 'none';

  const dropdown = document.getElementById('stockAlertDropdown');
  if (dropdown) {
    dropdown.style.display = (dropdown.style.display === 'block') ? 'none' : 'block';
  }
}

// Close Dropdowns on Click Outside
document.addEventListener('click', function(e) {
  const dropdown = document.getElementById('userDropdown');
  if (dropdown && dropdown.style.display === 'block') {
    if (!e.target.closest('#userMenuToggle')) {
      dropdown.style.display = 'none';
    }
  }

  const alertDropdown = document.getElementById('stockAlertDropdown');
  if (alertDropdown && alertDropdown.style.display === 'block') {
    if (!e.target.closest('#stockAlertBtn')) {
      alertDropdown.style.display = 'none';
    }
  }
});

// Modal Utilities
function openModal(modalId) {
  const modal = (typeof modalId === 'string') ? document.getElementById(modalId) : modalId;
  if (modal) {
    modal.classList.add('show');
    modal.style.display = 'flex';
    document.body.style.overflow = 'hidden';
  }
}

function closeModal(modalId) {
  if (!modalId) {
    document.querySelectorAll('.modal-backdrop').forEach(function(m) {
      m.classList.remove('show');
      m.style.display = 'none';
    });
    document.body.style.overflow = '';
    return;
  }
  const modal = (typeof modalId === 'string') ? document.getElementById(modalId) : modalId;
  if (modal) {
    modal.classList.remove('show');
    modal.style.display = 'none';
    document.body.style.overflow = '';
  }
}

// Global window reference
window.openModal = openModal;
window.closeModal = closeModal;

// Auto-bind click handler on all .modal-close and backdrop clicks
document.addEventListener('DOMContentLoaded', function() {
  document.querySelectorAll('.modal-close').forEach(function(btn) {
    btn.addEventListener('click', function(e) {
      e.preventDefault();
      const parentModal = btn.closest('.modal-backdrop');
      if (parentModal) {
        closeModal(parentModal);
      }
    });
  });
});

// Close modal when clicking directly on backdrop
document.addEventListener('click', function(e) {
  if (e.target && e.target.classList && e.target.classList.contains('modal-backdrop')) {
    closeModal(e.target);
  }
});

// Close modal when pressing ESC
document.addEventListener('keydown', function(e) {
  if (e.key === 'Escape' || e.keyCode === 27) {
    document.querySelectorAll('.modal-backdrop').forEach(function(m) {
      if (m.classList.contains('show') || m.style.display === 'flex' || m.style.display === 'block') {
        closeModal(m);
      }
    });
  }
});

// Format Currency VND helper (e.g. 408000 -> 408.000 VNĐ)
function formatVND(value) {
  return new Intl.NumberFormat('vi-VN').format(value) + ' VNĐ';
}

