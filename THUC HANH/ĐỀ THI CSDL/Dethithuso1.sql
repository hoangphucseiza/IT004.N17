CREATE DATABASE DETHITHUSO1
USE DETHITHUSO1

CREATE TABLE TACGIA
(
	MaTG char(5),
	HoTen varchar(20),
	DiaChi varchar(50),
	NgaySinh smalldatetime,
	DienThoai varchar(15),
	CONSTRAINT PK_TACGIA PRIMARY KEY (MaTG)
)
CREATE TABLE GIAOTRINH
(
	MAGT char(5),
	TenGT varchar(25),
	TheLoai varchar(50),
	CONSTRAINT PK_GIAOTRINH PRIMARY KEY (MAGT)
)
CREATE TABLE TACGIA_GIAOTRINH
(
	MaTG char(5),
	MaGT char(5),
	CONSTRAINT PK_TACGIA_GIAOTRINH PRIMARY KEY (MATG,MAGT)
)
CREATE TABLE PHATHANH
(
	MaPH char(5),
	MaGT char(5),
	NgayPH smalldatetime,
	SoLuong int,
	NXB varchar(25),
	CONSTRAINT PK_PHATHANH PRIMARY KEY (MaPH)
)
 -- Câu 1: Viết câu lệnh SQL tạo ra các quan hệ dựa trên kiểu dữ liệu được mô tả như bảng sau (3đ)
ALTER TABLE PHATHANH ADD CONSTRAINT FK_PHATHANH FOREIGN KEY (MAGT) REFERENCES GIAOTRINH(MaGT)
ALTER TABLE TACGIA_GIAOTRINH ADD CONSTRAINT FK_TACGIA_GIAOTRINH FOREIGN KEY (MATG) REFERENCES TACGIA(MATG)
ALTER TABLE TACGIA_GIAOTRINH ADD CONSTRAINT FK_TACGIA_GIAOTRINH1 FOREIGN KEY (MAGT) REFERENCES GIAOTRINH(MaGT)

-- Câu 2:
-- Ngày phát hành giáo trình phải lớn hơn ngày sinh của tác giả (1.5đ)?
CREATE TRIGGER Cau2
ON PHATHANH FOR INSERT, UPDATE
AS
BEGIN
	DECLARE @NgayPH smalldatetime, @MaGT char(5), @MaTG char(5), @NgaySinh smalldatetime
	SELECT @NgayPH = NgayPH , @MaGT = MaGT FROM INSERTED
	SELECT @MaTG = MaTG FROM TACGIA_GIAOTRINH WHERE MaGT = @MaGT
	SELECT @NgaySinh = NgaySinh From TACGIA WHERE MATG = @MATG
	IF ( @NgaySinh > @NgayPH )
	BEGIN
	rollback transaction
	print ' Ngay Phat hanh giao trinh phai lon hon ngay sinh tac gia'
	END
END
-- Mỗi lần phát hành thì số lượng phải từ 300 quyển trở lên (0.5đ)?
ALTER TABLE PHATHANH ADD CONSTRAINT	CHECK_PHATHANH CHECK( SoLuong >= 300)
-- Câu 3: 
-- Cho biết thông tin Giáo trình (MaGT,TenGT,TheLoai) được phát hành trong năm 2022 ? (1đ)
SELECT MAGT, TenGT,TheLoai
FROM GIAOTRINH
WHERE MAGT in ( SELECT MaGT FROM PHATHANH WHERE YEAR(NgayPH) = 2022 )

-- Cho biết thông tin tác giả (MaTG, HoTen) viết giáo trình có tên là “Cơ sở dữ liệu” do Nhà xuất bản ĐHQG-HCM phát hành? (1đ)
SELECT TACGIA.MaTG, HoTen
FROM TACGIA,GIAOTRINH, TACGIA_GIAOTRINH, PHATHANH
WHERE TenGT = 'Co so du lieu' AND NXB = 'DHQG-HCM'
AND TACGIA.MATG =TACGIA_GIAOTRINH.MATG AND TACGIA_GIAOTRINH.MAGT = GIAOTRINH.MAGT AND GIAOTRINH.MAGT =PHATHANH.MAGT

-- Cho biết số lượng giáo trình của từng tác giả phát hành trong năm 2022? Thông tin hiển thị baogồm: Mã tác giả, tên tác giả và số giáo trình? (1đ)
Select TACGIA.MATG, HoTen , COUNT (GIAOTRINH.MAGT) SOGIAOTRINH
FROM TACGIA,GIAOTRINH, TACGIA_GIAOTRINH, PHATHANH
WHERE TACGIA.MATG =TACGIA_GIAOTRINH.MATG AND TACGIA_GIAOTRINH.MAGT = GIAOTRINH.MAGT AND GIAOTRINH.MAGT =PHATHANH.MAGT AND YEAR(NGayPH) = 2022
GROUP BY TACGIA.MATG, HoTen

-- Cho biết thông tin tác giả (MaTG, HoTen) không phát hành giáo trình nào trong năm 2022? (1đ)
SELECT MATG, HoTen
FROM TACGIA
WHERE MATG not in ( SELECT TACGIA.MATG FROM TACGIA, TACGIA_GIAOTRINH, PHATHANH WHERE 
TACGIA.MATG =TACGIA_GIAOTRINH.MATG AND TACGIA_GIAOTRINH.MAGT = PHATHANH.MAGT AND YEAR(NGAYPH) = 2022 )
-- Tìm nhà xuất bản phát hành nhiều thể loại giáo trình nhất (1đ)? ( Sao dễ z)
SELECT TOP 1 NXB 
FROM PHATHANH
GROUP BY NXB
ORDER BY COUNT(MAGT) DESC