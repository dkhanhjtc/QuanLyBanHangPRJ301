<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="activeMenu" value="stocktakes" />
<c:set var="breadcrumbCurrent" value="Kiểm kê" />

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Đối soát kiểm kê #${stocktake != null ? stocktake.code : 'KK-101'} · Kiotflow</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>

<div class="app-container">
  <jsp:include page="/common/sidebar.jsp">
    <jsp:param name="activeMenu" value="stocktakes" />
  </jsp:include>

  <div class="main-content">
    <jsp:include page="/common/header.jsp">
      <jsp:param name="breadcrumbCurrent" value="Đối soát kiểm kê" />
    </jsp:include>

    <div class="page-body">
      <!-- Page Top Header -->
      <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 24px;">
        <div>
          <div style="display: flex; align-items: center; gap: 12px;">
            <h1 style="font-size: 1.85rem; font-weight: 800; color: #0f172a; letter-spacing: -0.02em;">
              Đối soát kiểm kê #${stocktake != null ? stocktake.code : 'KK-101'}
            </h1>
            <c:choose>
              <c:when test="${stocktake.status eq 'COMPLETED'}">
                <span class="badge badge-success" style="font-size: 0.8rem; padding: 4px 10px;">Đã đối soát</span>
              </c:when>
              <c:otherwise>
                <span class="badge badge-warning" style="font-size: 0.8rem; padding: 4px 10px;">Chờ đối soát</span>
              </c:otherwise>
            </c:choose>
          </div>
          <div style="font-size: 0.85rem; color: #64748b; margin-top: 4px;">
            ${stocktake != null ? stocktake.title : 'Khu vực kiểm kê'} · Người thực hiện: <strong>${stocktake != null ? stocktake.assignedTo : 'Nhân viên'}</strong>
          </div>
        </div>
        <a href="${pageContext.request.contextPath}/stocktakes" class="btn btn-outline">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="19" y1="12" x2="5" y2="12"/><polyline points="12 19 5 12 12 5"/></svg>
          <span>Danh sách kiểm kê</span>
        </a>
      </div>

      <!-- Info Meta Panel -->
      <div class="card" style="padding: 16px 24px; margin-bottom: 20px;">
        <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px;">
          <div>
            <div style="font-size: 0.72rem; color: #64748b; text-transform: uppercase; font-weight: 700; margin-bottom: 2px;">Thời điểm kiểm kê</div>
            <div style="font-size: 0.875rem; font-weight: 600; color: #0f172a;">${stocktake != null ? stocktake.formattedDate : '27/10/2026'}</div>
          </div>
          <div>
            <div style="font-size: 0.72rem; color: #64748b; text-transform: uppercase; font-weight: 700; margin-bottom: 2px;">Trạng thái phiếu</div>
            <div style="font-size: 0.875rem; font-weight: 600; color: #2563eb;">${stocktake != null ? stocktake.status : 'REVIEW'}</div>
          </div>
          <div>
            <div style="font-size: 0.72rem; color: #64748b; text-transform: uppercase; font-weight: 700; margin-bottom: 2px;">Nhân sự đối soát</div>
            <div style="font-size: 0.875rem; font-weight: 600; color: #0f172a;"><c:out value="${sessionScope.user != null ? sessionScope.user.fullName : 'Quản lý'}" /></div>
          </div>
        </div>
      </div>

      <!-- Inventory Reconciliation Warning Banner -->
      <c:if test="${stocktake.status ne 'COMPLETED'}">
        <div style="display: flex; align-items: flex-start; gap: 12px; background: #fffbeb; border: 1px solid #fde68a; border-radius: 12px; padding: 14px 18px; margin-bottom: 24px; font-size: 0.85rem; color: #b45309;">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="flex-shrink:0; margin-top:2px;"><path d="M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
          <div>
            Chưa cập nhật tồn kho. Khi nhấn Duyệt: số lượng tồn trong CSDL sẽ được cập nhật chính xác theo số thực đếm của nhân viên.
          </div>
        </div>
      </c:if>

      <!-- Discrepancy Table Card (Truy vấn từ CSDL, Không hardcode) -->
      <div class="card" style="margin-bottom: 24px;">
        <div class="card-header">
          <div>
            <div class="card-title">Số đếm &amp; chênh lệch thực tế</div>
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
                <th>GIÁ TRỊ VỐN CHÊNH</th>
                <th>GIẢI TRÌNH CỦA NHÂN VIÊN</th>
              </tr>
            </thead>
            <tbody>
              <c:choose>
                <c:when test="${not empty stocktake.items}">
                  <c:forEach items="${stocktake.items}" var="item">
                    <tr>
                      <td>
                        <div style="display: flex; align-items: center; gap: 12px;">
                          <img src="${pageContext.request.contextPath}/assets/images/${item.imageUrl != null ? item.imageUrl : (item.productId + '.svg')}" alt="${item.productName}" style="width: 40px; height: 40px; border-radius: 8px; object-fit: cover;">
                          <div>
                            <div style="font-weight: 700; color: #0f172a;">${item.productName}</div>
                            <div style="font-size: 0.72rem; color: #64748b;">${item.productId}</div>
                          </div>
                        </div>
                      </td>
                      <td style="font-weight: 600;">${item.systemStock}</td>
                      <td style="font-weight: 600;">${item.actualStock}</td>
                      <td>
                        <c:choose>
                          <c:when test="${item.variance < 0}">
                            <span class="badge badge-danger" style="font-size: 0.8rem; padding: 4px 8px;">${item.variance}</span>
                          </c:when>
                          <c:when test="${item.variance > 0}">
                            <span class="badge badge-primary" style="font-size: 0.8rem; padding: 4px 8px;">+${item.variance}</span>
                          </c:when>
                          <c:otherwise>
                            <span class="badge badge-gray" style="font-size: 0.8rem; padding: 4px 8px;">0</span>
                          </c:otherwise>
                        </c:choose>
                      </td>
                      <td style="font-weight: 600; color: ${item.variance < 0 ? '#ef4444' : (item.variance > 0 ? '#2563eb' : '#64748b')};">
                        <fmt:formatNumber value="${item.varianceCost}" pattern="#,###"/> VNĐ
                      </td>
                      <td>
                        <div style="font-size: 0.825rem; color: #0f172a;">
                          <c:out value="${item.note != null && !item.note.isEmpty() ? item.note : 'Khớp số lượng hệ thống.'}" />
                        </div>
                      </td>
                    </tr>
                  </c:forEach>
                </c:when>
                <c:otherwise>
                  <tr>
                    <td colspan="6" style="text-align: center; padding: 40px; color: #94a3b8;">
                      Chưa có mặt hàng nào được ghi nhận trong phiếu kiểm kê này.
                    </td>
                  </tr>
                </c:otherwise>
              </c:choose>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Reconciliation Action Block -->
      <div class="card" style="padding: 24px;">
        <c:choose>
          <c:when test="${stocktake.status eq 'COMPLETED'}">
            <div style="display: flex; align-items: center; justify-content: space-between;">
              <div style="color: #059669; font-weight: 600; font-size: 0.95rem;">
                ✓ Đợt kiểm kê này đã được phê duyệt và cân bằng tồn kho hoàn tất.
              </div>
              <a href="${pageContext.request.contextPath}/stocktakes" class="btn btn-outline">Quay lại danh sách</a>
            </div>
          </c:when>
          <c:otherwise>
            <form action="${pageContext.request.contextPath}/stocktakes" method="POST">
              <input type="hidden" name="action" value="approve">
              <input type="hidden" name="id" value="${stocktake.id}">
              <input type="hidden" name="code" value="${stocktake.code}">

              <div class="form-group" style="margin-bottom: 12px;">
                <label class="form-label" for="reconcileNotes">Ghi chú đối soát</label>
                <input type="text" id="reconcileNotes" name="notes" class="form-input" value="Đã kiểm tra lại thực tế và xác nhận điều chỉnh tồn kho.">
              </div>
              <div style="font-size: 0.75rem; color: #94a3b8; margin-bottom: 20px;">
                Hành động duyệt sẽ cập nhật số lượng tồn kho trong SQL Server và lưu vào Nhật ký hoạt động.
              </div>

              <div style="display: flex; justify-content: flex-end; gap: 12px;">
                <a href="${pageContext.request.contextPath}/stocktakes" class="btn btn-outline">
                  <span>Hủy bỏ</span>
                </a>
                <button type="submit" class="btn btn-primary" onclick="return confirm('Xác nhận DUYỆT và cập nhật cân bằng tồn kho thực tế cho phiếu ${stocktake.code}?')">
                  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                  <span>Duyệt điều chỉnh tồn kho</span>
                </button>
              </div>
            </form>
          </c:otherwise>
        </c:choose>
      </div>
    </div>
  </div>
</div>

<jsp:include page="/common/footer.jsp" />
</body>
</html>
