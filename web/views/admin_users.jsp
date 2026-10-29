<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="activeMenu" value="admin_users" />
<c:set var="currentRole" value="admin" />
<c:set var="breadcrumbCurrent" value="Tài khoản & mã" />

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Tài khoản & mã đăng nhập · Kiotflow</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
  <script>
    function copyToClipboard(text) {
      navigator.clipboard.writeText(text);
      alert('Đã sao chép mã đăng nhập: ' + text);
    }
    function revokeUser(code, name) {
      if (confirm('Xác nhận THU HỒI mã ' + code + ' của nhân sự ' + name + '?\nNgười dùng sẽ bị đăng xuất và không thể đăng nhập.')) {
        alert('Đã thu hồi quyền đăng nhập của ' + name);
        location.reload();
      }
    }
    function deleteUserCode(code, name) {
      if (confirm('Xác nhận XÓA VĨNH VIỄN mã ' + code + ' của ' + name + '?\nLịch sử đơn hàng và kiểm kê của nhân sự vẫn được bảo lưu.')) {
        alert('Đã xóa mã ' + code);
        location.reload();
      }
    }
  </script>
</head>
<body>

<div class="app-container">
  <jsp:include page="/common/sidebar.jsp" />

  <div class="main-content">
    <jsp:include page="/common/header.jsp" />

    <div class="page-body">
      <!-- Page Top Header -->
      <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 20px;">
        <div>
          <h1 style="font-size: 1.85rem; font-weight: 800; color: #0f172a; letter-spacing: -0.02em;">Tài khoản &amp; mã đăng nhập</h1>
          <div style="font-size: 0.85rem; color: #64748b; margin-top: 4px;">
            Quản lý quyền truy cập tập trung · 6 tài khoản · Đăng nhập bằng Số điện thoại + Mã được cấp
          </div>
        </div>
        <button type="button" class="btn btn-outline" onclick="alert('Đang trích xuất danh sách tài khoản...')">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4M7 10l5 5 5-5M12 15V3"/></svg>
          <span>Xuất tài khoản</span>
        </button>
      </div>

      <!-- Blue Role Description Notice -->
      <div style="display: flex; align-items: flex-start; gap: 12px; background: #eff6ff; border: 1px solid #bfdbfe; border-radius: 12px; padding: 14px 18px; margin-bottom: 24px; font-size: 0.825rem; color: #1e40af; line-height: 1.5;">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="flex-shrink:0; margin-top:1px;"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
        <div>
          Super Admin cấp/thu hồi mã và thay đổi vai trò. Quản lý phụ trách hàng hóa, duyệt kho, kiểm kê; Nhân viên bán hàng và thực hiện kiểm kê được giao. Tài khoản đăng nhập bằng Số điện thoại + Mã được cấp.
        </div>
      </div>

      <!-- Main Layout: Table on Left, Action Cards on Right -->
      <div style="display: grid; grid-template-columns: 1fr 360px; gap: 24px; align-items: start;">
        <!-- LEFT: ACCOUNTS TABLE -->
        <div>
          <div class="card">
            <!-- Search & Filter Bar -->
            <div style="padding: 16px 20px; display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--border);">
              <div class="input-icon-wrapper" style="flex: 1; max-width: 450px;">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                <input type="text" class="form-input" placeholder="Tìm tên hoặc số điện thoại...">
              </div>
              <select class="form-select" style="width: auto; font-size: 0.85rem;">
                <option value="all">Vai trò: Tất cả</option>
                <option value="admin">Super Admin</option>
                <option value="manager">Quản lý</option>
                <option value="staff">Nhân viên</option>
              </select>
            </div>

            <!-- Table -->
            <div class="table-responsive">
              <table class="custom-table">
                <thead>
                  <tr>
                    <th>Tài khoản</th>
                    <th>Số điện thoại</th>
                    <th>Mã đăng nhập</th>
                    <th>Vai trò / Đổi</th>
                    <th>Trạng thái</th>
                    <th style="text-align: right;">Thao tác</th>
                  </tr>
                </thead>
                <tbody>
                  <!-- Row 1: Mai Anh (Super Admin) -->
                  <tr>
                    <td>
                      <div style="font-weight: 700; color: #0f172a;">Mai Anh</div>
                      <div style="font-size: 0.72rem; color: #64748b;">27/10 · 10:25</div>
                    </td>
                    <td style="font-weight: 500;">090 123 4123</td>
                    <td style="font-family: monospace; font-weight: 700; color: #0f172a;">AN-SA-001</td>
                    <td style="font-weight: 600; color: #475569;">Super Admin</td>
                    <td><span class="badge badge-success">Đang hoạt động</span></td>
                    <td style="text-align: right;">
                      <span title="Không thể thu hồi Super Admin đang đăng nhập">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#94a3b8" stroke-width="2"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0110 0v4"/></svg>
                      </span>
                    </td>
                  </tr>

                  <!-- Row 2: Nguyễn Minh Hà (Quản lý) -->
                  <tr>
                    <td>
                      <div style="font-weight: 700; color: #0f172a;">Nguyễn Minh Hà</div>
                      <div style="font-size: 0.72rem; color: #64748b;">27/10 · 10:30</div>
                    </td>
                    <td style="font-weight: 500;">090 987 6543</td>
                    <td style="font-family: monospace; font-weight: 700; color: #0f172a;">AN-QL-001</td>
                    <td>
                      <select class="form-select" style="width: auto; padding: 4px 8px; font-size: 0.8rem; font-weight: 600; color: #2563eb;" onchange="alert('Đã thay đổi vai trò của Nguyễn Minh Hà thành: ' + this.value)">
                        <option value="manager" selected>Quản lý</option>
                        <option value="staff">Nhân viên</option>
                        <option value="admin">Super Admin</option>
                      </select>
                    </td>
                    <td><span class="badge badge-success">Đang hoạt động</span></td>
                    <td style="text-align: right;">
                      <a href="javascript:void(0)" onclick="revokeUser('AN-QL-001', 'Nguyễn Minh Hà')" style="color: #dc2626; font-size: 0.825rem; font-weight: 600;">Thu hồi</a>
                    </td>
                  </tr>

                  <!-- Row 3: Lê Lan Anh (Nhân viên) -->
                  <tr>
                    <td>
                      <div style="font-weight: 700; color: #0f172a;">Lê Lan Anh</div>
                      <div style="font-size: 0.72rem; color: #64748b;">27/10 · 10:24</div>
                    </td>
                    <td style="font-weight: 500;">090 555 1122</td>
                    <td style="font-family: monospace; font-weight: 700; color: #0f172a;">AN-NV-002</td>
                    <td>
                      <select class="form-select" style="width: auto; padding: 4px 8px; font-size: 0.8rem; font-weight: 600; color: #2563eb;" onchange="alert('Đã thay đổi vai trò của Lê Lan Anh thành: ' + this.value)">
                        <option value="staff" selected>Nhân viên</option>
                        <option value="manager">Quản lý</option>
                      </select>
                    </td>
                    <td><span class="badge badge-success">Đang hoạt động</span></td>
                    <td style="text-align: right;">
                      <a href="javascript:void(0)" onclick="revokeUser('AN-NV-002', 'Lê Lan Anh')" style="color: #dc2626; font-size: 0.825rem; font-weight: 600;">Thu hồi</a>
                    </td>
                  </tr>

                  <!-- Row 4: Trần Quốc Bảo (Nhân viên) -->
                  <tr>
                    <td>
                      <div style="font-weight: 700; color: #0f172a;">Trần Quốc Bảo</div>
                      <div style="font-size: 0.72rem; color: #64748b;">27/10 · 10:29</div>
                    </td>
                    <td style="font-weight: 500;">090 333 7788</td>
                    <td style="font-family: monospace; font-weight: 700; color: #0f172a;">AN-NV-003</td>
                    <td>
                      <select class="form-select" style="width: auto; padding: 4px 8px; font-size: 0.8rem; font-weight: 600; color: #2563eb;" onchange="alert('Đã thay đổi vai trò của Trần Quốc Bảo thành: ' + this.value)">
                        <option value="staff" selected>Nhân viên</option>
                        <option value="manager">Quản lý</option>
                      </select>
                    </td>
                    <td><span class="badge badge-success">Đang hoạt động</span></td>
                    <td style="text-align: right;">
                      <a href="javascript:void(0)" onclick="revokeUser('AN-NV-003', 'Trần Quốc Bảo')" style="color: #dc2626; font-size: 0.825rem; font-weight: 600;">Thu hồi</a>
                    </td>
                  </tr>

                  <!-- Row 5: Đỗ Hoàng Nam (Chờ kích hoạt) -->
                  <tr>
                    <td>
                      <div style="font-weight: 700; color: #0f172a;">Đỗ Hoàng Nam</div>
                      <div style="font-size: 0.72rem; color: #64748b;">Chưa đăng nhập</div>
                    </td>
                    <td style="font-weight: 500;">090 999 0000</td>
                    <td style="font-family: monospace; font-weight: 700; color: #0f172a;">AN-NV-005</td>
                    <td>
                      <select class="form-select" style="width: auto; padding: 4px 8px; font-size: 0.8rem; font-weight: 600; color: #2563eb;">
                        <option value="staff" selected>Nhân viên</option>
                        <option value="manager">Quản lý</option>
                      </select>
                    </td>
                    <td><span class="badge badge-warning">Chờ kích hoạt</span></td>
                    <td style="text-align: right;">
                      <a href="javascript:void(0)" onclick="revokeUser('AN-NV-005', 'Đỗ Hoàng Nam')" style="color: #dc2626; font-size: 0.825rem; font-weight: 600;">Thu hồi</a>
                    </td>
                  </tr>

                  <!-- Row 6: Phạm Thu Trang (Đã thu hồi) -->
                  <tr>
                    <td>
                      <div style="font-weight: 700; color: #0f172a;">Phạm Thu Trang</div>
                      <div style="font-size: 0.72rem; color: #64748b;">26/10 · 14:20</div>
                    </td>
                    <td style="font-weight: 500;">090 777 2233</td>
                    <td style="font-family: monospace; font-weight: 700; color: #94a3b8;">AN-NV-004</td>
                    <td>
                      <select class="form-select" style="width: auto; padding: 4px 8px; font-size: 0.8rem; font-weight: 600; color: #94a3b8;" disabled>
                        <option value="staff">Nhân viên</option>
                      </select>
                    </td>
                    <td><span class="badge badge-gray">Đã thu hồi</span></td>
                    <td style="text-align: right;">
                      <a href="javascript:void(0)" onclick="deleteUserCode('AN-NV-004', 'Phạm Thu Trang')" style="color: #dc2626; font-size: 0.825rem; font-weight: 600;">Xóa mã</a>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>

            <!-- Pagination Bar -->
            <div style="display: flex; justify-content: space-between; align-items: center; padding: 14px 20px; border-top: 1px solid var(--border); font-size: 0.8rem; color: #64748b;">
              <div>Hiển thị 1–6 trong 6 tài khoản</div>
              <div style="display: flex; gap: 6px;">
                <button type="button" class="btn btn-outline" style="padding: 4px 8px; font-size: 0.75rem;">&lt;</button>
                <button type="button" class="btn btn-primary" style="padding: 4px 10px; font-size: 0.75rem;">1</button>
                <button type="button" class="btn btn-outline" style="padding: 4px 8px; font-size: 0.75rem;">&gt;</button>
              </div>
            </div>
          </div>

          <!-- Table Bottom Danger Notice -->
          <div style="display: flex; align-items: flex-start; gap: 12px; background: #fff5f5; border: 1px solid #fecaca; border-radius: 12px; padding: 16px 20px; margin-top: 20px;">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#ef4444" stroke-width="2" style="flex-shrink:0; margin-top:2px;"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
            <div style="font-size: 0.825rem; color: #991b1b; line-height: 1.5;">
              <strong style="color: #7f1d1d; display: block; margin-bottom: 2px;">Thu hồi trước, xóa mã sau</strong>
              Chỉ xóa mã đã thu hồi sau khi xác nhận. Người dùng mất quyền đăng nhập; đơn hàng, kiểm kê và nhật ký vẫn được giữ nguyên. Không thể xóa Super Admin đang đăng nhập.
            </div>
          </div>
        </div>

        <!-- RIGHT: ISSUE CODE & ROLE INFO -->
        <div style="display: flex; flex-direction: column; gap: 20px;">
          <!-- Card 1: Issue Code Form -->
          <div class="card" style="padding: 24px;">
            <div style="display: flex; align-items: center; gap: 8px; margin-bottom: 6px;">
              <div style="width: 28px; height: 28px; border-radius: 6px; background: #eff6ff; color: #2563eb; display: flex; align-items: center; justify-content: center;">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M21 2l-2 2m-7.61 7.61a5.5 5.5 0 11-7.778 7.778 5.5 5.5 0 017.777-7.777zm0 0L15.5 7.5m0 0l3 3L22 7l-3-3m-3.5 3.5L19 4"/></svg>
              </div>
              <h2 style="font-size: 1.15rem; font-weight: 700; color: #0f172a;">Cấp mã đăng nhập</h2>
            </div>
            <p style="font-size: 0.78rem; color: #64748b; margin-bottom: 18px;">
              Tạo mã riêng cho từng thành viên. Đăng nhập bằng Số điện thoại + Mã được cấp.
            </p>

            <form action="${pageContext.request.contextPath}/admin/users" method="POST" onsubmit="event.preventDefault(); alert('Cấp mã đăng nhập thành công!');">
              <div class="form-group">
                <label class="form-label">Họ và tên *</label>
                <input type="text" class="form-input" value="Đỗ Hoàng Nam" required>
              </div>

              <div class="form-group">
                <label class="form-label">Số điện thoại *</label>
                <input type="text" class="form-input" value="090 999 0000" required>
              </div>

              <div class="form-group">
                <label class="form-label">Vai trò *</label>
                <select class="form-select" required>
                  <option value="staff" selected>Nhân viên</option>
                  <option value="manager">Quản lý</option>
                  <option value="admin">Super Admin</option>
                </select>
              </div>

              <button type="submit" class="btn btn-primary" style="width: 100%; padding: 12px; margin-top: 8px;">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                <span>Cấp mã mới</span>
              </button>
            </form>

            <!-- Success Issued Code Result Card -->
            <div style="margin-top: 24px; padding-top: 20px; border-top: 1px solid var(--border);">
              <span class="badge badge-success" style="font-size: 0.75rem; padding: 4px 10px; margin-bottom: 10px;">
                Đã cấp lúc 10:05 hôm nay
              </span>

              <div style="background: #eff6ff; border: 1.5px dashed #60a5fa; border-radius: 12px; padding: 16px; margin: 10px 0; display: flex; align-items: center; justify-content: space-between;">
                <div>
                  <div style="font-size: 0.72rem; color: #2563eb; font-weight: 700; text-transform: uppercase;">Mã đăng nhập</div>
                  <div style="font-size: 1.5rem; font-weight: 800; font-family: monospace; color: #1e40af; letter-spacing: 0.05em;">AN-NV-005</div>
                </div>
                <button type="button" class="btn btn-outline" style="padding: 6px 10px; background: #fff;" onclick="copyToClipboard('AN-NV-005')" title="Sao chép">
                  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"/><path d="M5 15H4a2 2 0 01-2-2V4a2 2 0 012-2h9a2 2 0 012 2v1"/></svg>
                </button>
              </div>

              <div style="font-size: 0.75rem; color: #64748b; line-height: 1.45;">
                Giao mã và hướng dẫn đăng nhập qua kênh bảo mật. Yêu cầu đổi mã khi đăng nhập lần đầu.
              </div>
            </div>
          </div>

          <!-- Card 2: Controlled Role Switching -->
          <div class="card" style="padding: 20px 24px;">
            <div style="display: flex; align-items: center; gap: 8px; margin-bottom: 6px;">
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#2563eb" stroke-width="2"><path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 00-3-3.87M16 3.13a4 4 0 010 7.75"/></svg>
              <h3 style="font-size: 0.95rem; font-weight: 700; color: #0f172a;">Đổi vai trò có kiểm soát</h3>
            </div>
            <p style="font-size: 0.78rem; color: #64748b; line-height: 1.45; margin-bottom: 12px;">
              Chọn vai trò tại từng tài khoản. Quyền mới áp dụng từ phiên đăng nhập tiếp theo và luôn được lưu vào nhật ký.
            </p>
            <a href="${pageContext.request.contextPath}/views/activity_log.jsp" style="display: inline-flex; align-items: center; gap: 6px; font-size: 0.825rem; font-weight: 600; color: #2563eb;">
              <span>Xem nhật ký hoạt động</span>
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg>
            </a>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>

<jsp:include page="/common/footer.jsp" />

