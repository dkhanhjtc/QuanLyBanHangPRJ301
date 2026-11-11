-- ========================================================================
-- CƠ SỞ DỮ LIỆU BÁN HÀNG THỜI TRANG (PRJ301)
-- Tên CSDL: QuanLyBanHangThoiTrang
-- Hệ quản trị: Microsoft SQL Server
-- ========================================================================

USE master;
GO

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'QuanLyBanHangThoiTrang')
BEGIN
    CREATE DATABASE QuanLyBanHangThoiTrang;
END
GO

USE QuanLyBanHangThoiTrang;
GO

-- 1. XÓA BẢNG CŨ THEO THỨ TỰ PHỤ THUỘC (NẾU CÓ)
IF OBJECT_ID('SystemNotifications', 'U') IS NOT NULL DROP TABLE SystemNotifications;
IF OBJECT_ID('ActivityLogs', 'U') IS NOT NULL DROP TABLE ActivityLogs;
IF OBJECT_ID('StockTransactions', 'U') IS NOT NULL DROP TABLE StockTransactions;
IF OBJECT_ID('StocktakeAssignments', 'U') IS NOT NULL DROP TABLE StocktakeAssignments;
IF OBJECT_ID('StocktakeDetails', 'U') IS NOT NULL DROP TABLE StocktakeDetails;
IF OBJECT_ID('Stocktakes', 'U') IS NOT NULL DROP TABLE Stocktakes;
IF OBJECT_ID('InboundShipmentDetails', 'U') IS NOT NULL DROP TABLE InboundShipmentDetails;
IF OBJECT_ID('InboundShipments', 'U') IS NOT NULL DROP TABLE InboundShipments;
IF OBJECT_ID('OrderDetails', 'U') IS NOT NULL DROP TABLE OrderDetails;
IF OBJECT_ID('Orders', 'U') IS NOT NULL DROP TABLE Orders;
IF OBJECT_ID('WorkShifts', 'U') IS NOT NULL DROP TABLE WorkShifts;
IF OBJECT_ID('PurchaseOrders', 'U') IS NOT NULL DROP TABLE PurchaseOrders;
IF OBJECT_ID('Products', 'U') IS NOT NULL DROP TABLE Products;
IF OBJECT_ID('Suppliers', 'U') IS NOT NULL DROP TABLE Suppliers;
IF OBJECT_ID('Categories', 'U') IS NOT NULL DROP TABLE Categories;
IF OBJECT_ID('Users', 'U') IS NOT NULL DROP TABLE Users;
GO

-- 2. BẢNG NGƯỜI DÙNG (Users)
CREATE TABLE Users (
    user_id INT IDENTITY(1,1) PRIMARY KEY,
    phone VARCHAR(15) NOT NULL UNIQUE,
    passcode VARCHAR(100) NOT NULL,
    full_name NVARCHAR(100) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('ADMIN', 'MANAGER', 'STAFF')),
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'REVOKED')),
    created_at DATETIME NOT NULL DEFAULT GETDATE()
);
GO

-- 3. BẢNG DANH MỤC HÀNG HÓA (Categories)
CREATE TABLE Categories (
    category_id INT IDENTITY(1,1) PRIMARY KEY,
    category_name NVARCHAR(100) NOT NULL UNIQUE,
    description NVARCHAR(255) NULL,
    created_at DATETIME NOT NULL DEFAULT GETDATE()
);
GO

-- 4. BẢNG NHÀ CUNG CẤP & XƯỞNG MAY (Suppliers)
CREATE TABLE Suppliers (
    supplier_id INT IDENTITY(1,1) PRIMARY KEY,
    supplier_code VARCHAR(30) NOT NULL UNIQUE,
    supplier_name NVARCHAR(150) NOT NULL,
    contact_phone VARCHAR(20) NULL,
    address NVARCHAR(255) NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'INACTIVE')),
    created_at DATETIME NOT NULL DEFAULT GETDATE()
);
GO

-- 5. BẢNG HÀNG HÓA & KHO (Products)
-- Liên kết khóa ngoại: category_id -> Categories, supplier_id -> Suppliers
CREATE TABLE Products (
    product_id INT IDENTITY(1,1) PRIMARY KEY,
    product_code VARCHAR(30) NOT NULL,
    product_name NVARCHAR(150) NOT NULL,
    category_id INT NOT NULL CONSTRAINT FK_Products_Categories REFERENCES Categories(category_id),
    supplier_id INT NULL CONSTRAINT FK_Products_Suppliers REFERENCES Suppliers(supplier_id),
    size VARCHAR(20) NULL,
    color NVARCHAR(50) NULL,
    unit NVARCHAR(30) NOT NULL DEFAULT N'Cái',
    cost_price DECIMAL(18,2) NOT NULL DEFAULT 0,
    retail_price DECIMAL(18,2) NOT NULL DEFAULT 0,
    stock_qty INT NOT NULL DEFAULT 0 CHECK (stock_qty >= 0),
    min_stock_alert INT NOT NULL DEFAULT 5,
    image_url NVARCHAR(255) NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'DISCONTINUED', 'INACTIVE')),
    CONSTRAINT UQ_Products_Code_Size_Color UNIQUE (product_code, size, color)
);
GO

-- 6. BẢNG CA LÀM VIỆC (WorkShifts)
-- Liên kết khóa ngoại: staff_id -> Users
CREATE TABLE WorkShifts (
    shift_id INT IDENTITY(1,1) PRIMARY KEY,
    staff_id INT NOT NULL CONSTRAINT FK_WorkShifts_Users REFERENCES Users(user_id),
    shift_code VARCHAR(50) NOT NULL UNIQUE,
    start_time DATETIME NOT NULL DEFAULT GETDATE(),
    end_time DATETIME NULL,
    opening_cash DECIMAL(18,2) NOT NULL DEFAULT 0,
    closing_cash DECIMAL(18,2) NULL,
    actual_cash DECIMAL(18,2) NULL,
    total_sales DECIMAL(18,2) NOT NULL DEFAULT 0,
    status VARCHAR(20) NOT NULL DEFAULT 'OPEN' CHECK (status IN ('OPEN', 'CLOSED'))
);
GO

-- 7. BẢNG ĐƠN BÁN HÀNG (Orders)
-- Liên kết khóa ngoại: staff_id -> Users, shift_id -> WorkShifts
CREATE TABLE Orders (
    order_id INT IDENTITY(1,1) PRIMARY KEY,
    order_code VARCHAR(50) NOT NULL UNIQUE,
    staff_id INT NOT NULL CONSTRAINT FK_Orders_Staff REFERENCES Users(user_id),
    shift_id INT NULL CONSTRAINT FK_Orders_Shifts REFERENCES WorkShifts(shift_id),
    total_amount DECIMAL(18,2) NOT NULL DEFAULT 0,
    payment_method NVARCHAR(50) NOT NULL DEFAULT N'Tiền mặt',
    status VARCHAR(20) NOT NULL DEFAULT 'COMPLETED' CHECK (status IN ('COMPLETED', 'CANCELLED')),
    created_at DATETIME NOT NULL DEFAULT GETDATE()
);
GO

-- 8. BẢNG CHI TIẾT ĐƠN HÀNG (OrderDetails)
-- Liên kết khóa ngoại: order_id -> Orders, product_id -> Products
CREATE TABLE OrderDetails (
    order_detail_id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT NOT NULL CONSTRAINT FK_OrderDetails_Orders REFERENCES Orders(order_id) ON DELETE CASCADE,
    product_id INT NOT NULL CONSTRAINT FK_OrderDetails_Products REFERENCES Products(product_id),
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(18,2) NOT NULL,
    subtotal DECIMAL(18,2) NOT NULL
);
GO

-- 9. BẢNG PHIẾU NHẬP HÀNG (InboundShipments)
-- Liên kết khóa ngoại: supplier_id -> Suppliers, manager_id -> Users
CREATE TABLE InboundShipments (
    shipment_id INT IDENTITY(1,1) PRIMARY KEY,
    shipment_code VARCHAR(50) NOT NULL UNIQUE,
    supplier_id INT NOT NULL CONSTRAINT FK_InboundShipments_Suppliers REFERENCES Suppliers(supplier_id),
    manager_id INT NOT NULL CONSTRAINT FK_InboundShipments_Users REFERENCES Users(user_id),
    expected_date DATE NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED')),
    notes NVARCHAR(255) NULL,
    created_at DATETIME NOT NULL DEFAULT GETDATE()
);
GO

-- 10. BẢNG CHI TIẾT NHẬP HÀNG (InboundShipmentDetails)
-- Liên kết khóa ngoại: shipment_id -> InboundShipments, product_id -> Products
CREATE TABLE InboundShipmentDetails (
    item_id INT IDENTITY(1,1) PRIMARY KEY,
    shipment_id INT NOT NULL CONSTRAINT FK_InboundShipmentDetails_Shipments REFERENCES InboundShipments(shipment_id) ON DELETE CASCADE,
    product_id INT NOT NULL CONSTRAINT FK_InboundShipmentDetails_Products REFERENCES Products(product_id),
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_cost DECIMAL(18,2) NOT NULL,
    subtotal DECIMAL(18,2) NOT NULL
);
GO

-- 11. BẢNG ĐỢT KIỂM KÊ (Stocktakes)
-- Liên kết khóa ngoại: category_id -> Categories, manager_id -> Users, assigned_staff_id -> Users
CREATE TABLE Stocktakes (
    stocktake_id INT IDENTITY(1,1) PRIMARY KEY,
    stocktake_code VARCHAR(50) NOT NULL UNIQUE,
    title NVARCHAR(150) NOT NULL,
    category_id INT NULL CONSTRAINT FK_Stocktakes_Categories REFERENCES Categories(category_id),
    manager_id INT NOT NULL CONSTRAINT FK_Stocktakes_Manager REFERENCES Users(user_id),
    assigned_staff_id INT NOT NULL CONSTRAINT FK_Stocktakes_Staff REFERENCES Users(user_id),
    status VARCHAR(20) NOT NULL DEFAULT 'ASSIGNED' CHECK (status IN ('ASSIGNED', 'COUNTED', 'APPROVED')),
    notes NVARCHAR(255) NULL,
    created_at DATETIME NOT NULL DEFAULT GETDATE()
);
GO

-- 12. BẢNG CHI TIẾT KIỂM KÊ (StocktakeDetails)
-- Liên kết khóa ngoại: stocktake_id -> Stocktakes, product_id -> Products
CREATE TABLE StocktakeDetails (
    item_id INT IDENTITY(1,1) PRIMARY KEY,
    stocktake_id INT NOT NULL CONSTRAINT FK_StocktakeDetails_Stocktakes REFERENCES Stocktakes(stocktake_id) ON DELETE CASCADE,
    product_id INT NOT NULL CONSTRAINT FK_StocktakeDetails_Products REFERENCES Products(product_id),
    system_qty INT NOT NULL DEFAULT 0,
    actual_qty INT NOT NULL DEFAULT 0,
    discrepancy INT NOT NULL DEFAULT 0,
    note NVARCHAR(255) NULL
);
GO

-- 13. BẢNG PHÂN CÔNG KIỂM KÊ NHÂN VIÊN (StocktakeAssignments)
-- Liên kết khóa ngoại: staff_id -> Users, category_id -> Categories, created_by -> Users
CREATE TABLE StocktakeAssignments (
    assignment_id INT IDENTITY(1,1) PRIMARY KEY,
    staff_id INT NOT NULL CONSTRAINT FK_Assign_Staff REFERENCES Users(user_id),
    category_id INT NULL CONSTRAINT FK_Assign_Category REFERENCES Categories(category_id),
    created_by INT NOT NULL CONSTRAINT FK_Assign_Creator REFERENCES Users(user_id),
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'SUBMITTED', 'APPROVED', 'REJECTED')),
    note NVARCHAR(255) NULL,
    created_at DATETIME NOT NULL DEFAULT GETDATE()
);
GO

-- 14. BẢNG THẺ KHO / BIẾN ĐỘNG TỒN KHO (StockTransactions)
-- Liên kết khóa ngoại: product_id -> Products, created_by -> Users
CREATE TABLE StockTransactions (
    transaction_id INT IDENTITY(1,1) PRIMARY KEY,
    product_id INT NOT NULL CONSTRAINT FK_StockTrans_Products REFERENCES Products(product_id),
    quantity INT NOT NULL,
    stock_before INT NOT NULL,
    stock_after INT NOT NULL,
    transaction_type VARCHAR(30) NOT NULL CHECK (transaction_type IN ('INITIAL', 'STOCKTAKE_ADJUST', 'IMPORT', 'SALE')),
    reference_code VARCHAR(50) NULL,
    created_by INT NOT NULL CONSTRAINT FK_StockTrans_Users REFERENCES Users(user_id),
    note NVARCHAR(255) NULL,
    created_at DATETIME NOT NULL DEFAULT GETDATE()
);
GO

-- 15. BẢNG THÔNG BÁO HỆ THỐNG (SystemNotifications)
-- Liên kết khóa ngoại: user_id -> Users
CREATE TABLE SystemNotifications (
    notification_id BIGINT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NULL CONSTRAINT FK_SystemNotifications_Users REFERENCES Users(user_id),
    title NVARCHAR(150) NOT NULL,
    message NVARCHAR(500) NOT NULL,
    type VARCHAR(30) NOT NULL CHECK (type IN ('SYSTEM', 'STOCKTAKE_SUBMITTED', 'SHIPMENT_PENDING', 'STOCK_ALERT')),
    reference_url VARCHAR(255) NULL,
    is_read BIT NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT GETDATE()
);
GO

-- 16. BẢNG NHẬT KÝ HOẠT ĐỘNG (ActivityLogs)
-- Liên kết khóa ngoại: user_id -> Users
CREATE TABLE ActivityLogs (
    log_id BIGINT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NULL CONSTRAINT FK_ActivityLogs_Users REFERENCES Users(user_id),
    action_type NVARCHAR(100) NOT NULL,
    record_target NVARCHAR(100) NULL,
    description NVARCHAR(255) NULL,
    created_at DATETIME NOT NULL DEFAULT GETDATE()
);
GO

-- 17. BẢNG PHIẾU NHẬP HÀNG CHỜ DUYỆT ĐƠN GIẢN (PurchaseOrders)
-- Liên kết khóa ngoại: createdBy -> Users
CREATE TABLE PurchaseOrders (
    id INT IDENTITY(1,1) PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    supplierName NVARCHAR(100) NOT NULL,
    productId VARCHAR(50) NOT NULL,
    totalQuantity INT NOT NULL,
    totalCost DECIMAL(18,2) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED')),
    rejectReason NVARCHAR(255) NULL,
    createdBy INT NOT NULL CONSTRAINT FK_PurchaseOrders_Users REFERENCES Users(user_id),
    createdAt DATETIME NOT NULL DEFAULT GETDATE()
);
GO

-- ========================================================================
-- 18. DỮ LIỆU MẪU CHUẨN ĐỂ KIỂM THỬ ĐẦY ĐỦ CHỨC NĂNG HỆ THỐNG
-- ========================================================================

-- Dữ liệu tài khoản: ADMIN (1), MANAGER (2), STAFF (3, 4, 5)
SET IDENTITY_INSERT Users ON;
INSERT INTO Users (user_id, phone, passcode, full_name, role, status, created_at) VALUES
(1, '0988000001', '123456', N'Nguyễn Quản Trị', 'ADMIN', 'ACTIVE', '2026-10-20 08:00:00'),
(2, '0988000002', '123456', N'Nguyễn Minh Hà', 'MANAGER', 'ACTIVE', '2026-10-21 08:00:00'),
(3, '0988000003', '123456', N'Lê Lan Anh', 'STAFF', 'ACTIVE', '2026-10-22 08:00:00'),
(4, '0988000004', '123456', N'Trần Quốc Bảo', 'STAFF', 'ACTIVE', '2026-10-23 08:00:00'),
(5, '0988000005', '123456', N'Đỗ Hoàng Nam', 'STAFF', 'REVOKED', '2026-10-24 08:00:00');
SET IDENTITY_INSERT Users OFF;
GO

-- Danh mục nhóm hàng
SET IDENTITY_INSERT Categories ON;
INSERT INTO Categories (category_id, category_name, description, created_at) VALUES
(1, N'Áo sơ mi', N'Áo sơ mi nam nữ công sở, vải cotton, lụa cao cấp', '2026-10-20 08:00:00'),
(2, N'Áo thun / Polo', N'Áo thun cotton, polo pique thể thao năng động', '2026-10-20 08:00:00'),
(3, N'Quần Jean / Quần Tây', N'Quần tây âu công sở, jeans slimfit co giãn', '2026-10-20 08:00:00'),
(4, N'Váy đầm', N'Váy đầm thiết kế thời trang nữ', '2026-10-20 08:00:00'),
(5, N'Áo khoác', N'Áo khoác gió, blazer, bomber chống nắng và giữ ấm', '2026-10-20 08:00:00');
SET IDENTITY_INSERT Categories OFF;
GO

-- Nhà cung cấp & Xưởng may
SET IDENTITY_INSERT Suppliers ON;
INSERT INTO Suppliers (supplier_id, supplier_code, supplier_name, contact_phone, address, status, created_at) VALUES
(1, 'NCC-01', N'Xưởng May Tân Bình Fashion', '0908123456', N'Quận Tân Bình, TP. Hồ Chí Minh', 'ACTIVE', '2026-10-20 08:00:00'),
(2, 'NCC-02', N'Công ty Dệt May Hà Nội', '0912345678', N'KCN Phố Nối, Hưng Yên', 'ACTIVE', '2026-10-20 08:00:00'),
(3, 'NCC-03', N'Xưởng Dệt Kim Đông Xuân', '0987654321', N'Hai Bà Trưng, Hà Nội', 'ACTIVE', '2026-10-20 08:00:00');
SET IDENTITY_INSERT Suppliers OFF;
GO

-- Hàng hóa kho mẫu
SET IDENTITY_INSERT Products ON;
INSERT INTO Products (product_id, product_code, product_name, category_id, supplier_id, size, color, unit, cost_price, retail_price, stock_qty, min_stock_alert, image_url, status) VALUES
(1, 'SM01', N'Áo Sơ Mi Oxford Trắng', 1, 1, 'M', N'Trắng', N'Cái', 200000, 350000, 75, 10, 'SM01.svg', 'ACTIVE'),
(2, 'SM02', N'Áo Sơ Mi Dài Tay Xanh Navy', 1, 1, 'L', N'Xanh Navy', N'Cái', 220000, 380000, 28, 10, 'SM02.svg', 'ACTIVE'),
(3, 'AT01', N'Áo Thun Cotton Compact Đen', 2, 2, 'L', N'Đen', N'Cái', 100000, 190000, 80, 15, 'AT01.svg', 'ACTIVE'),
(4, 'AT02', N'Áo Polo Pique Thoáng Khí', 2, 2, 'M', N'Xanh rêu', N'Cái', 150000, 260000, 4, 10, 'AT02.svg', 'ACTIVE'),
(5, 'QJ01', N'Quần Jeans Slimfit Co Giãn', 3, 1, '31', N'Xanh đậm', N'Cái', 250000, 450000, 42, 10, 'QJ01.svg', 'ACTIVE'),
(6, 'QT01', N'Quần Tây Form Suông Công Sở', 3, 2, '32', N'Xám chì', N'Cái', 240000, 420000, 35, 10, 'QT01.svg', 'ACTIVE'),
(7, 'VD01', N'Váy Đầm Hoa Nhí Dáng Xòe', 4, 3, 'S', N'Vàng hoa', N'Cái', 280000, 490000, 18, 5, 'VD01.svg', 'ACTIVE'),
(8, 'AK01', N'Áo Khoác Bomber Chống Gió', 5, 3, 'XL', N'Đen bóng', N'Cái', 320000, 580000, 3, 5, 'AK01.svg', 'ACTIVE');
SET IDENTITY_INSERT Products OFF;
GO

-- Thẻ kho biến động ban đầu (StockTransactions)
INSERT INTO StockTransactions (product_id, quantity, stock_before, stock_after, transaction_type, reference_code, created_by, note, created_at) VALUES
(1, 75, 0, 75, 'INITIAL', 'INIT-2026', 2, N'Khởi tạo số dư tồn kho ban đầu', '2026-10-20 08:30:00'),
(2, 28, 0, 28, 'INITIAL', 'INIT-2026', 2, N'Khởi tạo số dư tồn kho ban đầu', '2026-10-20 08:30:00'),
(3, 80, 0, 80, 'INITIAL', 'INIT-2026', 2, N'Khởi tạo số dư tồn kho ban đầu', '2026-10-20 08:30:00'),
(4, 4, 0, 4, 'INITIAL', 'INIT-2026', 2, N'Khởi tạo số dư tồn kho ban đầu', '2026-10-20 08:30:00');
GO

-- Phiếu nhập hàng mẫu (PurchaseOrders)
INSERT INTO PurchaseOrders (code, supplierName, productId, totalQuantity, totalCost, status, rejectReason, createdBy, createdAt) VALUES
('PN-026', N'Xưởng May Tân Bình Fashion', '1', 30, 6000000, 'PENDING', NULL, 3, '2026-10-27 09:40:00'),
('PN-025', N'Công ty Dệt May Hà Nội', '4', 20, 3000000, 'PENDING', NULL, 4, '2026-10-27 09:10:00');
GO

-- Đợt kiểm kê mẫu (Stocktakes)
SET IDENTITY_INSERT Stocktakes ON;
INSERT INTO Stocktakes (stocktake_id, stocktake_code, title, category_id, manager_id, assigned_staff_id, status, notes, created_at) VALUES
(1, 'KK-101', N'Khu vực Áo sơ mi & Áo thun', 1, 2, 4, 'COUNTED', N'Đếm cả hàng trưng bày và kho lưu trữ', '2026-10-27 10:25:00'),
(2, 'KK-102', N'Khu vực Quần Jeans & Quần Tây', 3, 2, 3, 'ASSIGNED', N'Kiểm kê trước giờ mở cửa', '2026-10-27 11:00:00');
SET IDENTITY_INSERT Stocktakes OFF;
GO

-- Chi tiết kiểm kê (StocktakeDetails)
INSERT INTO StocktakeDetails (stocktake_id, product_id, system_qty, actual_qty, discrepancy, note) VALUES
(1, 1, 75, 75, 0, N'Khớp hoàn toàn số lượng hệ thống'),
(1, 4, 5, 4, -1, N'Phát hiện 1 áo bị lỗi tem mác cần xử lý');
GO

-- Nhật ký hoạt động mẫu (ActivityLogs)
INSERT INTO ActivityLogs (user_id, action_type, record_target, description, created_at) VALUES
(2, N'Đăng nhập hệ thống', '0988000002', N'Quản lý Nguyễn Minh Hà đăng nhập thành công', '2026-11-10 09:21:43'),
(2, N'Cập nhật hàng hóa', 'SM01', N'Cập nhật thông tin Áo Sơ Mi Oxford Trắng', '2026-11-10 09:31:43'),
(3, N'Bán hàng POS', 'BH-01', N'Thu ngân Lê Lan Anh hoàn tất đơn thanh toán tiền mặt', '2026-11-10 09:41:43');
GO
