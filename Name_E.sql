USE master
GO

IF EXISTS (SELECT 'true' FROM master.dbo.Sysdatabases WHERE NAME = 'E_QLThuoc')
	DROP DATABASE E_QLThuoc
GO

CREATE DATABASE E_QLThuoc
GO

USE E_QLThuoc
GO

CREATE TABLE THUOC (
	MaThuoc varchar(10) PRIMARY KEY,
	TenThuoc nvarchar(30),
	SoLuong int,
	DonGia money,
	NhaSX nvarchar(30)
)

CREATE TABLE BENHNHAN (
	MaBN varchar(10) PRIMARY KEY,
	TenBN nvarchar(30),
	GioiTinh nvarchar(3)
)

CREATE TABLE DONTHUOC (
	MaDon varchar(10),
	MaThuoc varchar(10),
	SoLuongBan int,
	NgayBan date,
	MaBN varchar(10),
	CONSTRAINT pk_donthuoc_madon_mathuoc PRIMARY KEY (MaDon, MaThuoc),
	CONSTRAINT fk_donthuoc_mathuoc FOREIGN KEY (MaThuoc) REFERENCES THUOC(MaThuoc),
	CONSTRAINT fk_donthuoc_mabn FOREIGN KEY (MaBN) REFERENCES BENHNHAN(MaBN)
)
GO

INSERT THUOC VALUES ('T001', N'Thuốc cảm', 100, 10000, N'Valies'),
					('T002', N'Thuốc sốt', 553, 15000, N'Sumaho'),
					('T003', N'Thuốc ho', 275, 13000, N'Kakolu')
INSERT BENHNHAN VALUES ('BN01', N'Nguyễn Văn Sơn', N'Nam'),
					('BN02', N'Trịnh Văn Quyết', N'Nam'),
					('BN03', N'Vũ Thị Hiền', N'Nữ')
INSERT DONTHUOC VALUES ('DN01', 'T002', 70, '2019-3-17', 'BN03'),
					('DN02', 'T001', 35, '2019-3-17', 'BN03'),
					('DN03', 'T003', 62, '2019-10-3', 'BN02'),
					('DN04', 'T001', 39, '2020-1-21', 'BN01'),
					('DN05', 'T002', 57, '2020-7-29', 'BN02')
GO

SELECT * FROM THUOC
SELECT * FROM DONTHUOC
SELECT * FROM THUOC
GO

CREATE FUNCTION fn_cau2 (@NgayBan date)
RETURNS @bang TABLE(MaBN varchar(10),
					TenBN nvarchar(30),
					GioiTinh nvarchar(3),
					MaThuoc varchar(10),
					TenThuoc nvarchar(30),
					SoLuong int,
					DonGia money
					)
AS
	BEGIN
		INSERT @bang
		SELECT bn.MaBN, TenBN, GioiTinh, t.MaThuoc, TenThuoc, SoLuong, DonGia
		FROM BENHNHAN bn JOIN DONTHUOC dt ON bn.MaBN = dt.MaBN
							JOIN THUOC t ON t.MaThuoc = dt.MaThuoc
		WHERE NgayBan = @NgayBan
		RETURN
	END
GO

SELECT * FROM dbo.fn_cau2 ('2019-10-3')
SELECT * FROM dbo.fn_cau2 ('2019-10-7')
GO

CREATE PROC sp_cau3 (@MaDon varchar(10), @TenThuoc nvarchar(30), @SoLuongBan int, @NgayBan date, @MaBN varchar(10))
AS
	IF NOT EXISTS (SELECT TenThuoc FROM THUOC WHERE TenThuoc = @TenThuoc)
		PRINT N'Tên thuốc không tồn tại'
	ELSE
		BEGIN
			DECLARE @MaThuoc varchar(10)
			SET @MaThuoc = (SELECT MaThuoc FROM THUOC WHERE TenThuoc = @TenThuoc)
			INSERT DONTHUOC VALUES (@MaDon, @MaThuoc, @SoLuongBan, @NgayBan, @MaBN)
		END
GO

EXECUTE sp_cau3 'DN06', N'Thuốc ho', 120, '2020-10-17', 'BN01'
EXECUTE sp_cau3 'DN07', N'Thuốc trĩ', 120, '2020-10-17', 'BN01'
GO

CREATE TRIGGER tg_cau4 ON DONTHUOC
FOR INSERT
AS
	DECLARE @MaThuoc varchar(10), @SoLuongBan int
	SET @MaThuoc = (SELECT MaThuoc FROM inserted)
	SET @SoLuongBan = (SELECT SoLuongBan FROM inserted)
	IF (@SoLuongBan > (SELECT SoLuong FROM THUOC WHERE MaThuoc = @MaThuoc))
		BEGIN
			PRINT N'Số lượng thuốc tồn trong kho không đủ'
			ROLLBACK TRAN
		END
	ELSE
		BEGIN
			UPDATE THUOC SET SoLuong = SoLuong - @SoLuongBan WHERE MaThuoc = @MaThuoc
			PRINT N'Đã thêm đơn thuốc'
		END
GO

INSERT DONTHUOC VALUES ('DN06', 'T001', 20, '2020-12-3', 'BN02')
INSERT DONTHUOC VALUES ('DN07', 'T002', 1000, '2020-12-13', 'BN01')
GO

SELECT * FROM DONTHUOC
	