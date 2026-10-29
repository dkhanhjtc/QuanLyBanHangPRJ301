/**
 * KIOTFLOW - Global Application JavaScript
 */

// Dropdown Toggle
function toggleUserDropdown(event) {
  event.stopPropagation();
  const dropdown = document.getElementById('userDropdown');
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
});

// Modal Utilities
function openModal(modalId) {
  const modal = document.getElementById(modalId);
  if (modal) {
    modal.classList.add('show');
    document.body.style.overflow = 'hidden';
  }
}

function closeModal(modalId) {
  const modal = document.getElementById(modalId);
  if (modal) {
    modal.classList.remove('show');
    document.body.style.overflow = '';
  }
}

// Close modal when clicking backdrop
document.addEventListener('click', function(e) {
  if (e.target.classList.contains('modal-backdrop')) {
    e.target.classList.remove('show');
    document.body.style.overflow = '';
  }
});

// Format Currency VND helper (e.g. 408000 -> 408.000 đ)
function formatVND(value) {
  return new Intl.NumberFormat('vi-VN').format(value) + ' đ';
}

