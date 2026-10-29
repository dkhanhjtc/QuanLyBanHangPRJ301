<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="activeMenu" value="activity_log" />
<c:set var="currentRole" value="admin" />
<c:set var="breadcrumbCurrent" value="Nhật ký hoạt động" />

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Nhật ký hoạt động · Kiotflow</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
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
          <h1 style="font-size: 1.85rem; font-weight: 800; color: #0f172a; letter-spacing: -0.02em;">Nhật ký hoạt động</h1>
          <div style="font-size: 0.85rem; color: #64748b; margin-top: 4px;">
            Theo dõi ai đã làm gì, khi nào và trên bản ghi nào · Dữ liệu minh họa
          </div>
        </div>
        <button type="button" class="btn btn-outline" onclick="alert('Đang trích xuất nhật ký hoạt động hệ thống...')">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4M7 10l5 5 5-5M12 15V3"/></svg>
          <span>Xuất nhật ký</span>
        </button>
      </div>

      <!-- Blue Audit Notice -->
      <div style="display: flex; justify-content: space-between; align-items: center; background: #eff6ff; border: 1px solid #bfdbfe; border-radius: 12px; padding: 14px 20px; margin-bottom: 24px; font-size: 0.825rem; color: #1e40af;">
        <div style="display: flex; align-items: center; gap: 10px;">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
          <span>Nhật ký chỉ đọc, không thể sửa hoặc xóa. Các thay đổi quyền và tồn kho được ghi lại để truy vết.</span>
        </div>
        <span style="font-weight: 600; color: #2563eb;">Múi giờ GMT+7</span>
      </div>

      <!-- Main Log Card -->
      <div class="card">
        <!-- Filter Row -->
        <div style="padding: 16px 20px; display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--border); flex-wrap: wrap; gap: 12px;">
          <div style="display: flex; gap: 10px; align-items: center; flex: 1;">
            <div class="input-icon-wrapper" style="flex: 1; max-width: 320px;">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
              <input type="text" class="form-input" placeholder="Tìm người dùng, mã bản ghi...">
            </div>

            <button type="button" class="btn btn-outline" style="font-size: 0.85rem;">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
              <span>26–27/10/2026</span>
            </button>

            <select class="form-select" style="width: auto; font-size: 0.85rem;">
              <option value="all">Tất cả vai trò</option>
              <option value="admin">Super Admin</option>
              <option value="manager">Quản lý</option>
              <option value="staff">Nhân viên</option>
            </select>

            <select class="form-select" style="width: auto; font-size: 0.85rem;">
              <option value="all">Hành động</option>
              <option value="sales">Bán hàng</option>
              <option value="inflow">Duyệt kho</option>
              <option value="stocktake">Kiểm kê</option>
              <option value="auth">Phân quyền</option>
            </select>

            <select class="form-select" style="width: auto; font-size: 0.85rem;">
              <option value="all">Kết quả</option>
              <option value="success">Thành công / Đã duyệt</option>
              <option value="rejected">Đã từ chối</option>
              <option value="sent">Đã gửi</option>
            </select>
          </div>

          <button type="button" class="icon-button" title="Làm mới nhật ký" onclick="location.reload()">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="23 4 23 10 17 10"/><polyline points="1 20 1 14 7 14"/><path d="M3.51 9a9 9 0 0114.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0020.49 15"/></svg>
          </button>
        </div>

        <!-- Table -->
        <div class="table-responsive">
          <table class="custom-table">
            <thead>
              <tr>
                <th>Thời gian</th>
                <th>Người thực hiện</th>
                <th>Vai trò</th>
                <th>Hành động / Chi tiết</th>
                <th>Bản ghi</th>
                <th>Kết quả</th>
              </tr>
            </thead>
            <tbody>
              <!-- Row 1 -->
              <tr>
                <td>
                  <div style="font-weight: 700; color: #0f172a;">10:29:02</div>
                  <div style="font-size: 0.72rem; color: #64748b;">27/10/2026</div>
                </td>
                <td style="font-weight: 600; color: #0f172a;">Trần Quốc Bảo</td>
                <td style="font-size: 0.8rem; color: #64748b;">Nhân viên</td>
                <td>
                  <div style="font-weight: 600; color: #0f172a;">Gửi kết quả kiểm kê</div>
                  <div style="font-size: 0.75rem; color: #64748b;">3 sản phẩm · 2 chênh lệch · Chờ Quản lý duyệt.</div>
                </td>
                <td>
                  <div style="font-weight: 700; color: #2563eb;">KK-101</div>
                  <div style="font-size: 0.72rem; color: #64748b;">Kiểm kê</div>
                </td>
                <td><span class="badge badge-primary">Đã gửi</span></td>
              </tr>

              <!-- Row 2 -->
              <tr>
                <td>
                  <div style="font-weight: 700; color: #0f172a;">10:25:18</div>
                  <div style="font-size: 0.72rem; color: #64748b;">27/10/2026</div>
                </td>
                <td style="font-weight: 600; color: #0f172a;">Mai Anh</td>
                <td style="font-size: 0.8rem; color: #64748b;">Super Admin</td>
                <td>
                  <div style="font-weight: 600; color: #0f172a;">Xóa mã đã thu hồi</div>
                  <div style="font-size: 0.75rem; color: #64748b;">Xóa quyền đăng nhập; giữ nguyên lịch sử.</div>
                </td>
                <td>
                  <div style="font-weight: 700; color: #2563eb;">AN-NV-006</div>
                  <div style="font-size: 0.72rem; color: #64748b;">Tài khoản</div>
                </td>
                <td><span class="badge badge-success">Thành công</span></td>
              </tr>

              <!-- Row 3 -->
              <tr>
                <td>
                  <div style="font-weight: 700; color: #0f172a;">10:24:36</div>
                  <div style="font-size: 0.72rem; color: #64748b;">27/10/2026</div>
                </td>
                <td style="font-weight: 600; color: #0f172a;">Lê Lan Anh</td>
                <td style="font-size: 0.8rem; color: #64748b;">Nhân viên</td>
                <td>
                  <div style="font-weight: 600; color: #0f172a;">Thanh toán đơn bán hàng</div>
                  <div style="font-size: 0.75rem; color: #64748b;">408.000 đ · Tiền mặt · Trừ tồn 4 sản phẩm.</div>
                </td>
                <td>
                  <div style="font-weight: 700; color: #2563eb;">BH-1042</div>
                  <div style="font-size: 0.72rem; color: #64748b;">Bán hàng</div>
                </td>
                <td><span class="badge badge-success">Thành công</span></td>
              </tr>

              <!-- Row 4 -->
              <tr>
                <td>
                  <div style="font-weight: 700; color: #0f172a;">10:05:12</div>
                  <div style="font-size: 0.72rem; color: #64748b;">27/10/2026</div>
                </td>
                <td style="font-weight: 600; color: #0f172a;">Mai Anh</td>
                <td style="font-size: 0.8rem; color: #64748b;">Super Admin</td>
                <td>
                  <div style="font-weight: 600; color: #0f172a;">Cấp mã đăng nhập</div>
                  <div style="font-size: 0.75rem; color: #64748b;">Đỗ Hoàng Nam · Vai trò Nhân viên.</div>
                </td>
                <td>
                  <div style="font-weight: 700; color: #2563eb;">AN-NV-005</div>
                  <div style="font-size: 0.72rem; color: #64748b;">Tài khoản</div>
                </td>
                <td><span class="badge badge-success">Thành công</span></td>
              </tr>

              <!-- Row 5 -->
              <tr>
                <td>
                  <div style="font-weight: 700; color: #0f172a;">08:35:44</div>
                  <div style="font-size: 0.72rem; color: #64748b;">27/10/2026</div>
                </td>
                <td style="font-weight: 600; color: #0f172a;">Nguyễn Minh Hà</td>
                <td style="font-size: 0.8rem; color: #64748b;">Quản lý</td>
                <td>
                  <div style="font-weight: 600; color: #0f172a;">Từ chối hàng về</div>
                  <div style="font-size: 0.75rem; color: #dc2626;">6 chai hở nắp, cần đổi lại lô. Không cộng 36 WA01.</div>
                </td>
                <td>
                  <div style="font-weight: 700; color: #2563eb;">PN-023</div>
                  <div style="font-size: 0.72rem; color: #64748b;">Nhập kho</div>
                </td>
                <td><span class="badge badge-danger">Đã từ chối</span></td>
              </tr>

              <!-- Row 6 -->
              <tr>
                <td>
                  <div style="font-weight: 700; color: #0f172a;">08:20:11</div>
                  <div style="font-size: 0.72rem; color: #64748b;">27/10/2026</div>
                </td>
                <td style="font-weight: 600; color: #0f172a;">Nguyễn Minh Hà</td>
                <td style="font-size: 0.8rem; color: #64748b;">Quản lý</td>
                <td>
                  <div style="font-weight: 600; color: #0f172a;">Duyệt hàng về</div>
                  <div style="font-size: 0.75rem; color: #64748b;">TE01 +10 hộp · Tồn kho từ 8 &rarr; 18.</div>
                </td>
                <td>
                  <div style="font-weight: 700; color: #2563eb;">PN-022</div>
                  <div style="font-size: 0.72rem; color: #64748b;">Nhập kho</div>
                </td>
                <td><span class="badge badge-success">Đã duyệt</span></td>
              </tr>

              <!-- Row 7 -->
              <tr>
                <td>
                  <div style="font-weight: 700; color: #0f172a;">17:15:32</div>
                  <div style="font-size: 0.72rem; color: #64748b;">26/10/2026</div>
                </td>
                <td style="font-weight: 600; color: #0f172a;">Nguyễn Minh Hà</td>
                <td style="font-size: 0.8rem; color: #64748b;">Quản lý</td>
                <td>
                  <div style="font-weight: 600; color: #0f172a;">Duyệt điều chỉnh kiểm kê</div>
                  <div style="font-size: 0.75rem; color: #64748b;">WA01: 50 &rarr; 48 · Giá trị vốn -10.000 đ.</div>
                </td>
                <td>
                  <div style="font-weight: 700; color: #2563eb;">KK-098</div>
                  <div style="font-size: 0.72rem; color: #64748b;">Kiểm kê</div>
                </td>
                <td><span class="badge badge-success">Đã duyệt</span></td>
              </tr>

              <!-- Row 8 -->
              <tr>
                <td>
                  <div style="font-weight: 700; color: #0f172a;">14:20:05</div>
                  <div style="font-size: 0.72rem; color: #64748b;">26/10/2026</div>
                </td>
                <td style="font-weight: 600; color: #0f172a;">Mai Anh</td>
                <td style="font-size: 0.8rem; color: #64748b;">Super Admin</td>
                <td>
                  <div style="font-weight: 600; color: #0f172a;">Thu hồi mã đăng nhập</div>
                  <div style="font-size: 0.75rem; color: #64748b;">Phạm Thu Trang · Kết thúc quyền truy cập.</div>
                </td>
                <td>
                  <div style="font-weight: 700; color: #2563eb;">AN-NV-004</div>
                  <div style="font-size: 0.72rem; color: #64748b;">Tài khoản</div>
                </td>
                <td><span class="badge badge-success">Thành công</span></td>
              </tr>

              <!-- Row 9 -->
              <tr>
                <td>
                  <div style="font-weight: 700; color: #0f172a;">14:10:28</div>
                  <div style="font-size: 0.72rem; color: #64748b;">26/10/2026</div>
                </td>
                <td style="font-weight: 600; color: #0f172a;">Mai Anh</td>
                <td style="font-size: 0.8rem; color: #64748b;">Super Admin</td>
                <td>
                  <div style="font-weight: 600; color: #0f172a;">Thay đổi vai trò</div>
                  <div style="font-size: 0.75rem; color: #64748b;">Phạm Thu Trang · Quản lý &rarr; Nhân viên.</div>
                </td>
                <td>
                  <div style="font-weight: 700; color: #2563eb;">AN-NV-004</div>
                  <div style="font-size: 0.72rem; color: #64748b;">Phân quyền</div>
                </td>
                <td><span class="badge badge-success">Thành công</span></td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- Pagination Bar -->
        <div style="display: flex; justify-content: space-between; align-items: center; padding: 14px 20px; border-top: 1px solid var(--border); font-size: 0.8rem; color: #64748b;">
          <div>Hiển thị 1–9 trong 9 hoạt động</div>
          <div style="display: flex; gap: 6px;">
            <button type="button" class="btn btn-outline" style="padding: 4px 8px; font-size: 0.75rem;">&lt;</button>
            <button type="button" class="btn btn-primary" style="padding: 4px 10px; font-size: 0.75rem;">1</button>
            <button type="button" class="btn btn-outline" style="padding: 4px 8px; font-size: 0.75rem;">&gt;</button>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>

<jsp:include page="/common/footer.jsp" />

