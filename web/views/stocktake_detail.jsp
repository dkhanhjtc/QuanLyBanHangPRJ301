<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="activeMenu" value="stocktakes" />
<c:set var="currentRole" value="manager" />
<c:set var="breadcrumbCurrent" value="Kiểm kê" />

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Đối soát kiểm kê #KK-101 · Kiotflow</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>

<div class="app-container">
  <jsp:include page="/common/sidebar.jsp" />

  <div class="main-content">
    <jsp:include page="/common/header.jsp" />

    <div class="page-body">
      <!-- Page Top Header -->
      <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 24px;">
        <div>
          <div style="display: flex; align-items: center; gap: 12px;">
            <h1 style="font-size: 1.85rem; font-weight: 800; color: #0f172a; letter-spacing: -0.02em;">Đối soát kiểm kê #KK-101</h1>
            <span class="badge badge-warning" style="font-size: 0.8rem; padding: 4px 10px;">Chờ đối soát</span>
          </div>
          <div style="font-size: 0.85rem; color: #64748b; margin-top: 4px;">
            Kệ cà phê &amp; trà · 3 sản phẩm · Nhân viên thực hiện: Trần Quốc Bảo
          </div>
        </div>
        <a href="${pageContext.request.contextPath}/views/stocktakes.jsp" class="btn btn-outline">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="19" y1="12" x2="5" y2="12"/><polyline points="12 19 5 12 12 5"/></svg>
          <span>Danh sách kiểm kê</span>
        </a>
      </div>

      <!-- Info Meta Panel -->
      <div class="card" style="padding: 16px 24px; margin-bottom: 20px;">
        <div style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px;">
          <div>
            <div style="font-size: 0.72rem; color: #64748b; text-transform: uppercase; font-weight: 700; margin-bottom: 2px;">Thời gian kiểm kê</div>
            <div style="font-size: 0.875rem; font-weight: 600; color: #0f172a;">27/10/2026 · 10:25–10:28</div>
          </div>
          <div>
            <div style="font-size: 0.72rem; color: #64748b; text-transform: uppercase; font-weight: 700; margin-bottom: 2px;">Thời điểm chốt tồn</div>
            <div style="font-size: 0.875rem; font-weight: 600; color: #0f172a;">27/10/2026 · 10:25</div>
          </div>
          <div>
            <div style="font-size: 0.72rem; color: #64748b; text-transform: uppercase; font-weight: 700; margin-bottom: 2px;">Người đối soát</div>
            <div style="font-size: 0.875rem; font-weight: 600; color: #0f172a;">Nguyễn Minh Hà</div>
          </div>
          <div>
            <div style="font-size: 0.72rem; color: #64748b; text-transform: uppercase; font-weight: 700; margin-bottom: 2px;">Phạm vi</div>
            <div style="font-size: 0.875rem; font-weight: 600; color: #0f172a;">CF01 · TE01 · CC01</div>
          </div>
        </div>
      </div>

      <!-- 3 Stat KPI Cards -->
      <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; margin-bottom: 20px;">
        <div class="card" style="padding: 20px 24px;">
          <div style="font-size: 0.75rem; color: #64748b; margin-bottom: 4px;">Sản phẩm đã kiểm</div>
          <div style="font-size: 1.85rem; font-weight: 800; color: #0f172a;">3 / 3</div>
        </div>
        <div class="card" style="padding: 20px 24px;">
          <div style="font-size: 0.75rem; color: #64748b; margin-bottom: 4px;">Có chênh lệch</div>
          <div style="font-size: 1.85rem; font-weight: 800; color: #ef4444;">2 sản phẩm</div>
        </div>
        <div class="card" style="padding: 20px 24px;">
          <div style="font-size: 0.75rem; color: #64748b; margin-bottom: 4px;">Điều chỉnh giá trị vốn</div>
          <div style="font-size: 1.85rem; font-weight: 800; color: #ef4444;">-15.000 <span style="text-decoration: underline;">đ</span></div>
        </div>
      </div>

      <!-- Inventory Reconciliation Warning Banner -->
      <div style="display: flex; align-items: flex-start; gap: 12px; background: #fffbeb; border: 1px solid #fde68a; border-radius: 12px; padding: 14px 18px; margin-bottom: 24px; font-size: 0.85rem; color: #b45309;">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="flex-shrink:0; margin-top:2px;"><path d="M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
        <div>
          Chưa cập nhật tồn kho. Khi duyệt: <strong>CF01 từ 24 &rarr; 23, CC01 từ 15 &rarr; 16; TE01 giữ nguyên 18</strong>. Giá trị vốn kho từ 7.492.000 đ &rarr; 7.477.000 đ.
        </div>
      </div>

      <!-- Discrepancy Table Card -->
      <div class="card" style="margin-bottom: 24px;">
        <div class="card-header">
          <div>
            <div class="card-title">Số đếm &amp; chênh lệch</div>
            <div class="card-subtitle">Chênh lệch = Thực đếm – Hệ thống</div>
          </div>
        </div>

        <div class="table-responsive">
          <table class="custom-table">
            <thead>
              <tr>
                <th>SẢN PHẨM</th>
                <th>HỆ THỐNG</th>
                <th>THỰC ĐẾM</th>
                <th>CHÊNH LỆCH</th>
                <th>GIÁ TRỊ VỐN</th>
                <th>GIẢI TRÌNH CỦA NHÂN VIÊN</th>
              </tr>
            </thead>
            <tbody>
              <!-- Row 1: Cà phê Arabica (Deficit -1) -->
              <tr>
                <td>
                  <div style="display: flex; align-items: center; gap: 12px;">
                    <img src="${pageContext.request.contextPath}/assets/images/CF01.svg" alt="CF01" style="width: 40px; height: 40px; border-radius: 8px; object-fit: cover;">
                    <div>
                      <div style="font-weight: 700; color: #0f172a;">Cà phê Arabica</div>
                      <div style="font-size: 0.72rem; color: #64748b;">CF01 · Gói 250g</div>
                    </div>
                  </div>
                </td>
                <td style="font-weight: 600;">24</td>
                <td style="font-weight: 600;">23</td>
                <td>
                  <span class="badge badge-danger" style="font-size: 0.8rem; padding: 4px 8px;">-1</span>
                </td>
                <td style="font-weight: 600; color: #ef4444;">-85.000 đ</td>
                <td>
                  <div style="font-size: 0.825rem; color: #0f172a;">1 gói rách bao bì, đã tách khỏi kệ bán.</div>
                  <a href="javascript:void(0)" onclick="alert('Đang tải ảnh minh chứng CF01-baobi.jpg')" style="font-size: 0.75rem; color: #2563eb; display: inline-flex; align-items: center; gap: 4px; margin-top: 2px;">
                    <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21.44 11.05l-9.19 9.19a6 6 0 01-8.49-8.49l9.19-9.19a4 4 0 015.66 5.66l-9.2 9.19a2 2 0 01-2.83-2.83l8.49-8.48"/></svg>
                    <span>Ảnh đính kèm · CF01-baobi.jpg</span>
                  </a>
                </td>
              </tr>

              <!-- Row 2: Trà sen (Match 0) -->
              <tr>
                <td>
                  <div style="display: flex; align-items: center; gap: 12px;">
                    <img src="${pageContext.request.contextPath}/assets/images/TE01.svg" alt="TE01" style="width: 40px; height: 40px; border-radius: 8px; object-fit: cover;">
                    <div>
                      <div style="font-weight: 700; color: #0f172a;">Trà sen</div>
                      <div style="font-size: 0.72rem; color: #64748b;">TE01 · Hộp 100g</div>
                    </div>
                  </div>
                </td>
                <td style="font-weight: 600;">18</td>
                <td style="font-weight: 600;">18</td>
                <td>
                  <span class="badge badge-gray" style="font-size: 0.8rem; padding: 4px 8px;">0</span>
                </td>
                <td style="font-weight: 600; color: #64748b;">0 đ</td>
                <td style="font-size: 0.825rem; color: #64748b;">Khớp số lượng hệ thống.</td>
              </tr>

              <!-- Row 3: Cacao nguyên chất (Surplus +1) -->
              <tr>
                <td>
                  <div style="display: flex; align-items: center; gap: 12px;">
                    <img src="${pageContext.request.contextPath}/assets/images/CC01.svg" alt="CC01" style="width: 40px; height: 40px; border-radius: 8px; object-fit: cover;">
                    <div>
                      <div style="font-weight: 700; color: #0f172a;">Cacao nguyên chất</div>
                      <div style="font-size: 0.72rem; color: #64748b;">CC01 · Gói 200g</div>
                    </div>
                  </div>
                </td>
                <td style="font-weight: 600;">15</td>
                <td style="font-weight: 600;">16</td>
                <td>
                  <span class="badge badge-primary" style="font-size: 0.8rem; padding: 4px 8px;">+1</span>
                </td>
                <td style="font-weight: 600; color: #2563eb;">+70.000 đ</td>
                <td style="font-size: 0.825rem; color: #0f172a;">Tìm thấy 1 gói tại kệ dự phòng, chưa ghi nhận tồn.</td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- Table Summary Row -->
        <div style="display: flex; justify-content: space-between; align-items: center; padding: 16px 24px; border-top: 1px solid var(--border); background: #fafbfc; font-size: 0.875rem;">
          <div style="font-weight: 600; color: #0f172a;">
            Tổng số lượng: Hệ thống 57 · Thực đếm 57
          </div>
          <div style="font-weight: 700; color: #ef4444; font-size: 0.95rem;">
            Giá trị điều chỉnh: -15.000 đ
          </div>
        </div>
      </div>

      <!-- Reconciliation Action Block -->
      <div class="card" style="padding: 24px;">
        <div class="form-group" style="margin-bottom: 12px;">
          <label class="form-label" for="reconcileNotes">Ghi chú đối soát</label>
          <input type="text" id="reconcileNotes" class="form-input" value="Đã đối chiếu ảnh và kiểm tra lại kệ dự phòng.">
        </div>
        <div style="font-size: 0.75rem; color: #94a3b8; margin-bottom: 20px;">
          Từ chối phải kèm lý do để nhân viên kiểm đếm lại. Mọi quyết định được lưu nhật ký.
        </div>

        <div style="display: flex; justify-content: flex-end; gap: 12px;">
          <button type="button" class="btn btn-outline" style="color: #dc2626;" onclick="if(confirm('Yêu cầu nhân viên kiểm đếm lại phiếu KK-101?')) alert('Đã gửi yêu cầu kiểm đếm lại!');">
            <span>Từ chối &amp; yêu cầu kiểm lại</span>
          </button>
          <button type="button" class="btn btn-primary" onclick="if(confirm('Xác nhận DUYỆT điều chỉnh tồn kho cho phiếu KK-101?')) { alert('Đã duyệt điều chỉnh tồn kho thành công! Nhật ký hệ thống đã được ghi lại.'); location.href='${pageContext.request.contextPath}/views/stocktakes.jsp'; }">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
            <span>Duyệt điều chỉnh tồn kho</span>
          </button>
        </div>
      </div>
    </div>
  </div>
</div>

<jsp:include page="/common/footer.jsp" />

