<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="activeMenu" value="products" />
<c:set var="currentRole" value="manager" />
<c:set var="breadcrumbCurrent" value="Hàng hóa" />

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Quản lý hàng hóa · Kiotflow</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
  <script>
    window.CONTEXT_PATH = "${pageContext.request.contextPath}";
  </script>
  <style>
    .sub-nav-tabs {
      display: flex;
      gap: 28px;
      border-bottom: 1px solid var(--border);
      margin-bottom: 24px;
    }
    .sub-nav-tab {
      padding: 10px 4px 14px;
      font-size: 0.95rem;
      font-weight: 600;
      color: var(--text-muted);
      border-bottom: 2px solid transparent;
      cursor: pointer;
      display: flex;
      align-items: center;
      gap: 6px;
      background: none;
      border-top: none;
      border-left: none;
      border-right: none;
      transition: all 0.15s ease;
    }
    .sub-nav-tab:hover {
      color: var(--text-main);
    }
    .sub-nav-tab.active {
      color: var(--primary);
      border-bottom-color: var(--primary);
    }
  </style>
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
          <h1 style="font-size: 1.85rem; font-weight: 800; color: #0f172a; letter-spacing: -0.02em;">Quản lý hàng hóa</h1>
          <div style="font-size: 0.85rem; color: #64748b; margin-top: 4px;">
            8 sản phẩm · 163 đơn vị tồn kho · Giá trị vốn 7.492.000 đ
          </div>
        </div>
        <div style="display: flex; gap: 10px;">
          <button type="button" class="btn btn-outline" onclick="alert('Đang trích xuất danh sách hàng hóa ra file Excel...')">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4M7 10l5 5 5-5M12 15V3"/></svg>
            <span>Xuất danh sách</span>
          </button>
          <button type="button" class="btn btn-primary" onclick="openNewProductModal()">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
            <span>Thêm hàng hóa</span>
          </button>
        </div>
      </div>

      <!-- Tab Buttons Navigation -->
      <div class="sub-nav-tabs">
        <button type="button" class="sub-nav-tab active" id="tabBtnProducts" onclick="switchProductTab('products')">
          <span>Hàng hóa</span>
        </button>
        <button type="button" class="sub-nav-tab" id="tabBtnApprovals" onclick="switchProductTab('approvals')">
          <span>Duyệt hàng về</span>
          <span class="badge badge-primary" style="font-size: 0.7rem; padding: 2px 7px;">3</span>
        </button>
      </div>

      <!-- ====================================================================
           TAB 1: PRODUCTS INVENTORY TABLE VIEW
           ==================================================================== -->
      <div id="productsTableView">
        <div class="card">
          <!-- Filter Bar -->
          <div style="padding: 18px 20px; display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--border); flex-wrap: wrap; gap: 12px;">
            <div style="display: flex; gap: 12px; align-items: center; flex: 1; max-width: 650px;">
              <div class="input-icon-wrapper" style="flex: 1;">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                <input type="text" class="form-input" placeholder="Tìm tên sản phẩm hoặc SKU...">
              </div>
              <button type="button" class="btn btn-outline" style="font-size: 0.85rem;">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="4" y1="21" x2="4" y2="14"/><line x1="4" y1="10" x2="4" y2="3"/><line x1="12" y1="21" x2="12" y2="12"/><line x1="12" y1="8" x2="12" y2="3"/><line x1="20" y1="21" x2="20" y2="16"/><line x1="20" y1="12" x2="20" y2="3"/></svg>
                <span>Tất cả nhóm hàng</span>
              </button>
              <select class="form-select" style="width: auto; font-size: 0.85rem;">
                <option value="all">Trạng thái: Tất cả</option>
                <option value="low">Chạm đáy</option>
                <option value="sufficient">Đủ hàng</option>
              </select>
            </div>
            <div>
              <span class="badge" style="background: #fef2f2; color: #ef4444; font-size: 0.8rem; padding: 6px 12px; font-weight: 700;">
                2 hàng chạm đáy
              </span>
            </div>
          </div>

          <!-- Inventory Table -->
          <div class="table-responsive">
            <table class="custom-table">
              <thead>
                <tr>
                  <th style="width: 50px;">Ảnh</th>
                  <th>SKU</th>
                  <th>Tên sản phẩm</th>
                  <th>Giá nhập</th>
                  <th>Giá bán</th>
                  <th>Tồn kho</th>
                  <th>Tối thiểu</th>
                  <th>Trạng thái</th>
                  <th style="text-align: right;">Thao tác</th>
                </tr>
              </thead>
              <tbody>
                <c:choose>
                  <c:when test="${not empty products}">
                    <c:forEach items="${products}" var="p">
                      <tr>
                        <td>
                          <img src="${pageContext.request.contextPath}/assets/images/${p.image}" alt="${p.name}" style="width: 36px; height: 36px; border-radius: 6px; object-fit: cover;">
                        </td>
                        <td style="font-weight: 600; color: #0f172a;">${p.sku}</td>
                        <td>
                          <div style="font-weight: 600; color: #0f172a;">${p.name}</div>
                          <div style="font-size: 0.72rem; color: #64748b;">${p.spec} · ${p.category}</div>
                        </td>
                        <td><fmt:formatNumber value="${p.costPrice}" pattern="#,###"/> đ</td>
                        <td style="font-weight: 600;"><fmt:formatNumber value="${p.price}" pattern="#,###"/> đ</td>
                        
                        <!-- Reactive Stock Quantity highlighting -->
                        <td style="font-weight: 700; ${p.stockQuantity <= p.minStock ? 'color: #ef4444;' : 'color: #0f172a;'}">
                          ${p.stockQuantity}
                        </td>
                        <td>${p.minStock}</td>
                        <td>
                          <c:choose>
                            <c:when test="${p.stockQuantity <= p.minStock}">
                              <span class="badge badge-danger">Chạm đáy</span>
                            </c:when>
                            <c:otherwise>
                              <span class="badge badge-success">Đủ hàng</span>
                            </c:otherwise>
                          </c:choose>
                        </td>
                        <td style="text-align: right;">
                          <button type="button" class="btn btn-outline" style="padding: 4px 8px;" onclick="openProductEditModal('${p.sku}', '${p.name}', '${p.category}', '${p.unit}', '${p.costPrice}', '${p.price}', '${p.stockQuantity}', '${p.minStock}', '${p.image}')" title="Chỉnh sửa">
                            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 013 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>
                          </button>
                        </td>
                      </tr>
                    </c:forEach>
                  </c:when>

                  <c:otherwise>
                    <!-- Row 1: Cà phê Arabica -->
                    <tr>
                      <td><img src="${pageContext.request.contextPath}/assets/images/CF01.svg" alt="CF01" style="width: 36px; height: 36px; border-radius: 6px; object-fit: cover;"></td>
                      <td style="font-weight: 600; color: #0f172a;">CF01</td>
                      <td>
                        <div style="font-weight: 600; color: #0f172a;">Cà phê Arabica</div>
                        <div style="font-size: 0.72rem; color: #64748b;">Gói 250g · Cà phê &amp; trà</div>
                      </td>
                      <td>85.000 đ</td>
                      <td style="font-weight: 600;">125.000 đ</td>
                      <td style="font-weight: 700; color: #0f172a;">24</td>
                      <td>10</td>
                      <td><span class="badge badge-success">Đủ hàng</span></td>
                      <td style="text-align: right;">
                        <button type="button" class="btn btn-outline" style="padding: 4px 8px;" onclick="openProductEditModal('CF01', 'Cà phê Arabica', 'coffee', 'Gói 250g', '85000', '125000', '24', '10', 'CF01.svg')">
                          <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 013 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>
                        </button>
                      </td>
                    </tr>

                    <!-- Row 2: Trà sen -->
                    <tr>
                      <td><img src="${pageContext.request.contextPath}/assets/images/TE01.svg" alt="TE01" style="width: 36px; height: 36px; border-radius: 6px; object-fit: cover;"></td>
                      <td style="font-weight: 600; color: #0f172a;">TE01</td>
                      <td>
                        <div style="font-weight: 600; color: #0f172a;">Trà sen</div>
                        <div style="font-size: 0.72rem; color: #64748b;">Hộp 100g · Cà phê &amp; trà</div>
                      </td>
                      <td>60.000 đ</td>
                      <td style="font-weight: 600;">89.000 đ</td>
                      <td style="font-weight: 700; color: #0f172a;">18</td>
                      <td>8</td>
                      <td><span class="badge badge-success">Đủ hàng</span></td>
                      <td style="text-align: right;">
                        <button type="button" class="btn btn-outline" style="padding: 4px 8px;" onclick="openProductEditModal('TE01', 'Trà sen', 'coffee', 'Hộp 100g', '60000', '89000', '18', '8', 'TE01.svg')">
                          <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 013 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>
                        </button>
                      </td>
                    </tr>

                    <!-- Row 3: Sữa yến mạch (Chạm đáy) -->
                    <tr>
                      <td><img src="${pageContext.request.contextPath}/assets/images/MK01.svg" alt="MK01" style="width: 36px; height: 36px; border-radius: 6px; object-fit: cover;"></td>
                      <td style="font-weight: 600; color: #0f172a;">MK01</td>
                      <td>
                        <div style="font-weight: 600; color: #0f172a;">Sữa yến mạch</div>
                        <div style="font-size: 0.72rem; color: #64748b;">Hộp 1L · Đồ uống</div>
                      </td>
                      <td>42.000 đ</td>
                      <td style="font-weight: 600;">59.000 đ</td>
                      <td style="font-weight: 700; color: #ef4444;">8</td>
                      <td>8</td>
                      <td><span class="badge badge-danger">Chạm đáy</span></td>
                      <td style="text-align: right;">
                        <button type="button" class="btn btn-outline" style="padding: 4px 8px;" onclick="openProductEditModal('MK01', 'Sữa yến mạch', 'drinks', 'Hộp 1L', '42000', '59000', '8', '8', 'MK01.svg')">
                          <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 013 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>
                        </button>
                      </td>
                    </tr>

                    <!-- Row 4: Mật ong hoa nhãn -->
                    <tr>
                      <td><img src="${pageContext.request.contextPath}/assets/images/HN01.svg" alt="HN01" style="width: 36px; height: 36px; border-radius: 6px; object-fit: cover;"></td>
                      <td style="font-weight: 600; color: #0f172a;">HN01</td>
                      <td>
                        <div style="font-weight: 600; color: #0f172a;">Mật ong hoa nhãn</div>
                        <div style="font-size: 0.72rem; color: #64748b;">Chai 500ml · Thực phẩm</div>
                      </td>
                      <td>95.000 đ</td>
                      <td style="font-weight: 600;">145.000 đ</td>
                      <td style="font-weight: 700; color: #0f172a;">12</td>
                      <td>5</td>
                      <td><span class="badge badge-success">Đủ hàng</span></td>
                      <td style="text-align: right;">
                        <button type="button" class="btn btn-outline" style="padding: 4px 8px;" onclick="openProductEditModal('HN01', 'Mật ong hoa nhãn', 'food', 'Chai 500ml', '95000', '145000', '12', '5', 'HN01.svg')">
                          <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 013 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>
                        </button>
                      </td>
                    </tr>

                    <!-- Row 5: Granola hạt (Chạm đáy) -->
                    <tr>
                      <td><img src="${pageContext.request.contextPath}/assets/images/GR01.svg" alt="GR01" style="width: 36px; height: 36px; border-radius: 6px; object-fit: cover;"></td>
                      <td style="font-weight: 600; color: #0f172a;">GR01</td>
                      <td>
                        <div style="font-weight: 600; color: #0f172a;">Granola hạt</div>
                        <div style="font-size: 0.72rem; color: #64748b;">Gói 300g · Thực phẩm</div>
                      </td>
                      <td>65.000 đ</td>
                      <td style="font-weight: 600;">99.000 đ</td>
                      <td style="font-weight: 700; color: #ef4444;">6</td>
                      <td>6</td>
                      <td><span class="badge badge-danger">Chạm đáy</span></td>
                      <td style="text-align: right;">
                        <button type="button" class="btn btn-outline" style="padding: 4px 8px;" onclick="openProductEditModal('GR01', 'Granola hạt', 'food', 'Gói 300g', '65000', '99000', '6', '6', 'GR01.svg')">
                          <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 013 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>
                        </button>
                      </td>
                    </tr>

                    <!-- Row 6: Bánh quy bơ -->
                    <tr>
                      <td><img src="${pageContext.request.contextPath}/assets/images/CK01.svg" alt="CK01" style="width: 36px; height: 36px; border-radius: 6px; object-fit: cover;"></td>
                      <td style="font-weight: 600; color: #0f172a;">CK01</td>
                      <td>
                        <div style="font-weight: 600; color: #0f172a;">Bánh quy bơ</div>
                        <div style="font-size: 0.72rem; color: #64748b;">Hộp 200g · Thực phẩm</div>
                      </td>
                      <td>38.000 đ</td>
                      <td style="font-weight: 600;">65.000 đ</td>
                      <td style="font-weight: 700; color: #0f172a;">32</td>
                      <td>10</td>
                      <td><span class="badge badge-success">Đủ hàng</span></td>
                      <td style="text-align: right;">
                        <button type="button" class="btn btn-outline" style="padding: 4px 8px;" onclick="openProductEditModal('CK01', 'Bánh quy bơ', 'food', 'Hộp 200g', '38000', '65000', '32', '10', 'CK01.svg')">
                          <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 013 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>
                        </button>
                      </td>
                    </tr>

                    <!-- Row 7: Nước khoáng -->
                    <tr>
                      <td><img src="${pageContext.request.contextPath}/assets/images/WA01.svg" alt="WA01" style="width: 36px; height: 36px; border-radius: 6px; object-fit: cover;"></td>
                      <td style="font-weight: 600; color: #0f172a;">WA01</td>
                      <td>
                        <div style="font-weight: 600; color: #0f172a;">Nước khoáng</div>
                        <div style="font-size: 0.72rem; color: #64748b;">Chai 500ml · Đồ uống</div>
                      </td>
                      <td>5.000 đ</td>
                      <td style="font-weight: 600;">10.000 đ</td>
                      <td style="font-weight: 700; color: #0f172a;">48</td>
                      <td>12</td>
                      <td><span class="badge badge-success">Đủ hàng</span></td>
                      <td style="text-align: right;">
                        <button type="button" class="btn btn-outline" style="padding: 4px 8px;" onclick="openProductEditModal('WA01', 'Nước khoáng', 'drinks', 'Chai 500ml', '5000', '10000', '48', '12', 'WA01.svg')">
                          <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 013 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>
                        </button>
                      </td>
                    </tr>

                    <!-- Row 8: Cacao nguyên chất -->
                    <tr>
                      <td><img src="${pageContext.request.contextPath}/assets/images/CC01.svg" alt="CC01" style="width: 36px; height: 36px; border-radius: 6px; object-fit: cover;"></td>
                      <td style="font-weight: 600; color: #0f172a;">CC01</td>
                      <td>
                        <div style="font-weight: 600; color: #0f172a;">Cacao nguyên chất</div>
                        <div style="font-size: 0.72rem; color: #64748b;">Gói 200g · Cà phê &amp; trà</div>
                      </td>
                      <td>70.000 đ</td>
                      <td style="font-weight: 600;">105.000 đ</td>
                      <td style="font-weight: 700; color: #0f172a;">15</td>
                      <td>5</td>
                      <td><span class="badge badge-success">Đủ hàng</span></td>
                      <td style="text-align: right;">
                        <button type="button" class="btn btn-outline" style="padding: 4px 8px;" onclick="openProductEditModal('CC01', 'Cacao nguyên chất', 'coffee', 'Gói 200g', '70000', '105000', '15', '5', 'CC01.svg')">
                          <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 013 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>
                        </button>
                      </td>
                    </tr>
                  </c:otherwise>
                </c:choose>
              </tbody>
            </table>
          </div>

          <!-- Pagination Bar -->
          <div style="display: flex; justify-content: space-between; align-items: center; padding: 16px 20px; border-top: 1px solid var(--border); font-size: 0.8rem; color: #64748b;">
            <div>Hiển thị 1–8 trong 8 sản phẩm</div>
            <div style="display: flex; gap: 6px;">
              <button type="button" class="btn btn-outline" style="padding: 4px 8px; font-size: 0.75rem;">&lt;</button>
              <button type="button" class="btn btn-primary" style="padding: 4px 10px; font-size: 0.75rem;">1</button>
              <button type="button" class="btn btn-outline" style="padding: 4px 8px; font-size: 0.75rem;">&gt;</button>
            </div>
          </div>
        </div>

        <!-- Footnote Info -->
        <div style="display: flex; align-items: center; gap: 8px; font-size: 0.8rem; color: #64748b; margin-top: 16px;">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
          <span>Nhãn “Chạm đáy” xuất hiện khi Tồn kho &le; Mức tồn tối thiểu. Chỉ hàng về đã duyệt mới được cộng vào tồn.</span>
        </div>
      </div>

      <!-- ====================================================================
           TAB 2: STOCK INFLOW APPROVALS VIEW (DUYỆT HÀNG VỀ)
           ==================================================================== -->
      <div id="approvalsTableView" style="display: none;">
        <!-- 3 Stat Cards -->
        <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; margin-bottom: 20px;">
          <div class="card" style="padding: 20px; display: flex; align-items: center; gap: 16px;">
            <div style="width: 44px; height: 44px; border-radius: 10px; background: #eff6ff; color: #2563eb; display: flex; align-items: center; justify-content: center;">
              <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/></svg>
            </div>
            <div>
              <div style="font-size: 0.75rem; color: #64748b;">Phiếu chờ duyệt</div>
              <div style="font-size: 1.5rem; font-weight: 800; color: #0f172a;">03 phiếu</div>
            </div>
          </div>

          <div class="card" style="padding: 20px; display: flex; align-items: center; gap: 16px;">
            <div style="width: 44px; height: 44px; border-radius: 10px; background: #eff6ff; color: #2563eb; display: flex; align-items: center; justify-content: center;">
              <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="7" width="20" height="14" rx="2"/><path d="M16 21V5a2 2 0 00-2-2h-4a2 2 0 00-2 2v16"/></svg>
            </div>
            <div>
              <div style="font-size: 0.75rem; color: #64748b;">Số lượng chờ nhập</div>
              <div style="font-size: 1.5rem; font-weight: 800; color: #0f172a;">56 đơn vị</div>
            </div>
          </div>

          <div class="card" style="padding: 20px; display: flex; align-items: center; gap: 16px;">
            <div style="width: 44px; height: 44px; border-radius: 10px; background: #eff6ff; color: #2563eb; display: flex; align-items: center; justify-content: center;">
              <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="1" y="4" width="22" height="16" rx="2"/><line x1="1" y1="10" x2="23" y2="10"/></svg>
            </div>
            <div>
              <div style="font-size: 0.75rem; color: #64748b;">Tổng giá trị nhập đề nghị</div>
              <div style="font-size: 1.5rem; font-weight: 800; color: #0f172a;">3.328.000 <span style="text-decoration: underline;">đ</span></div>
            </div>
          </div>
        </div>

        <!-- Alert Notice -->
        <div style="display: flex; align-items: center; gap: 10px; background: #eff6ff; border: 1px solid #bfdbfe; border-radius: 10px; padding: 12px 18px; margin-bottom: 20px; font-size: 0.825rem; color: #1e40af;">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 16V8a2 2 0 00-1-1.73l-7-4a2 2 0 00-2 0l-7 4A2 2 0 003 8v8a2 2 0 001 1.73l7 4a2 2 0 002 0l7-4A2 2 0 0021 16z"/></svg>
          <span>Duyệt phiếu sẽ cộng số lượng thực nhận vào tồn kho ngay lập tức. Từ chối không thay đổi tồn kho và bắt buộc có lý do.</span>
        </div>

        <!-- Inflow Table Card -->
        <div class="card" style="margin-bottom: 24px;">
          <div style="padding: 16px 20px; display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--border);">
            <div style="display: flex; gap: 12px; align-items: center; flex: 1; max-width: 650px;">
              <div class="input-icon-wrapper" style="flex: 1;">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                <input type="text" class="form-input" placeholder="Tìm mã phiếu, sản phẩm, nhà cung cấp...">
              </div>
              <select class="form-select" style="width: auto;">
                <option value="pending">Chờ duyệt · 3</option>
              </select>
              <button type="button" class="btn btn-outline" style="font-size: 0.85rem;">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/></svg>
                <span>27/10/2026</span>
              </button>
            </div>
            <div style="font-size: 0.8rem; color: #64748b; font-weight: 500;">
              Chỉ Quản lý được duyệt
            </div>
          </div>

          <div class="table-responsive">
            <table class="custom-table">
              <thead>
                <tr>
                  <th>Phiếu nhập</th>
                  <th>Nhà cung cấp</th>
                  <th>Hàng thực nhận</th>
                  <th>Số lượng</th>
                  <th>Người gửi</th>
                  <th>Tồn sau duyệt</th>
                  <th style="text-align: right;">Quyết định</th>
                </tr>
              </thead>
              <tbody>
                <!-- Row PN-026 -->
                <tr id="ticket-row-PN-026">
                  <td>
                    <div style="font-weight: 700; color: #2563eb;">PN-026</div>
                    <div style="font-size: 0.72rem; color: #64748b;">09:40 · 27/10</div>
                    <span class="badge badge-warning" style="margin-top: 4px; font-size: 0.7rem;">Chờ duyệt</span>
                  </td>
                  <td>
                    <div style="font-weight: 600; color: #0f172a;">Oats Việt</div>
                    <div style="font-size: 0.72rem; color: #64748b;">NCC-003</div>
                  </td>
                  <td>
                    <div style="font-weight: 600; color: #0f172a;">Sữa yến mạch</div>
                    <div style="font-size: 0.72rem; color: #64748b;">MK01 · 1.008.000 đ</div>
                  </td>
                  <td style="font-weight: 700; color: #0f172a;">+24</td>
                  <td style="color: #0f172a;">Lê Lan Anh</td>
                  <td>
                    <div style="font-weight: 700; color: #2563eb;">8 &rarr; 32</div>
                    <div style="font-size: 0.7rem; color: #94a3b8;">Chưa cộng kho</div>
                  </td>
                  <td style="text-align: right;">
                    <button type="button" class="btn btn-primary" style="padding: 6px 14px; font-size: 0.8rem;" onclick="approveInflow('PN-026', 'Sữa yến mạch', 24)">
                      <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                      <span>Duyệt</span>
                    </button>
                    <button type="button" class="btn btn-danger-outline" style="padding: 6px 14px; font-size: 0.8rem;" onclick="openRejectModal('PN-026', 'Sữa yến mạch', 'Oats Việt', 'Lê Lan Anh', 24, 8)">
                      <span>Từ chối</span>
                    </button>
                  </td>
                </tr>

                <!-- Row PN-025 -->
                <tr id="ticket-row-PN-025">
                  <td>
                    <div style="font-weight: 700; color: #2563eb;">PN-025</div>
                    <div style="font-size: 0.72rem; color: #64748b;">09:10 · 27/10</div>
                    <span class="badge badge-warning" style="margin-top: 4px; font-size: 0.7rem;">Chờ duyệt</span>
                  </td>
                  <td>
                    <div style="font-weight: 600; color: #0f172a;">Hạt Lành</div>
                    <div style="font-size: 0.72rem; color: #64748b;">NCC-005</div>
                  </td>
                  <td>
                    <div style="font-weight: 600; color: #0f172a;">Granola hạt</div>
                    <div style="font-size: 0.72rem; color: #64748b;">GR01 · 1.300.000 đ</div>
                  </td>
                  <td style="font-weight: 700; color: #0f172a;">+20</td>
                  <td style="color: #0f172a;">Trần Quốc Bảo</td>
                  <td>
                    <div style="font-weight: 700; color: #2563eb;">6 &rarr; 26</div>
                    <div style="font-size: 0.7rem; color: #94a3b8;">Chưa cộng kho</div>
                  </td>
                  <td style="text-align: right;">
                    <button type="button" class="btn btn-primary" style="padding: 6px 14px; font-size: 0.8rem;" onclick="approveInflow('PN-025', 'Granola hạt', 20)">
                      <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                      <span>Duyệt</span>
                    </button>
                    <button type="button" class="btn btn-danger-outline" style="padding: 6px 14px; font-size: 0.8rem;" onclick="openRejectModal('PN-025', 'Granola hạt', 'Hạt Lành', 'Trần Quốc Bảo', 20, 6)">
                      <span>Từ chối</span>
                    </button>
                  </td>
                </tr>

                <!-- Row PN-024 -->
                <tr id="ticket-row-PN-024">
                  <td>
                    <div style="font-weight: 700; color: #2563eb;">PN-024</div>
                    <div style="font-size: 0.72rem; color: #64748b;">08:45 · 27/10</div>
                    <span class="badge badge-warning" style="margin-top: 4px; font-size: 0.7rem;">Chờ duyệt</span>
                  </td>
                  <td>
                    <div style="font-weight: 600; color: #0f172a;">Cao Nguyên</div>
                    <div style="font-size: 0.72rem; color: #64748b;">NCC-001</div>
                  </td>
                  <td>
                    <div style="font-weight: 600; color: #0f172a;">Cà phê Arabica</div>
                    <div style="font-size: 0.72rem; color: #64748b;">CF01 · 1.020.000 đ</div>
                  </td>
                  <td style="font-weight: 700; color: #0f172a;">+12</td>
                  <td style="color: #0f172a;">Lê Lan Anh</td>
                  <td>
                    <div style="font-weight: 700; color: #2563eb;">24 &rarr; 36</div>
                    <div style="font-size: 0.7rem; color: #94a3b8;">Chưa cộng kho</div>
                  </td>
                  <td style="text-align: right;">
                    <button type="button" class="btn btn-primary" style="padding: 6px 14px; font-size: 0.8rem;" onclick="approveInflow('PN-024', 'Cà phê Arabica', 12)">
                      <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                      <span>Duyệt</span>
                    </button>
                    <button type="button" class="btn btn-danger-outline" style="padding: 6px 14px; font-size: 0.8rem;" onclick="openRejectModal('PN-024', 'Cà phê Arabica', 'Cao Nguyên', 'Lê Lan Anh', 12, 24)">
                      <span>Từ chối</span>
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>

        <!-- History Bottom Card (Vừa xử lý hôm nay) -->
        <div class="card">
          <div class="card-header">
            <div class="card-title">Vừa xử lý hôm nay</div>
            <a href="javascript:void(0)" onclick="alert('Đang mở toàn bộ nhật ký duyệt kho...')" style="font-size: 0.85rem; font-weight: 600; display: inline-flex; align-items: center; gap: 4px;">
              <span>Xem lịch sử</span>
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg>
            </a>
          </div>
          <div class="card-body" style="display: flex; flex-direction: column; gap: 14px;">
            <!-- Processed Item 1 -->
            <div style="display: flex; justify-content: space-between; align-items: center; padding-bottom: 12px; border-bottom: 1px solid #f1f5f9;">
              <div>
                <div style="font-size: 0.875rem; font-weight: 600; color: #0f172a;">PN-022 · Trà sen · +10 hộp · Tồn 8 &rarr; 18</div>
                <div style="font-size: 0.75rem; color: #64748b; margin-top: 2px;">Minh Hà · 08:20</div>
              </div>
              <span class="badge badge-success">Đã duyệt</span>
            </div>

            <!-- Processed Item 2 (Rejected) -->
            <div style="display: flex; justify-content: space-between; align-items: flex-start;">
              <div>
                <div style="font-size: 0.875rem; font-weight: 600; color: #0f172a;">PN-023 · Nước khoáng · 36 chai · Không cộng kho</div>
                <div style="font-size: 0.75rem; color: #dc2626; margin-top: 3px;">
                  Lý do: 6 chai bị hở nắp, cần đổi lại lô hàng.
                </div>
                <div style="font-size: 0.75rem; color: #64748b; margin-top: 2px;">Minh Hà · 08:35</div>
              </div>
              <span class="badge badge-danger">Đã từ chối</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>

<!-- ==========================================================================
     MODAL: CHỈNH SỬA & THÊM HÀNG HÓA
     ========================================================================== -->
<div class="modal-backdrop" id="productEditModal">
  <div class="modal-window" style="max-width: 650px;">
    <div class="modal-header">
      <div>
        <h3 class="modal-title">Chỉnh sửa hàng hóa</h3>
        <div class="modal-sub" id="modalProductSubtitle">MK01 · Sữa yến mạch · Cập nhật thông tin trong danh mục</div>
      </div>
      <button type="button" class="modal-close" onclick="closeModal('productEditModal')">&times;</button>
    </div>

    <form action="${pageContext.request.contextPath}/products" method="POST" enctype="multipart/form-data" onsubmit="event.preventDefault(); alert('Lưu thông tin sản phẩm thành công!'); closeModal('productEditModal');">
      <div class="modal-body">
        <!-- Image Preview & Upload Dropzone -->
        <div class="form-group">
          <label class="form-label">Ảnh sản phẩm</label>
          <div style="display: flex; gap: 16px; align-items: center;">
            <div style="width: 100px; height: 100px; border-radius: 12px; border: 1px solid #e2e8f0; overflow: hidden; background: #f8fafc; flex-shrink: 0; display: flex; align-items: center; justify-content: center;">
              <img id="productImagePreview" src="${pageContext.request.contextPath}/assets/images/MK01.svg" alt="Preview" style="width: 100%; height: 100%; object-fit: cover;">
            </div>
            
            <div class="upload-dropzone" style="flex: 1;" onclick="document.getElementById('productImageInput').click()">
              <input type="file" id="productImageInput" name="productImage" accept="image/*" style="display: none;" onchange="previewSelectedImage(this)">
              <div style="display: flex; align-items: center; justify-content: center; gap: 8px;">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#2563eb" stroke-width="2"><path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4M17 8l-5-5-5 5M12 3v12"/></svg>
                <span class="upload-prompt">Tải ảnh lên hoặc kéo thả vào đây</span>
              </div>
              <div class="upload-hint">JPG, PNG · Tối đa 5 MB · Tỷ lệ khuyến nghị 1:1</div>
            </div>
          </div>
        </div>

        <!-- Form Rows Grid -->
        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 14px;">
          <div class="form-group">
            <label class="form-label">Mã SKU *</label>
            <input type="text" id="modalProductSku" class="form-input" required>
          </div>
          <div class="form-group">
            <label class="form-label">Tên sản phẩm *</label>
            <input type="text" id="modalProductName" class="form-input" required>
          </div>
        </div>

        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 14px;">
          <div class="form-group">
            <label class="form-label">Nhóm hàng</label>
            <select id="modalProductCategory" class="form-select">
              <option value="coffee">Cà phê &amp; trà</option>
              <option value="drinks">Đồ uống</option>
              <option value="food">Thực phẩm</option>
            </select>
          </div>
          <div class="form-group">
            <label class="form-label">Đơn vị tính</label>
            <input type="text" id="modalProductUnit" class="form-input" placeholder="Ví dụ: Hộp 1L">
          </div>
        </div>

        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 14px;">
          <div class="form-group">
            <label class="form-label">Giá nhập (đ) *</label>
            <input type="number" id="modalProductCost" class="form-input" required>
          </div>
          <div class="form-group">
            <label class="form-label">Giá bán (đ) *</label>
            <input type="number" id="modalProductPrice" class="form-input" required>
          </div>
        </div>

        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 14px;">
          <div class="form-group">
            <label class="form-label">Tồn kho hiện tại *</label>
            <input type="number" id="modalProductStock" class="form-input" oninput="checkStockThresholdWarning()" required>
          </div>
          <div class="form-group">
            <label class="form-label">Mức tồn tối thiểu *</label>
            <input type="number" id="modalProductMinStock" class="form-input" oninput="checkStockThresholdWarning()" required>
          </div>
        </div>

        <!-- Dynamic Stock Warning Banner -->
        <div id="modalStockWarning" style="display: none; align-items: center; gap: 10px; background: #fffbeb; border: 1px solid #fde68a; border-radius: 10px; padding: 12px 14px; margin-top: 8px; font-size: 0.8rem; color: #b45309;">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
          <span>Tồn kho hiện tại bằng mức tối thiểu. Sản phẩm đang được gắn nhãn “Chạm đáy”.</span>
        </div>

        <div style="font-size: 0.75rem; color: #94a3b8; margin-top: 14px;">
          * Trường bắt buộc. Thay đổi tồn kho cần có lý do và được lưu trong nhật ký; ưu tiên điều chỉnh qua kiểm kê.
        </div>
      </div>

      <div class="modal-footer">
        <button type="button" class="btn btn-outline" onclick="closeModal('productEditModal')">Hủy</button>
        <button type="submit" class="btn btn-primary">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
          <span>Lưu thay đổi</span>
        </button>
      </div>
    </form>
  </div>
</div>

<!-- ==========================================================================
     MODAL: TỪ CHỐI PHIẾU NHẬP HÀNG (REJECTION REASON)
     ========================================================================== -->
<div class="modal-backdrop" id="rejectTicketModal">
  <div class="modal-window">
    <div class="modal-header">
      <div>
        <h3 class="modal-title">Từ chối phiếu <span id="rejectTicketIdTitle">PN-025</span></h3>
        <div class="modal-sub" id="rejectTicketSub">Granola hạt · Nhà cung cấp Hạt Lành · Người gửi: Trần Quốc Bảo</div>
      </div>
      <button type="button" class="modal-close" onclick="closeModal('rejectTicketModal')">&times;</button>
    </div>

    <div class="modal-body">
      <!-- Summary Box -->
      <div style="display: grid; grid-template-columns: 1fr 1fr; background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 12px; padding: 16px; margin-bottom: 20px;">
        <div>
          <div style="font-size: 0.75rem; color: #64748b;">Số lượng đề nghị</div>
          <div style="font-size: 1.35rem; font-weight: 800; color: #0f172a;" id="rejectQtyDisplay">20 gói</div>
        </div>
        <div>
          <div style="font-size: 0.75rem; color: #64748b;">Tồn kho sau từ chối</div>
          <div style="font-size: 1.35rem; font-weight: 800; color: #0f172a;" id="rejectStockDisplay">6 gói</div>
        </div>
      </div>

      <!-- Textarea Reason with Validation -->
      <div class="form-group">
        <label class="form-label" for="rejectReasonInput">Lý do từ chối *</label>
        <textarea id="rejectReasonInput" class="form-textarea" rows="4" placeholder="Nhập lý do cụ thể để nhân viên kiểm tra lại lô hàng..."></textarea>
        <div class="invalid-feedback" id="rejectReasonError" style="display: none;">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
          <span>Vui lòng nhập lý do từ chối.</span>
        </div>
      </div>

      <!-- Warning Box -->
      <div style="display: flex; align-items: flex-start; gap: 10px; background: #fffbeb; border: 1px solid #fde68a; border-radius: 10px; padding: 12px 14px; margin-top: 14px; font-size: 0.8rem; color: #b45309;">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="flex-shrink:0; margin-top:2px;"><path d="M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
        <div>Phiếu bị từ chối sẽ không cộng số lượng vào kho. Lý do được gửi cho nhân viên và lưu vào Nhật ký hoạt động.</div>
      </div>
    </div>

    <div class="modal-footer">
      <button type="button" class="btn btn-outline" onclick="closeModal('rejectTicketModal')">Hủy</button>
      <button type="button" class="btn btn-primary" onclick="submitRejection()">Xác nhận từ chối</button>
    </div>
  </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/products.js"></script>
<jsp:include page="/common/footer.jsp" />

