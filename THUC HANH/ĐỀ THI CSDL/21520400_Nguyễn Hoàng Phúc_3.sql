CREATE DATABASE THICUOIKI
USE THICUOIKI
-- Câu 1:
CREATE TABLE TRUYEN
(
	MaTruyen char(5),
	TenTruyen Nvarchar(20),
	TheLoai Nvarchar(50),
	NXB Nvarchar(20)
	CONSTRAINT PK_TRUYEN PRIMARY KEY (MaTruyen)
)
CREATE TABLE KHACHHANG
(
	MaKH char(5),
	HoTen Nvarchar(25),
	NgaySinh smalldatetime,
	DiaChi Nvarchar(50),
	SoDT varchar(15),
	NgDK smalldatetime,
	CONSTRAINT PK_KHACHHANG PRIMARY KEY (MaKH)
)
CREATE TABLE CHITIET_PHIEUTHUE
(
	MaTruyen char(5),
	MaPT char(5),
	CONSTRAINT PK_CHITIET_PHIEUTHUE PRIMARY KEY (MaTruyen,MaPT)
)
CREATE TABLE PHIEUTHUE
(
	MaPT char(5),
	MaKH char(5),
	NgayThue smalldatetime,
	NgayTra smalldatetime,
	SoTruyenThue int,
	CONSTRAINT PK_PHIEUTHUE PRIMARY KEY (MaPT)
)
ALTER TABLE CHITIET_PHIEUTHUE ADD CONSTRAINT FK_CHITIET_PHIEUTHUE FOREIGN KEY (MaTruyen) REFERENCES Truyen(MaTruyen)
ALTER TABLE CHITIET_PHIEUTHUE ADD CONSTRAINT FK_CHITIET_PHIEUTHUE1 FOREIGN KEY (MaPT) REFERENCES PHIEUTHUE(MaPT)
ALTER TABLE PHIEUTHUE ADD CONSTRAINT FK_PHIEUTHUE FOREIGN KEY (MaKH) REFERENCES KHACHHANG(MaKH)

-- Câu 2:
-- Viết trigger khi thêm hoặc cập nhật một bộ dữ liệu trong bảng PHIEUTHUE thì phải kiểm tra RBTV ngày đăng ký thành viên của khách hàng phải nhỏ hơn ngày khách hàng thuê truyện?
CREATE TRIGGER Cau1
ON PHIEUTHUE FOR INSERT, UPDATE
AS
BEGIN
	DECLARE @MaKH char(5), @NgayThue smalldatetime, @NgDK smalldatetime
	SELECT  @NgayThue = NgayThue, @MaKH = MaKH FROM INSERTED
	SELECT @NgDK = NgDK FROM KHACHHANG WHERE MaKH = @MaKH
	IF ( @NgDK > @NgayThue )
	BEGIN
	rollback transaction
	print ' Ngay DK thanh vien phai nho hon Ngay Thue'
	END
END
-- Mỗi lần thuê truyện phải thuê từ 01 quyển trở lên (0.5đ)
ALTER TABLE PHIEUTHUE ADD CONSTRAINT CHK_PHIEUTHUE CHECK(SoTruyenThue >=1)

-- Câu 3:
-- Cho biết thông tin khách hàng (MaKH, HoTen) có ngày đăng ký thành viên là 26/02/2021? (0,5đ)
SELECT MaKH, HoTen 
FROM KHACHHANG
WHERE NgDK ='26/02/2021'

--Cho biết thông tin truyện (MaTruyen,TenTruyen,TheLoai) được khách hàng thuê vào tháng 12 năm 2022? (1đ)
SELECT TRUYEN.MaTruyen, TenTruyen, TheLoai
FROM TRUYEN, CHITIET_PHIEUTHUE, PHIEUTHUE
WHERE TRUYEN.MaTruyen = CHITIET_PHIEUTHUE.MaTRuyen AND CHITIET_PHIEUTHUE.MaPT = PHIEUTHUE.MaPT
AND MONTH(NgayThue) = 12 AND YEAR(NgayThue) =2022

-- Cho biết thông tin khách hàng (MaKH, HoTen, SoDT) đã thuê truyện thuộc thể loại “Thiếu Nhi” và thể loại “Văn học” trong năm 2022? (1đ)
(Select KHACHHANG.MaKH, HoTen, SoDT
FROM TRUYEN, CHITIET_PHIEUTHUE, PHIEUTHUE, KHACHHANG
WHERE TRUYEN.MaTruyen = CHITIET_PHIEUTHUE.MaTRuyen AND CHITIET_PHIEUTHUE.MaPT = PHIEUTHUE.MaPT AND PHIEUTHUE.MaKH =KHACHHANG.MAKH
AND TheLoai = 'Thiếu Nhi' AND YEAR(NgayThue)= 2022)
INTERSECT
(Select KHACHHANG.MaKH, HoTen, SoDT
FROM TRUYEN, CHITIET_PHIEUTHUE, PHIEUTHUE, KHACHHANG
WHERE TRUYEN.MaTruyen = CHITIET_PHIEUTHUE.MaTRuyen AND CHITIET_PHIEUTHUE.MaPT = PHIEUTHUE.MaPT AND PHIEUTHUE.MaKH =KHACHHANG.MAKH
AND TheLoai = 'Văn học' AND YEAR(NgayThue)= 2022)

-- Cho biết số lượng truyện của từng thể loại được thuê trong năm 2022. Thông tin hiển thị bao gồm: Thể loại, số lượng truyện thuê? (1đ)
Select TheLoai, COUNT(TRUYEN.MaTruyen) SoLuongTruyenThue
FROM TRUYEN, CHITIET_PHIEUTHUE, PHIEUTHUE
WHERE TRUYEN.MaTruyen = CHITIET_PHIEUTHUE.MaTruyen AND CHITIET_PHIEUTHUE.MaPT = PHIEUTHUE.MaPT
AND YEAR(NgayThue)= 2022
GROUP BY TheLoai

-- Cho biết thông tin truyện (MaTruyen, TenTruyen) không được thuê trong năm 2022
SELECT MaTruyen, TenTruyen
FROM TRUYEN
WHERE MaTruyen Not in ( SELECT TRUYEN.MaTruyen FROM TRUYEN, CHITIET_PHIEUTHUE, PHIEUTHUE
WHERE TRUYEN.MaTruyen = CHITIET_PHIEUTHUE.MaTRuyen AND CHITIET_PHIEUTHUE.MaPT = PHIEUTHUE.MaPT
AND YEAR(NgayThue)= 2022 )

--Cho biết khách hàng (MaKH, HoTen) đã thuê nhiều thể loại truyện nhất?
SELECT TOP 1 KHACHHANG.MaKH, HoTen
FROM TRUYEN, CHITIET_PHIEUTHUE, PHIEUTHUE, KHACHHANG
WHERE TRUYEN.MaTruyen = CHITIET_PHIEUTHUE.MaTRuyen AND CHITIET_PHIEUTHUE.MaPT = PHIEUTHUE.MaPT AND PHIEUTHUE.MaKH =KHACHHANG.MAKH
GROUP BY  KHACHHANG.MaKH, HoTen
ORDER BY COUNT(TheLoai) DESC