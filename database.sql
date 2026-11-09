-- ==============================================================
-- DATABASE INITIALIZATION SCRIPT FOR KIOTFLOW (PRJ301)
-- Database: KiotFlow_DB
-- DBMS: Microsoft SQL Server
-- ==============================================================

USE master;
GO

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'KiotFlow_DB')
BEGIN
    CREATE DATABASE KiotFlow_DB;
END
GO

USE KiotFlow_DB;
GO

-- 1. DROP EXISTING TABLES IN REVERSE ORDER OF DEPENDENCIES
IF OBJECT_ID('ActivityLogs', 'U') IS NOT NULL DROP TABLE ActivityLogs;
IF OBJECT_ID('OrderDetails', 'U') IS NOT NULL DROP TABLE OrderDetails;
IF OBJECT_ID('Orders', 'U') IS NOT NULL DROP TABLE Orders;
IF OBJECT_ID('PurchaseOrders', 'U') IS NOT NULL DROP TABLE PurchaseOrders;
IF OBJECT_ID('StocktakeItems', 'U') IS NOT NULL DROP TABLE StocktakeItems;
IF OBJECT_ID('Stocktakes', 'U') IS NOT NULL DROP TABLE Stocktakes;
IF OBJECT_ID('Products', 'U') IS NOT NULL DROP TABLE Products;
IF OBJECT_ID('Users', 'U') IS NOT NULL DROP TABLE Users;
GO

-- 2. CREATE TABLE Users
CREATE TABLE Users (
    id INT IDENTITY(1,1) PRIMARY KEY,
    loginCode VARCHAR(50) NOT NULL UNIQUE,
    phone VARCHAR(20) NULL,
    fullName NVARCHAR(100) NOT NULL,
    password VARCHAR(100) NOT NULL, -- Plain text theo quy định chấm bài PRJ301
    role VARCHAR(20) NOT NULL,      -- 'ADMIN', 'MANAGER', 'STAFF'
    isActive BIT NOT NULL DEFAULT 1,
    createdAt DATETIME NOT NULL DEFAULT GETDATE()
);
GO

-- 3. CREATE TABLE Products
CREATE TABLE Products (
    id VARCHAR(50) PRIMARY KEY,     -- SKU / Mã sản phẩm (CF01, TE01, ...)
    sku VARCHAR(50) NOT NULL,
    name NVARCHAR(150) NOT NULL,
    category VARCHAR(50) NOT NULL,  -- 'coffee', 'drinks', 'food', 'fashion', ...
    price DECIMAL(18,2) NOT NULL,
    costPrice DECIMAL(18,2) NOT NULL,
    stockQuantity INT NOT NULL DEFAULT 0,
    minStock INT NOT NULL DEFAULT 0,
    unit NVARCHAR(50) NULL,
    spec NVARCHAR(100) NULL,
    imageUrl VARCHAR(255) NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' -- 'ACTIVE', 'INACTIVE'
);
GO

-- 4. CREATE TABLE Orders
CREATE TABLE Orders (
    id INT IDENTITY(1,1) PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE, -- BH-1042, BH-1041, ...
    createdBy INT NOT NULL FOREIGN KEY REFERENCES Users(id),
    totalAmount DECIMAL(18,2) NOT NULL DEFAULT 0,
    paymentMethod NVARCHAR(50) NOT NULL DEFAULT N'Tiền mặt',
    status NVARCHAR(50) NOT NULL DEFAULT N'Đã thanh toán',
    createdAt DATETIME NOT NULL DEFAULT GETDATE()
);
GO

-- 5. CREATE TABLE OrderDetails
CREATE TABLE OrderDetails (
    id INT IDENTITY(1,1) PRIMARY KEY,
    orderId INT NOT NULL FOREIGN KEY REFERENCES Orders(id) ON DELETE CASCADE,
    productId VARCHAR(50) NOT NULL FOREIGN KEY REFERENCES Products(id),
    productName NVARCHAR(150) NOT NULL,
    quantity INT NOT NULL,
    unitPrice DECIMAL(18,2) NOT NULL,
    subtotal DECIMAL(18,2) NOT NULL
);
GO

-- 6. CREATE TABLE PurchaseOrders (Phiếu nhập hàng chờ duyệt)
CREATE TABLE PurchaseOrders (
    id INT IDENTITY(1,1) PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE, -- PN-026, PN-025, ...
    supplierName NVARCHAR(100) NOT NULL,
    productId VARCHAR(50) NOT NULL FOREIGN KEY REFERENCES Products(id),
    totalQuantity INT NOT NULL,
    totalCost DECIMAL(18,2) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING', -- 'PENDING', 'APPROVED', 'REJECTED'
    rejectReason NVARCHAR(255) NULL,
    createdBy INT NOT NULL FOREIGN KEY REFERENCES Users(id),
    createdAt DATETIME NOT NULL DEFAULT GETDATE()
);
GO

-- 7. CREATE TABLE Stocktakes (Phiếu kiểm kê)
CREATE TABLE Stocktakes (
    id INT IDENTITY(1,1) PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE, -- KK-101, KK-102, ...
    title NVARCHAR(150) NOT NULL,
    assignedTo NVARCHAR(100) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'REVIEW', -- 'PENDING', 'REVIEW', 'OVERDUE', 'COMPLETED'
    totalVariance INT NOT NULL DEFAULT 0,
    createdAt DATETIME NOT NULL DEFAULT GETDATE()
);
GO

-- 8. CREATE TABLE StocktakeItems (Chi tiết kiểm kê)
CREATE TABLE StocktakeItems (
    id INT IDENTITY(1,1) PRIMARY KEY,
    stocktakeId INT NOT NULL FOREIGN KEY REFERENCES Stocktakes(id) ON DELETE CASCADE,
    productId VARCHAR(50) NOT NULL FOREIGN KEY REFERENCES Products(id),
    productName NVARCHAR(150) NOT NULL,
    systemStock INT NOT NULL,
    actualStock INT NOT NULL,
    variance INT NOT NULL,
    note NVARCHAR(255) NULL
);
GO

-- 9. CREATE TABLE ActivityLogs (Nhật ký hoạt động hệ thống)
CREATE TABLE ActivityLogs (
    id INT IDENTITY(1,1) PRIMARY KEY,
    userId INT NULL,
    userName NVARCHAR(100) NOT NULL,
    action NVARCHAR(100) NOT NULL,
    details NVARCHAR(500) NULL,
    ipAddress VARCHAR(50) NULL,
    role VARCHAR(50) NULL,
    recordCode VARCHAR(50) NULL,
    result NVARCHAR(50) NULL,
    createdAt DATETIME NOT NULL DEFAULT GETDATE()
);
GO

-- ==============================================================
-- 10. INSERT SAMPLE DATA
-- ==============================================================

-- Bảng Users: 1 Admin, 1 Quản lý, 3 Nhân viên
INSERT INTO Users (loginCode, phone, fullName, password, role, isActive, createdAt) VALUES
('AN-SA-001', '0901234123', N'Mai Anh', '123456', 'ADMIN', 1, '2026-10-20 08:00:00'),
('AN-QL-001', '0909876543', N'Nguyễn Minh Hà', '123456', 'MANAGER', 1, '2026-10-21 08:00:00'),
('AN-NV-002', '0905551122', N'Lê Lan Anh', '123456', 'STAFF', 1, '2026-10-22 08:00:00'),
('AN-NV-003', '0903337788', N'Trần Quốc Bảo', '123456', 'STAFF', 1, '2026-10-23 08:00:00'),
('AN-NV-005', '0909990000', N'Đỗ Hoàng Nam', '123456', 'STAFF', 0, '2026-10-24 08:00:00');
GO

-- Bảng Products: 8 sản phẩm (2 sản phẩm chạm đáy: MK01, GR01)
INSERT INTO Products (id, sku, name, category, price, costPrice, stockQuantity, minStock, unit, spec, imageUrl, status) VALUES
('CF01', 'CF01', N'Cà phê Arabica', 'coffee', 125000, 85000, 24, 10, N'gói', N'Gói 250g', 'CF01.svg', 'ACTIVE'),
('TE01', 'TE01', N'Trà sen', 'coffee', 89000, 60000, 18, 8, N'hộp', N'Hộp 100g', 'TE01.svg', 'ACTIVE'),
('MK01', 'MK01', N'Sữa yến mạch', 'drinks', 59000, 42000, 8, 8, N'hộp', N'Hộp 1L', 'MK01.svg', 'ACTIVE'),
('HN01', 'HN01', N'Mật ong hoa nhãn', 'food', 145000, 95000, 12, 5, N'chai', N'Chai 500ml', 'HN01.svg', 'ACTIVE'),
('GR01', 'GR01', N'Granola hạt', 'food', 99000, 65000, 6, 6, N'gói', N'Gói 300g', 'GR01.svg', 'ACTIVE'),
('CK01', 'CK01', N'Bánh quy bơ', 'food', 65000, 38000, 32, 10, N'hộp', N'Hộp 200g', 'CK01.svg', 'ACTIVE'),
('WA01', 'WA01', N'Nước khoáng', 'drinks', 10000, 5000, 48, 12, N'chai', N'Chai 500ml', 'WA01.svg', 'ACTIVE'),
('CC01', 'CC01', N'Cacao nguyên chất', 'coffee', 105000, 70000, 15, 5, N'gói', N'Gói 200g', 'CC01.svg', 'ACTIVE');
GO

-- Bảng Orders: 4 đơn hàng gần đây
INSERT INTO Orders (code, createdBy, totalAmount, paymentMethod, status, createdAt) VALUES
('BH-1042', 3, 408000, N'Tiền mặt', N'Đã thanh toán', '2026-10-27 10:24:00'),
('BH-1041', 3, 354000, N'Chuyển khoản', N'Đã thanh toán', '2026-10-27 09:52:00'),
('BH-1040', 3, 492000, N'Tiền mặt', N'Đã thanh toán', '2026-10-27 09:15:00'),
('BH-1039', 4, 246000, N'Chuyển khoản', N'Đã thanh toán', '2026-10-26 16:48:00');
GO

-- Bảng OrderDetails
INSERT INTO OrderDetails (orderId, productId, productName, quantity, unitPrice, subtotal) VALUES
(1, 'CF01', N'Cà phê Arabica', 2, 125000, 250000),
(1, 'MK01', N'Sữa yến mạch', 1, 59000, 59000),
(1, 'GR01', N'Granola hạt', 1, 99000, 99000),
(2, 'TE01', N'Trà sen', 2, 89000, 178000),
(2, 'CC01', N'Cacao nguyên chất', 1, 105000, 105000),
(2, 'MK01', N'Sữa yến mạch', 1, 59000, 59000),
(3, 'HN01', N'Mật ong hoa nhãn', 2, 145000, 290000),
(3, 'CF01', N'Cà phê Arabica', 1, 125000, 125000),
(3, 'CK01', N'Bánh quy bơ', 1, 65000, 65000),
(4, 'CK01', N'Bánh quy bơ', 2, 65000, 130000),
(4, 'TE01', N'Trà sen', 1, 89000, 89000),
(4, 'WA01', N'Nước khoáng', 2, 10000, 20000);
GO

-- Bảng PurchaseOrders: 3 phiếu chờ duyệt
INSERT INTO PurchaseOrders (code, supplierName, productId, totalQuantity, totalCost, status, rejectReason, createdBy, createdAt) VALUES
('PN-026', N'Oats Việt', 'MK01', 24, 1008000, 'PENDING', NULL, 3, '2026-10-27 09:40:00'),
('PN-025', N'Hạt Lành', 'GR01', 20, 1300000, 'PENDING', NULL, 4, '2026-10-27 09:10:00'),
('PN-024', N'Cao Nguyên', 'CF01', 12, 1020000, 'PENDING', NULL, 3, '2026-10-27 08:45:00');
GO

-- Bảng Stocktakes
INSERT INTO Stocktakes (code, title, assignedTo, status, totalVariance, createdAt) VALUES
('KK-101', N'Kệ cà phê & trà', N'Trần Quốc Bảo', 'REVIEW', 0, '2026-10-27 10:25:00'),
('KK-102', N'Kệ đồ uống', N'Lê Lan Anh', 'PENDING', 0, '2026-10-27 11:00:00'),
('KK-099', N'Kệ thực phẩm', N'Lê Lan Anh', 'OVERDUE', -2, '2026-10-26 17:00:00'),
('KK-098', N'Kệ nước khoáng', N'Trần Quốc Bảo', 'COMPLETED', 0, '2026-10-26 16:00:00');
GO

-- Bảng StocktakeItems cho KK-101 (chênh lệch CF01: -1, CC01: +1)
INSERT INTO StocktakeItems (stocktakeId, productId, productName, systemStock, actualStock, variance, note) VALUES
(1, 'CF01', N'Cà phê Arabica', 24, 23, -1, N'1 gói rách bao bì, đã tách khỏi kệ bán.'),
(1, 'TE01', N'Trà sen', 18, 18, 0, N'Khớp số lượng hệ thống.'),
(1, 'CC01', N'Cacao nguyên chất', 15, 16, 1, N'Tìm thấy 1 gói tại kệ dự phòng, chưa ghi nhận tồn.');
GO

-- Bảng ActivityLogs
INSERT INTO ActivityLogs (userId, userName, action, details, ipAddress, role, recordCode, result, createdAt) VALUES
(4, N'Trần Quốc Bảo', N'Gửi kết quả kiểm kê', N'3 sản phẩm · 2 chênh lệch · Chờ Quản lý duyệt.', '192.168.1.103', 'STAFF', 'KK-101', N'Đã gửi', '2026-10-27 10:29:02'),
(1, N'Mai Anh', N'Xóa mã đã thu hồi', N'Xóa quyền đăng nhập; giữ nguyên lịch sử.', '192.168.1.100', 'ADMIN', 'AN-NV-006', N'Thành công', '2026-10-27 10:25:18'),
(3, N'Lê Lan Anh', N'Thanh toán đơn bán hàng', N'408.000 đ · Tiền mặt · Trừ tồn 4 sản phẩm.', '192.168.1.102', 'STAFF', 'BH-1042', N'Thành công', '2026-10-27 10:24:36'),
(1, N'Mai Anh', N'Cấp mã đăng nhập', N'Đỗ Hoàng Nam · Vai trò Nhân viên.', '192.168.1.100', 'ADMIN', 'AN-NV-005', N'Thành công', '2026-10-27 10:05:12'),
(2, N'Nguyễn Minh Hà', N'Từ chối hàng về', N'6 chai hở nắp, cần đổi lại lô. Không cộng 36 WA01.', '192.168.1.101', 'MANAGER', 'PN-023', N'Đã từ chối', '2026-10-27 08:35:44');
GO

