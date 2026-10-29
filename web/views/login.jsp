<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Đăng nhập · Kiotflow Retail Operations</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
  <style>
    body {
      background-color: #ffffff;
      min-height: 100vh;
      display: flex;
    }
    .login-layout {
      display: flex;
      width: 100vw;
      min-height: 100vh;
    }
    .login-banner {
      width: 48%;
      background-color: #0c1222;
      color: #ffffff;
      padding: 56px 64px;
      display: flex;
      flex-direction: column;
      justify-content: space-between;
    }
    .login-form-side {
      width: 52%;
      background-color: #ffffff;
      padding: 48px 72px;
      display: flex;
      flex-direction: column;
      justify-content: space-between;
      overflow-y: auto;
    }
    .preview-card {
      background-color: #162032;
      border: 1px solid #243048;
      border-radius: 16px;
      padding: 24px;
      margin: 40px 0;
    }
    .preview-bars {
      display: flex;
      align-items: flex-end;
      gap: 12px;
      height: 90px;
      margin: 20px 0;
      padding-bottom: 8px;
    }
    .preview-bar {
      flex: 1;
      background: #2563eb;
      opacity: 0.85;
      border-radius: 4px;
      transition: height 0.3s ease;
    }
    .preview-bar:nth-child(1) { height: 45%; }
    .preview-bar:nth-child(2) { height: 65%; }
    .preview-bar:nth-child(3) { height: 50%; }
    .preview-bar:nth-child(4) { height: 85%; }
    .preview-bar:nth-child(5) { height: 100%; }
    .preview-bar:nth-child(6) { height: 70%; }
    .preview-bar:nth-child(7) { height: 55%; background: #60a5fa; }
    
    .pill-card {
      background: #1e293b;
      border: 1px solid #334155;
      border-radius: 10px;
      padding: 10px 14px;
      display: flex;
      align-items: center;
      gap: 10px;
      font-size: 0.8rem;
    }
    .pill-grid {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 12px;
    }
    @media (max-width: 960px) {
      .login-banner { display: none; }
      .login-form-side { width: 100%; padding: 32px 24px; }
    }
  </style>
</head>
<body>

<div class="login-layout">
  <!-- LEFT BRAND BANNER -->
  <div class="login-banner">
    <div>
      <div class="brand-logo" style="padding-left: 0;">
        <div class="brand-icon">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
            <path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/>
          </svg>
        </div>
        <div>
          <span style="color:#fff;">kiotflow</span>
          <span class="brand-tag" style="color:#94a3b8; margin-left:6px;">RETAIL OPERATIONS</span>
        </div>
      </div>

      <div style="margin-top: 48px;">
        <div style="font-size: 0.75rem; font-weight: 700; color: #60a5fa; letter-spacing: 0.08em; text-transform: uppercase; margin-bottom: 12px; display: flex; align-items: center; gap: 8px;">
          <span style="display:inline-block; width:16px; height:2px; background:#3b82f6;"></span>
          HỆ THỐNG QUẢN LÝ BÁN HÀNG & TỒN KHO
        </div>
        <h1 style="font-size: 2.5rem; font-weight: 800; line-height: 1.15; letter-spacing: -0.03em; color: #ffffff; max-width: 480px;">
          Mỗi giao dịch rõ ràng. Mỗi món hàng trong tầm kiểm soát.
        </h1>
        <p style="font-size: 0.95rem; color: #94a3b8; margin-top: 16px; line-height: 1.6; max-width: 440px;">
          Từ quầy thu ngân đến đối soát cuối ngày — một không gian vận hành, đúng người và đúng quyền.
        </p>
      </div>

      <!-- Live Mockup Summary Card -->
      <div class="preview-card">
        <div style="display: flex; justify-content: space-between; align-items: center;">
          <div style="display: flex; align-items: center; gap: 8px; font-size: 0.82rem; font-weight: 600; color: #e2e8f0;">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 9l9-7 9 7v11a2 2 0 01-2 2H5a2 2 0 01-2-2z"/></svg>
            An Nhiên · Tổng quan vận hành
          </div>
          <span style="font-size: 0.7rem; font-weight: 700; color: #64748b; letter-spacing: 0.05em;">MINH HỌA</span>
        </div>

        <div style="margin-top: 18px; display: flex; align-items: baseline; justify-content: space-between;">
          <div>
            <div style="font-size: 0.72rem; color: #94a3b8;">Ước tính doanh thu tuần</div>
            <div style="font-size: 1.75rem; font-weight: 800; color: #ffffff;">11.054.000 <span style="text-decoration: underline;">đ</span></div>
          </div>
          <span class="badge" style="background:#064e3b; color:#34d399; font-size:0.75rem; padding:4px 8px;">+8,2% so với tuần trước</span>
        </div>

        <!-- Bar chart preview -->
        <div class="preview-bars">
          <div class="preview-bar" title="21/10"></div>
          <div class="preview-bar" title="22/10"></div>
          <div class="preview-bar" title="23/10"></div>
          <div class="preview-bar" title="24/10"></div>
          <div class="preview-bar" title="25/10"></div>
          <div class="preview-bar" title="26/10"></div>
          <div class="preview-bar" title="27/10"></div>
        </div>

        <div class="pill-grid">
          <div class="pill-card">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#22c55e" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
            <div>
              <div style="color:#ffffff; font-weight:600;">Đơn #BH-1042</div>
              <div style="color:#94a3b8; font-size:0.7rem;">Đã thanh toán · 408.000 đ</div>
            </div>
          </div>
          <div class="pill-card">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#60a5fa" stroke-width="2.5"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/></svg>
            <div>
              <div style="color:#ffffff; font-weight:600;">Tồn kho đồng bộ</div>
              <div style="color:#94a3b8; font-size:0.7rem;">Theo từng giao dịch</div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Banner footer trust notice -->
    <div style="display: flex; align-items: center; gap: 8px; font-size: 0.8rem; color: #64748b;">
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
      <span>Phân quyền theo vai trò · Nhật ký hoạt động minh bạch</span>
    </div>
  </div>

  <!-- RIGHT LOGIN FORM -->
  <div class="login-form-side">
    <div style="display: flex; justify-content: flex-end;">
      <a href="javascript:void(0)" onclick="alert('Hotline hỗ trợ kỹ thuật: 1900-8888\nEmail: hotro@kiotflow.vn')" style="display: flex; align-items: center; gap: 6px; font-size: 0.825rem; color: #64748b;">
        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><path d="M9.09 9a3 3 0 015.83 1c0 2-3 3-3 3M12 17h.01"/></svg>
        <span>Cần hỗ trợ đăng nhập?</span>
      </a>
    </div>

    <div style="max-width: 440px; width: 100%; margin: auto;">
      <!-- Role/Access Tag -->
      <div style="margin-bottom: 14px;">
        <span class="badge" style="background:#eff6ff; color:#2563eb; font-size:0.75rem; font-weight:700; padding:5px 12px; letter-spacing:0.02em;">
          ĐĂNG NHẬP BẰNG SĐT &amp; MÃ ĐƯỢC CẤP
        </span>
      </div>

      <h2 style="font-size: 2rem; font-weight: 800; color: #0f172a; letter-spacing: -0.02em; margin-bottom: 8px;">
        Chào mừng trở lại
      </h2>
      <p style="font-size: 0.875rem; color: #64748b; margin-bottom: 28px;">
        Đăng nhập bằng số điện thoại và mã được cấp để bắt đầu ca làm việc của bạn.
      </p>

      <!-- Error alert via JSTL -->
      <c:if test="${not empty error}">
        <div style="display:flex; align-items:flex-start; gap:10px; background:#fef2f2; border:1px solid #fca5a5; border-radius:10px; padding:12px 14px; margin-bottom:20px; color:#b91c1c; font-size:0.85rem;">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="flex-shrink:0; margin-top:2px;">
            <circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/>
          </svg>
          <div>
            <strong>Đăng nhập thất bại:</strong> ${error}
          </div>
        </div>
      </c:if>

      <form action="${pageContext.request.contextPath}/login" method="POST" id="loginForm">
        <!-- Input: Phone Number -->
        <div class="form-group" style="margin-bottom: 20px;">
          <label class="form-label" for="phone">Số điện thoại</label>
          <div class="input-icon-wrapper">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
              <rect x="5" y="2" width="14" height="20" rx="2" ry="2"/>
              <line x1="12" y1="18" x2="12.01" y2="18"/>
            </svg>
            <input type="text" id="phone" name="phone" class="form-input" placeholder="Nhập số điện thoại của bạn" value="${param.phone != null ? param.phone : '090 987 6543'}" required>
          </div>
        </div>

        <!-- Input: Passcode / Mã được cấp -->
        <div class="form-group" style="margin-bottom: 18px;">
          <label class="form-label" for="passcode">Mã được cấp</label>
          <div class="input-icon-wrapper">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
              <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>
            </svg>
            <input type="password" id="passcode" name="passcode" class="form-input" placeholder="Ví dụ: 123456" value="123456" required>
          </div>
        </div>

        <!-- Remember Me & Forgot Passcode -->
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; font-size: 0.85rem;">
          <label style="display: flex; align-items: center; gap: 8px; cursor: pointer; color: #475569;">
            <input type="checkbox" name="rememberPhone" checked style="accent-color: #2563eb; width: 16px; height: 16px;">
            <span>Ghi nhớ số điện thoại</span>
          </label>
          <a href="javascript:void(0)" onclick="alert('Vui lòng liên hệ Super Admin hoặc Quản lý chi nhánh để nhận lại mã cấp mới.')" style="font-size: 0.85rem; font-weight: 600;">Nhận lại mã</a>
        </div>

        <!-- Submit Button -->
        <button type="submit" class="btn btn-primary" style="width: 100%; padding: 12px; font-size: 0.95rem; border-radius: 10px;">
          <span>Đăng nhập</span>
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M5 12h14M12 5l7 7-7 7"/></svg>
        </button>
      </form>

      <!-- Role Access Quick Info & Shortcuts for Testing -->
      <div style="margin-top: 36px; padding-top: 24px; border-top: 1px solid #f1f5f9;">
        <div style="font-size: 0.825rem; font-weight: 700; color: #1e293b; margin-bottom: 10px;">
          Một tài khoản, đúng quyền truy cập
        </div>
        <div style="display: flex; gap: 8px; margin-bottom: 12px;">
          <a href="${pageContext.request.contextPath}/views/admin_users.jsp" class="badge" style="background:#f1f5f9; color:#334155; padding:6px 12px; cursor:pointer;" title="Đăng nhập thử vai trò Super Admin">Super Admin</a>
          <a href="${pageContext.request.contextPath}/views/dashboard.jsp" class="badge" style="background:#f1f5f9; color:#334155; padding:6px 12px; cursor:pointer;" title="Đăng nhập thử vai trò Quản lý">Quản lý</a>
          <a href="${pageContext.request.contextPath}/views/pos.jsp" class="badge" style="background:#f1f5f9; color:#334155; padding:6px 12px; cursor:pointer;" title="Đăng nhập thử vai trò Nhân viên">Nhân viên</a>
        </div>
        <p style="font-size: 0.75rem; color: #94a3b8; line-height: 1.5;">
          Không có đăng ký công khai. Liên hệ Super Admin để được cấp mã hoặc khôi phục quyền truy cập. Nhân viên không có quyền quản trị tài khoản.
        </p>
      </div>
    </div>

    <!-- Bottom copyright -->
    <div style="display: flex; justify-content: space-between; align-items: center; font-size: 0.78rem; color: #94a3b8; padding-top: 24px;">
      <div>&copy; 2026 kiotflow</div>
      <a href="javascript:void(0)" style="color: #94a3b8;">Bảo mật &amp; điều khoản</a>
    </div>
  </div>
</div>

</body>
</html>

