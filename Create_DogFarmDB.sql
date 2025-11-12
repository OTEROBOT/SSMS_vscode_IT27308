-- ใช้ master database เพื่อจัดการการลบและสร้างฐานข้อมูล
USE master
GO

-- ปิดการเชื่อมต่อทั้งหมดไปยัง DogFarmDB และลบฐานข้อมูลถ้ามี
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'DogFarmDB')
BEGIN
    ALTER DATABASE DogFarmDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DogFarmDB;
END
GO

-- สร้างฐานข้อมูลใหม่
CREATE DATABASE DogFarmDB;
GO

-- เปลี่ยนไปใช้ฐานข้อมูล DogFarmDB
USE DogFarmDB;
GO

-- ให้สิทธิ์ผู้ใช้ Windows (LAPTOP-0ME98POV\Lenovo) เป็น db_owner
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'LAPTOP-0ME98POV\Lenovo')
BEGIN
    CREATE USER [LAPTOP-0ME98POV\Lenovo] FOR LOGIN [LAPTOP-0ME98POV\Lenovo];
    EXEC sp_addrolemember 'db_owner', 'LAPTOP-0ME98POV\Lenovo';
END
GO

-- ลบตารางเก่าถ้ามี
IF OBJECT_ID('ContestHistory') IS NOT NULL DROP TABLE ContestHistory;
IF OBJECT_ID('VaccineHistory') IS NOT NULL DROP TABLE VaccineHistory;
IF OBJECT_ID('Breeding') IS NOT NULL DROP TABLE Breeding;
IF OBJECT_ID('Dog') IS NOT NULL DROP TABLE Dog;
IF OBJECT_ID('Breed') IS NOT NULL DROP TABLE Breed;
GO

-- สร้างตาราง Breed
CREATE TABLE Breed (
    BreedID INT IDENTITY(1,1) PRIMARY KEY,
    BreedName NVARCHAR(100) NOT NULL
);
GO

-- สร้างตาราง Dog
CREATE TABLE Dog (
    DogID INT IDENTITY(1,1) PRIMARY KEY,
    DogName NVARCHAR(100) NOT NULL,
    DOB DATE NOT NULL,
    Gender CHAR(1) NOT NULL CHECK (Gender IN ('M', 'F')),
    Color NVARCHAR(50) NULL,
    Price DECIMAL(10,2) NULL,
    SaleStatus NVARCHAR(50) NOT NULL DEFAULT 'กำลังขาย' CHECK (SaleStatus IN ('กำลังขาย', 'ขายแล้ว', 'ยังไม่ขาย')),
    LifeStatus NVARCHAR(50) NOT NULL DEFAULT 'มีชีวิต' CHECK (LifeStatus IN ('มีชีวิต', 'เสียชีวิต')),
    OriginType NVARCHAR(50) NOT NULL CHECK (OriginType IN ('ซื้อ', 'ผสมพันธุ์', 'รับมา')),
    BreedID INT NULL FOREIGN KEY REFERENCES Breed(BreedID)
);
GO

-- สร้างตาราง Breeding
CREATE TABLE Breeding (
    BreedingID INT IDENTITY(1,1) PRIMARY KEY,
    BreedingDate DATE NOT NULL,
    BreedingDetail NVARCHAR(500) NULL,
    BreedingResult NVARCHAR(200) NULL,
    DeliveryDate DATE NULL,
    MalePuppyCount INT NULL CHECK (MalePuppyCount >= 0),
    FemalePuppyCount INT NULL CHECK (FemalePuppyCount >= 0),
    FatherDogID INT NULL FOREIGN KEY REFERENCES Dog(DogID),
    MotherDogID INT NULL FOREIGN KEY REFERENCES Dog(DogID)
);
GO

-- สร้างตาราง VaccineHistory
CREATE TABLE VaccineHistory (
    VaccineID INT IDENTITY(1,1) PRIMARY KEY,
    DogID INT NOT NULL FOREIGN KEY REFERENCES Dog(DogID),
    VaccineDate DATE NOT NULL,
    VaccineName NVARCHAR(100) NOT NULL,
    Quantity DECIMAL(5,2) NULL,
    Unit NVARCHAR(20) NULL
);
GO

-- สร้างตาราง ContestHistory
CREATE TABLE ContestHistory (
    ContestID INT IDENTITY(1,1) PRIMARY KEY,
    DogID INT NOT NULL FOREIGN KEY REFERENCES Dog(DogID),
    ContestDate DATE NOT NULL,
    ContestName NVARCHAR(100) NOT NULL,
    ContestResult NVARCHAR(200) NULL
);
GO

-- เพิ่ม index เพื่อประสิทธิภาพ
CREATE INDEX IX_Dog_BreedID ON Dog(BreedID);
CREATE INDEX IX_Breeding_FatherDogID ON Breeding(FatherDogID);
CREATE INDEX IX_Breeding_MotherDogID ON Breeding(MotherDogID);
CREATE INDEX IX_VaccineHistory_DogID ON VaccineHistory(DogID);
CREATE INDEX IX_ContestHistory_DogID ON ContestHistory(DogID);
GO

-- เพิ่มข้อมูลตัวอย่าง
INSERT INTO Breed (BreedName) VALUES 
(N'โกลเด้น รีทรีฟเวอร์'),
(N'ลาบราดอร์ รีทรีฟเวอร์');
GO

INSERT INTO Dog (DogName, DOB, Gender, Color, Price, SaleStatus, LifeStatus, OriginType, BreedID) VALUES 
(N'โกลดี้', '2023-01-15', 'F', N'ทอง', 15000.00, N'กำลังขาย', N'มีชีวิต', N'ผสมพันธุ์', 1),
(N'แล็บบี้', '2022-05-20', 'M', N'ดำ', 12000.00, N'ขายแล้ว', N'มีชีวิต', N'ซื้อ', 2);
GO

INSERT INTO Breeding (BreedingDate, BreedingDetail, BreedingResult, DeliveryDate, MalePuppyCount, FemalePuppyCount, FatherDogID, MotherDogID) VALUES 
('2024-06-01', N'ผสมแบบธรรมชาติ', N'สำเร็จ', '2024-09-01', 3, 2, 2, 1);
GO

INSERT INTO VaccineHistory (DogID, VaccineDate, VaccineName, Quantity, Unit) VALUES 
(1, '2023-02-01', N'วัคซีนรวม 6 โรค', 1.00, N'dose'),
(2, '2022-06-15', N'วัคซีนพิษสุนัขบ้า', 1.00, N'dose');
GO

INSERT INTO ContestHistory (DogID, ContestDate, ContestName, ContestResult) VALUES 
(1, '2024-03-10', N'ประกวดสุนัขนานาชาติ', N'ชนะที่ 1');
GO

-- ตรวจสอบว่าสร้างสำเร็จ
PRINT 'สร้างฐานข้อมูล DogFarmDB และตารางทั้งหมดสำเร็จ!';
GO

-- ทดสอบการเข้าถึง
SELECT * FROM sys.database_principals WHERE name = 'LAPTOP-0ME98POV\Lenovo';
SELECT * FROM Breed;
SELECT * FROM Dog;
SELECT * FROM Breeding;
SELECT * FROM VaccineHistory;
SELECT * FROM ContestHistory;
GO

--__________________________________________________________________________________

USE DogFarmDB;
SELECT * FROM Breed;
SELECT * FROM Dog;
SELECT * FROM Breeding;
SELECT * FROM VaccineHistory;
SELECT * FROM ContestHistory;


--___________________________________________________________________________________

USE DogFarmDB;
SELECT * FROM Dog;

--___________________________________________________________________________________
USE DogFarmDB;
ALTER TABLE Breed ADD CONSTRAINT UK_Breed_BreedName UNIQUE (BreedName);


USE DogFarmDB;
ALTER TABLE Breeding ADD CONSTRAINT UK_Breeding_Unique UNIQUE (DogFatherID, DogMotherID, BreedingDate);

--___________________________________________________________________________________
USE master
GO

-- ลบฐานข้อมูลเก่าถ้ามี
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'DogFarmDB')
BEGIN
    ALTER DATABASE DogFarmDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DogFarmDB;
END
GO

-- สร้างฐานข้อมูลใหม่
CREATE DATABASE DogFarmDB;
GO

USE DogFarmDB;
GO

-- ลบตารางเก่า
IF OBJECT_ID('ContestHistory') IS NOT NULL DROP TABLE ContestHistory;
IF OBJECT_ID('VaccineHistory') IS NOT NULL DROP TABLE VaccineHistory;
IF OBJECT_ID('Breeding') IS NOT NULL DROP TABLE Breeding;
IF OBJECT_ID('Dog') IS NOT NULL DROP TABLE Dog;
IF OBJECT_ID('Breed') IS NOT NULL DROP TABLE Breed;
GO

-- สร้างตาราง
CREATE TABLE Breed (
    BreedID INT IDENTITY(1,1) PRIMARY KEY,
    BreedName NVARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Dog (
    DogID INT IDENTITY(1,1) PRIMARY KEY,
    DogName NVARCHAR(100) NOT NULL,
    DOB DATE NOT NULL,
    Gender CHAR(1) NOT NULL CHECK (Gender IN ('M', 'F')),
    Color NVARCHAR(50) NULL,
    Price DECIMAL(10,2) NULL,
    SaleStatus NVARCHAR(50) NOT NULL CHECK (SaleStatus IN (N'กำลังขาย', N'ขายแล้ว', N'ยังไม่ขาย')),
    LifeStatus NVARCHAR(50) NOT NULL CHECK (LifeStatus IN (N'มีชีวิต', N'เสียชีวิต')),
    OriginType NVARCHAR(50) NOT NULL CHECK (OriginType IN (N'ซื้อ', N'ผสมพันธุ์', N'รับมา')),
    BreedID INT NULL FOREIGN KEY REFERENCES Breed(BreedID)
);

CREATE TABLE Breeding (
    BreedingID INT IDENTITY(1,1) PRIMARY KEY,
    BreedingDate DATE NOT NULL,
    FatherDogID INT NULL FOREIGN KEY REFERENCES Dog(DogID),
    MotherDogID INT NULL FOREIGN KEY REFERENCES Dog(DogID),
    MalePuppyCount INT NULL CHECK (MalePuppyCount >= 0),
    FemalePuppyCount INT NULL CHECK (FemalePuppyCount >= 0),
    UNIQUE (FatherDogID, MotherDogID, BreedingDate)
);

CREATE TABLE VaccineHistory (
    VaccineID INT IDENTITY(1,1) PRIMARY KEY,
    DogID INT NOT NULL FOREIGN KEY REFERENCES Dog(DogID),
    VaccineDate DATE NOT NULL,
    VaccineName NVARCHAR(100) NOT NULL,
    Quantity DECIMAL(5,2) NULL,
    Unit NVARCHAR(20) NULL
);

CREATE TABLE ContestHistory (
    ContestID INT IDENTITY(1,1) PRIMARY KEY,
    DogID INT NOT NULL FOREIGN KEY REFERENCES Dog(DogID),
    ContestDate DATE NOT NULL,
    ContestName NVARCHAR(100) NOT NULL,
    ContestResult NVARCHAR(200) NULL
);

-- เพิ่ม Index สำหรับค้นหา
CREATE INDEX IX_Dog_BreedID ON Dog(BreedID);
CREATE INDEX IX_Dog_SaleStatus ON Dog(SaleStatus);
CREATE INDEX IX_Dog_LifeStatus ON Dog(LifeStatus);
CREATE INDEX IX_VaccineHistory_DogID ON VaccineHistory(DogID);
CREATE INDEX IX_VaccineHistory_VaccineName ON VaccineHistory(VaccineName);
CREATE INDEX IX_ContestHistory_DogID ON ContestHistory(DogID);

-- ข้อมูลตัวอย่าง (เหมือนเดิม)
INSERT INTO Breed (BreedName) VALUES (N'โกลเด้น รีทรีฟเวอร์'), (N'ลาบราดอร์ รีทรีฟเวอร์');
INSERT INTO Dog (DogName, DOB, Gender, Color, Price, SaleStatus, LifeStatus, OriginType, BreedID) VALUES 
(N'โกลดี้', '2023-01-15', 'F', N'ทอง', 15000.00, N'กำลังขาย', N'มีชีวิต', N'ผสมพันธุ์', 1),
(N'แล็บบี้', '2022-05-20', 'M', N'ดำ', 12000.00, N'ขายแล้ว', N'มีชีวิต', N'ซื้อ', 2);
INSERT INTO Breeding (BreedingDate, FatherDogID, MotherDogID, MalePuppyCount, FemalePuppyCount) VALUES 
('2024-06-01', 2, 1, 3, 2);
INSERT INTO VaccineHistory (DogID, VaccineDate, VaccineName, Quantity, Unit) VALUES 
(1, '2023-02-01', N'วัคซีนรวม 6 โรค', 1.00, N'dose'),
(2, '2022-06-15', N'วัคซีนพิษสุนัขบ้า', 1.00, N'dose');
INSERT INTO ContestHistory (DogID, ContestDate, ContestName, ContestResult) VALUES 
(1, '2024-03-10', N'ประกวดสุนัขนานาชาติ', N'ชนะที่ 1');

PRINT 'สร้างฐานข้อมูลสำเร็จ!';
GO

--___________________________________________________________________________________
USE master
GO

-- ลบฐานข้อมูลเก่าถ้ามี
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'DogFarmDB')
BEGIN
    ALTER DATABASE DogFarmDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DogFarmDB;
END
GO

-- สร้างฐานข้อมูลใหม่
CREATE DATABASE DogFarmDB;
GO

USE DogFarmDB;
GO

-- ลบตารางเก่า
IF OBJECT_ID('ContestHistory') IS NOT NULL DROP TABLE ContestHistory;
IF OBJECT_ID('VaccineHistory') IS NOT NULL DROP TABLE VaccineHistory;
IF OBJECT_ID('Breeding') IS NOT NULL DROP TABLE Breeding;
IF OBJECT_ID('Dog') IS NOT NULL DROP TABLE Dog;
IF OBJECT_ID('Breed') IS NOT NULL DROP TABLE Breed;
GO

-- สร้างตาราง
CREATE TABLE Breed (
    BreedID INT IDENTITY(1,1) PRIMARY KEY,
    BreedName NVARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Dog (
    DogID INT IDENTITY(1,1) PRIMARY KEY,
    DogName NVARCHAR(100) NOT NULL,
    DOB DATE NOT NULL,
    Gender CHAR(1) NOT NULL CHECK (Gender IN ('M', 'F')),
    Color NVARCHAR(50) NULL,
    Price DECIMAL(10,2) NULL,
    SaleStatus NVARCHAR(50) NOT NULL CHECK (SaleStatus IN (N'กำลังขาย', N'ขายแล้ว', N'ยังไม่ขาย')),
    LifeStatus NVARCHAR(50) NOT NULL CHECK (LifeStatus IN (N'มีชีวิต', N'เสียชีวิต')),
    OriginType NVARCHAR(50) NOT NULL CHECK (OriginType IN (N'ซื้อ', N'ผสมพันธุ์', N'รับมา')),
    BreedID INT NULL FOREIGN KEY REFERENCES Breed(BreedID)
);

CREATE TABLE Breeding (
    BreedingID INT IDENTITY(1,1) PRIMARY KEY,
    BreedingDate DATE NOT NULL,
    FatherDogID INT NULL FOREIGN KEY REFERENCES Dog(DogID),
    MotherDogID INT NULL FOREIGN KEY REFERENCES Dog(DogID),
    MalePuppyCount INT NULL CHECK (MalePuppyCount >= 0),
    FemalePuppyCount INT NULL CHECK (FemalePuppyCount >= 0),
    UNIQUE (FatherDogID, MotherDogID, BreedingDate)
);

CREATE TABLE VaccineHistory (
    VaccineID INT IDENTITY(1,1) PRIMARY KEY,
    DogID INT NOT NULL FOREIGN KEY REFERENCES Dog(DogID),
    VaccineDate DATE NOT NULL,
    VaccineName NVARCHAR(100) NOT NULL,
    Quantity DECIMAL(5,2) NULL,
    Unit NVARCHAR(20) NULL
);

CREATE TABLE ContestHistory (
    ContestID INT IDENTITY(1,1) PRIMARY KEY,
    DogID INT NOT NULL FOREIGN KEY REFERENCES Dog(DogID),
    ContestDate DATE NOT NULL,
    ContestName NVARCHAR(100) NOT NULL,
    ContestResult NVARCHAR(200) NULL
);

-- เพิ่ม Index สำหรับค้นหา
CREATE INDEX IX_Dog_BreedID ON Dog(BreedID);
CREATE INDEX IX_Dog_SaleStatus ON Dog(SaleStatus);
CREATE INDEX IX_Dog_LifeStatus ON Dog(LifeStatus);
CREATE INDEX IX_VaccineHistory_DogID ON VaccineHistory(DogID);
CREATE INDEX IX_VaccineHistory_VaccineName ON VaccineHistory(VaccineName);
CREATE INDEX IX_ContestHistory_DogID ON ContestHistory(DogID);

-- ข้อมูลตัวอย่าง
INSERT INTO Breed (BreedName) VALUES 
(N'โกลเด้น รีทรีฟเวอร์'),
(N'ลาบราดอร์ รีทรีฟเวอร์');

INSERT INTO Dog (DogName, DOB, Gender, Color, Price, SaleStatus, LifeStatus, OriginType, BreedID) VALUES 
(N'โกลดี้', '2023-01-15', 'F', N'ทอง', 15000.00, N'กำลังขาย', N'มีชีวิต', N'ผสมพันธุ์', 1),
(N'แล็บบี้', '2022-05-20', 'M', N'ดำ', 12000.00, N'ขายแล้ว', N'มีชีวิต', N'ซื้อ', 2);

INSERT INTO Breeding (BreedingDate, FatherDogID, MotherDogID, MalePuppyCount, FemalePuppyCount) VALUES 
('2024-06-01', 2, 1, 3, 2);

INSERT INTO VaccineHistory (DogID, VaccineDate, VaccineName, Quantity, Unit) VALUES 
(1, '2023-02-01', N'วัคซีนรวม 6 โรค', 1.00, N'dose'),
(2, '2022-06-15', N'วัคซีนพิษสุนัขบ้า', 1.00, N'dose');

INSERT INTO ContestHistory (DogID, ContestDate, ContestName, ContestResult) VALUES 
(1, '2024-03-10', N'ประกวดสุนัขนานาชาติ', N'ชนะที่ 1');

PRINT 'สร้างฐานข้อมูลและตารางสำเร็จ!';
GO

--___________________________________________________________________________________


USE master
GO

-- ลบฐานข้อมูลเก่าถ้ามี
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'DogFarmDB')
BEGIN
    ALTER DATABASE DogFarmDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DogFarmDB;
END
GO

-- สร้างฐานข้อมูลใหม่
CREATE DATABASE DogFarmDB;
GO

USE DogFarmDB;
GO

-- ลบตารางเก่า
IF OBJECT_ID('ContestHistory') IS NOT NULL DROP TABLE ContestHistory;
IF OBJECT_ID('VaccineHistory') IS NOT NULL DROP TABLE VaccineHistory;
IF OBJECT_ID('Breeding') IS NOT NULL DROP TABLE Breeding;
IF OBJECT_ID('Dog') IS NOT NULL DROP TABLE Dog;
IF OBJECT_ID('Breed') IS NOT NULL DROP TABLE Breed;
GO

-- สร้างตาราง
CREATE TABLE Breed (
    BreedID INT IDENTITY(1,1) PRIMARY KEY,
    BreedName NVARCHAR(100) NOT NULL UNIQUE,
    ImagePath NVARCHAR(255) NULL -- เพิ่มคอลัมน์สำหรับเก็บ path รูปภาพ
);

CREATE TABLE Dog (
    DogID INT IDENTITY(1,1) PRIMARY KEY,
    DogName NVARCHAR(100) NOT NULL,
    DOB DATE NOT NULL,
    Gender CHAR(1) NOT NULL CHECK (Gender IN ('M', 'F')),
    Color NVARCHAR(50) NULL,
    Price DECIMAL(10,2) NULL,
    SaleStatus NVARCHAR(50) NOT NULL CHECK (SaleStatus IN (N'กำลังขาย', N'ขายแล้ว', N'ยังไม่ขาย')),
    LifeStatus NVARCHAR(50) NOT NULL CHECK (LifeStatus IN (N'มีชีวิต', N'เสียชีวิต')),
    OriginType NVARCHAR(50) NOT NULL CHECK (OriginType IN (N'ซื้อ', N'ผสมพันธุ์', N'รับมา')),
    BreedID INT NULL FOREIGN KEY REFERENCES Breed(BreedID)
);

CREATE TABLE Breeding (
    BreedingID INT IDENTITY(1,1) PRIMARY KEY,
    BreedingDate DATE NOT NULL,
    FatherDogID INT NULL FOREIGN KEY REFERENCES Dog(DogID),
    MotherDogID INT NULL FOREIGN KEY REFERENCES Dog(DogID),
    MalePuppyCount INT NULL CHECK (MalePuppyCount >= 0),
    FemalePuppyCount INT NULL CHECK (FemalePuppyCount >= 0),
    UNIQUE (FatherDogID, MotherDogID, BreedingDate)
);

CREATE TABLE VaccineHistory (
    VaccineID INT IDENTITY(1,1) PRIMARY KEY,
    DogID INT NOT NULL FOREIGN KEY REFERENCES Dog(DogID),
    VaccineDate DATE NOT NULL,
    VaccineName NVARCHAR(100) NOT NULL,
    Quantity DECIMAL(5,2) NULL,
    Unit NVARCHAR(20) NULL
);

CREATE TABLE ContestHistory (
    ContestID INT IDENTITY(1,1) PRIMARY KEY,
    DogID INT NOT NULL FOREIGN KEY REFERENCES Dog(DogID),
    ContestDate DATE NOT NULL,
    ContestName NVARCHAR(100) NOT NULL,
    ContestResult NVARCHAR(200) NULL
);

-- เพิ่ม Index สำหรับค้นหา
CREATE INDEX IX_Dog_BreedID ON Dog(BreedID);
CREATE INDEX IX_Dog_SaleStatus ON Dog(SaleStatus);
CREATE INDEX IX_Dog_LifeStatus ON Dog(LifeStatus);
CREATE INDEX IX_VaccineHistory_DogID ON VaccineHistory(DogID);
CREATE INDEX IX_VaccineHistory_VaccineName ON VaccineHistory(VaccineName);
CREATE INDEX IX_ContestHistory_DogID ON ContestHistory(DogID);

-- ข้อมูลตัวอย่าง
INSERT INTO Breed (BreedName, ImagePath) VALUES 
(N'โกลเด้น รีทรีฟเวอร์', NULL),
(N'ลาบราดอร์ รีทรีฟเวอร์', NULL);

INSERT INTO Dog (DogName, DOB, Gender, Color, Price, SaleStatus, LifeStatus, OriginType, BreedID) VALUES 
(N'โกลดี้', '2023-01-15', 'F', N'ทอง', 15000.00, N'กำลังขาย', N'มีชีวิต', N'ผสมพันธุ์', 1),
(N'แล็บบี้', '2022-05-20', 'M', N'ดำ', 12000.00, N'ขายแล้ว', N'มีชีวิต', N'ซื้อ', 2);

INSERT INTO Breeding (BreedingDate, FatherDogID, MotherDogID, MalePuppyCount, FemalePuppyCount) VALUES 
('2024-06-01', 2, 1, 3, 2);

INSERT INTO VaccineHistory (DogID, VaccineDate, VaccineName, Quantity, Unit) VALUES 
(1, '2023-02-01', N'วัคซีนรวม 6 โรค', 1.00, N'dose'),
(2, '2022-06-15', N'วัคซีนพิษสุนัขบ้า', 1.00, N'dose');

INSERT INTO ContestHistory (DogID, ContestDate, ContestName, ContestResult) VALUES 
(1, '2024-03-10', N'ประกวดสุนัขนานาชาติ', N'ชนะที่ 1');

PRINT 'สร้างฐานข้อมูลและตารางสำเร็จ!';
GO

--___________________________________________________________________________________
USE master
GO

-- ลบฐานข้อมูลเก่าถ้ามี
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'DogFarmDB')
BEGIN
    ALTER DATABASE DogFarmDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DogFarmDB;
END
GO

-- สร้างฐานข้อมูลใหม่
CREATE DATABASE DogFarmDB;
GO

USE DogFarmDB;
GO

-- ลบตารางเก่า
IF OBJECT_ID('ContestHistory') IS NOT NULL DROP TABLE ContestHistory;
IF OBJECT_ID('VaccineHistory') IS NOT NULL DROP TABLE VaccineHistory;
IF OBJECT_ID('Breeding') IS NOT NULL DROP TABLE Breeding;
IF OBJECT_ID('Dog') IS NOT NULL DROP TABLE Dog;
IF OBJECT_ID('Breed') IS NOT NULL DROP TABLE Breed;
GO

-- สร้างตาราง
CREATE TABLE Breed (
    BreedID INT IDENTITY(1,1) PRIMARY KEY,
    BreedName NVARCHAR(100) NOT NULL UNIQUE,
    ImagePath NVARCHAR(255) NULL
);

CREATE TABLE Dog (
    DogID INT IDENTITY(1,1) PRIMARY KEY,
    DogName NVARCHAR(100) NOT NULL,
    DOB DATE NOT NULL,
    Gender CHAR(1) NOT NULL CHECK (Gender IN ('M', 'F')),
    Color NVARCHAR(50) NULL,
    Price DECIMAL(10,2) NULL,
    SaleStatus NVARCHAR(50) NOT NULL CHECK (SaleStatus IN (N'กำลังขาย', N'ขายแล้ว', N'ยังไม่ขาย')),
    LifeStatus NVARCHAR(50) NOT NULL CHECK (LifeStatus IN (N'มีชีวิต', N'เสียชีวิต')),
    OriginType NVARCHAR(50) NOT NULL CHECK (OriginType IN (N'ซื้อ', N'ผสมพันธุ์', N'รับมา')),
    BreedID INT NULL FOREIGN KEY REFERENCES Breed(BreedID),
    ImagePath NVARCHAR(255) NULL -- เพิ่มคอลัมน์สำหรับเก็บ path รูปภาพ
);

CREATE TABLE Breeding (
    BreedingID INT IDENTITY(1,1) PRIMARY KEY,
    BreedingDate DATE NOT NULL,
    FatherDogID INT NULL FOREIGN KEY REFERENCES Dog(DogID),
    MotherDogID INT NULL FOREIGN KEY REFERENCES Dog(DogID),
    MalePuppyCount INT NULL CHECK (MalePuppyCount >= 0),
    FemalePuppyCount INT NULL CHECK (FemalePuppyCount >= 0),
    UNIQUE (FatherDogID, MotherDogID, BreedingDate)
);

CREATE TABLE VaccineHistory (
    VaccineID INT IDENTITY(1,1) PRIMARY KEY,
    DogID INT NOT NULL FOREIGN KEY REFERENCES Dog(DogID),
    VaccineDate DATE NOT NULL,
    VaccineName NVARCHAR(100) NOT NULL,
    Quantity DECIMAL(5,2) NULL,
    Unit NVARCHAR(20) NULL
);

CREATE TABLE ContestHistory (
    ContestID INT IDENTITY(1,1) PRIMARY KEY,
    DogID INT NOT NULL FOREIGN KEY REFERENCES Dog(DogID),
    ContestDate DATE NOT NULL,
    ContestName NVARCHAR(100) NOT NULL,
    ContestResult NVARCHAR(200) NULL
);

-- เพิ่ม Index สำหรับค้นหา
CREATE INDEX IX_Dog_BreedID ON Dog(BreedID);
CREATE INDEX IX_Dog_SaleStatus ON Dog(SaleStatus);
CREATE INDEX IX_Dog_LifeStatus ON Dog(LifeStatus);
CREATE INDEX IX_VaccineHistory_DogID ON VaccineHistory(DogID);
CREATE INDEX IX_VaccineHistory_VaccineName ON VaccineHistory(VaccineName);
CREATE INDEX IX_ContestHistory_DogID ON ContestHistory(DogID);

-- ข้อมูลตัวอย่าง
INSERT INTO Breed (BreedName, ImagePath) VALUES 
(N'โกลเด้น รีทรีฟเวอร์', NULL),
(N'ลาบราดอร์ รีทรีฟเวอร์', NULL);

INSERT INTO Dog (DogName, DOB, Gender, Color, Price, SaleStatus, LifeStatus, OriginType, BreedID, ImagePath) VALUES 
(N'โกลดี้', '2023-01-15', 'F', N'ทอง', 15000.00, N'กำลังขาย', N'มีชีวิต', N'ผสมพันธุ์', 1, NULL),
(N'แล็บบี้', '2022-05-20', 'M', N'ดำ', 12000.00, N'ขายแล้ว', N'มีชีวิต', N'ซื้อ', 2, NULL);

INSERT INTO Breeding (BreedingDate, FatherDogID, MotherDogID, MalePuppyCount, FemalePuppyCount) VALUES 
('2024-06-01', 2, 1, 3, 2);

INSERT INTO VaccineHistory (DogID, VaccineDate, VaccineName, Quantity, Unit) VALUES 
(1, '2023-02-01', N'วัคซีนรวม 6 โรค', 1.00, N'dose'),
(2, '2022-06-15', N'วัคซีนพิษสุนัขบ้า', 1.00, N'dose');

INSERT INTO ContestHistory (DogID, ContestDate, ContestName, ContestResult) VALUES 
(1, '2024-03-10', N'ประกวดสุนัขนานาชาติ', N'ชนะที่ 1');

PRINT 'สร้างฐานข้อมูลและตารางสำเร็จ!';
GO

--___________________________________________________________________________________
USE master
GO

-- ลบฐานข้อมูลเก่าถ้ามี
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'DogFarmDB')
BEGIN
    ALTER DATABASE DogFarmDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DogFarmDB;
END
GO

-- สร้างฐานข้อมูลใหม่
CREATE DATABASE DogFarmDB;
GO

USE DogFarmDB;
GO

-- ลบตารางเก่า
IF OBJECT_ID('ContestHistory') IS NOT NULL DROP TABLE ContestHistory;
IF OBJECT_ID('VaccineHistory') IS NOT NULL DROP TABLE VaccineHistory;
IF OBJECT_ID('Breeding') IS NOT NULL DROP TABLE Breeding;
IF OBJECT_ID('Dog') IS NOT NULL DROP TABLE Dog;
IF OBJECT_ID('Breed') IS NOT NULL DROP TABLE Breed;
GO

-- สร้างตาราง
CREATE TABLE Breed (
    BreedID INT IDENTITY(1,1) PRIMARY KEY,
    BreedName NVARCHAR(100) NOT NULL UNIQUE,
    ImagePath NVARCHAR(255) NULL,
    Description NVARCHAR(MAX) NULL -- เพิ่มคอลัมน์สำหรับเก็บรายละเอียดสายพันธุ์
);

CREATE TABLE Dog (
    DogID INT IDENTITY(1,1) PRIMARY KEY,
    DogName NVARCHAR(100) NOT NULL,
    DOB DATE NOT NULL,
    Gender CHAR(1) NOT NULL CHECK (Gender IN ('M', 'F')),
    Color NVARCHAR(50) NULL,
    Price DECIMAL(10,2) NULL,
    SaleStatus NVARCHAR(50) NOT NULL CHECK (SaleStatus IN (N'กำลังขาย', N'ขายแล้ว', N'ยังไม่ขาย')),
    LifeStatus NVARCHAR(50) NOT NULL CHECK (LifeStatus IN (N'มีชีวิต', N'เสียชีวิต')),
    OriginType NVARCHAR(50) NOT NULL CHECK (OriginType IN (N'ซื้อ', N'ผสมพันธุ์', N'รับมา')),
    BreedID INT NULL FOREIGN KEY REFERENCES Breed(BreedID),
    ImagePath NVARCHAR(255) NULL
);

CREATE TABLE Breeding (
    BreedingID INT IDENTITY(1,1) PRIMARY KEY,
    BreedingDate DATE NOT NULL,
    FatherDogID INT NULL FOREIGN KEY REFERENCES Dog(DogID),
    MotherDogID INT NULL FOREIGN KEY REFERENCES Dog(DogID),
    MalePuppyCount INT NULL CHECK (MalePuppyCount >= 0),
    FemalePuppyCount INT NULL CHECK (FemalePuppyCount >= 0),
    UNIQUE (FatherDogID, MotherDogID, BreedingDate)
);

CREATE TABLE VaccineHistory (
    VaccineID INT IDENTITY(1,1) PRIMARY KEY,
    DogID INT NOT NULL FOREIGN KEY REFERENCES Dog(DogID),
    VaccineDate DATE NOT NULL,
    VaccineName NVARCHAR(100) NOT NULL,
    Quantity DECIMAL(5,2) NULL,
    Unit NVARCHAR(20) NULL
);

CREATE TABLE ContestHistory (
    ContestID INT IDENTITY(1,1) PRIMARY KEY,
    DogID INT NOT NULL FOREIGN KEY REFERENCES Dog(DogID),
    ContestDate DATE NOT NULL,
    ContestName NVARCHAR(100) NOT NULL,
    ContestResult NVARCHAR(200) NULL
);

-- เพิ่ม Index สำหรับค้นหา
CREATE INDEX IX_Dog_BreedID ON Dog(BreedID);
CREATE INDEX IX_Dog_SaleStatus ON Dog(SaleStatus);
CREATE INDEX IX_Dog_LifeStatus ON Dog(LifeStatus);
CREATE INDEX IX_VaccineHistory_DogID ON VaccineHistory(DogID);
CREATE INDEX IX_VaccineHistory_VaccineName ON VaccineHistory(VaccineName);
CREATE INDEX IX_ContestHistory_DogID ON ContestHistory(DogID);

-- ข้อมูลตัวอย่าง
INSERT INTO Breed (BreedName, ImagePath, Description) VALUES 
(N'โกลเด้น รีทรีฟเวอร์', NULL, N'สุนัขที่มีนิสัยเป็นมิตร อ่อนโยน และฉลาด เหมาะสำหรับครอบครัวและการฝึกเป็นสุนัขช่วยเหลือ'),
(N'ลาบราดอร์ รีทรีฟเวอร์', NULL, N'สุนัขที่มีพลังงานสูง รักการเล่น และมีความจงรักภักดี เหมาะสำหรับงานค้นหาและช่วยเหลือ');

INSERT INTO Dog (DogName, DOB, Gender, Color, Price, SaleStatus, LifeStatus, OriginType, BreedID, ImagePath) VALUES 
(N'โกลดี้', '2023-01-15', 'F', N'ทอง', 15000.00, N'กำลังขาย', N'มีชีวิต', N'ผสมพันธุ์', 1, NULL),
(N'แล็บบี้', '2022-05-20', 'M', N'ดำ', 12000.00, N'ขายแล้ว', N'มีชีวิต', N'ซื้อ', 2, NULL);

INSERT INTO Breeding (BreedingDate, FatherDogID, MotherDogID, MalePuppyCount, FemalePuppyCount) VALUES 
('2024-06-01', 2, 1, 3, 2);

INSERT INTO VaccineHistory (DogID, VaccineDate, VaccineName, Quantity, Unit) VALUES 
(1, '2023-02-01', N'วัคซีนรวม 6 โรค', 1.00, N'dose'),
(2, '2022-06-15', N'วัคซีนพิษสุนัขบ้า', 1.00, N'dose');

INSERT INTO ContestHistory (DogID, ContestDate, ContestName, ContestResult) VALUES 
(1, '2024-03-10', N'ประกวดสุนัขนานาชาติ', N'ชนะที่ 1');

PRINT 'สร้างฐานข้อมูลและตารางสำเร็จ!';
GO

--___________________________________________________________________________________
USE master
GO

-- ลบฐานข้อมูลเก่าถ้ามี
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'DogFarmDB')
BEGIN
    ALTER DATABASE DogFarmDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DogFarmDB;
END
GO

-- สร้างฐานข้อมูลใหม่
CREATE DATABASE DogFarmDB;
GO

USE DogFarmDB;
GO

-- ลบตารางเก่า
IF OBJECT_ID('ContestHistory') IS NOT NULL DROP TABLE ContestHistory;
IF OBJECT_ID('VaccineHistory') IS NOT NULL DROP TABLE VaccineHistory;
IF OBJECT_ID('Breeding') IS NOT NULL DROP TABLE Breeding;
IF OBJECT_ID('Dog') IS NOT NULL DROP TABLE Dog;
IF OBJECT_ID('Breed') IS NOT NULL DROP TABLE Breed;
GO

-- สร้างตาราง
CREATE TABLE Breed (
    BreedID INT IDENTITY(1,1) PRIMARY KEY,
    BreedName NVARCHAR(100) NOT NULL UNIQUE,
    ImagePath NVARCHAR(255) NULL,
    Description NVARCHAR(MAX) NULL
);

CREATE TABLE Dog (
    DogID INT IDENTITY(1,1) PRIMARY KEY,
    DogName NVARCHAR(100) NOT NULL,
    DOB DATE NOT NULL,
    Gender CHAR(1) NOT NULL CHECK (Gender IN ('M', 'F')),
    Color NVARCHAR(50) NULL,
    Price DECIMAL(10,2) NULL,
    SaleStatus NVARCHAR(50) NOT NULL CHECK (SaleStatus IN (N'กำลังขาย', N'ขายแล้ว', N'ยังไม่ขาย')),
    LifeStatus NVARCHAR(50) NOT NULL CHECK (LifeStatus IN (N'มีชีวิต', N'เสียชีวิต')),
    OriginType NVARCHAR(50) NOT NULL CHECK (OriginType IN (N'ซื้อ', N'ผสมพันธุ์', N'รับมา')),
    BreedID INT NULL FOREIGN KEY REFERENCES Breed(BreedID),
    ImagePath NVARCHAR(255) NULL,
    PedigreeNumber NVARCHAR(50) NULL -- เพิ่มคอลัมน์สำหรับเลขเพ็ดดีกรี
);

CREATE TABLE Breeding (
    BreedingID INT IDENTITY(1,1) PRIMARY KEY,
    BreedingDate DATE NOT NULL,
    FatherDogID INT NULL FOREIGN KEY REFERENCES Dog(DogID),
    MotherDogID INT NULL FOREIGN KEY REFERENCES Dog(DogID),
    MalePuppyCount INT NULL CHECK (MalePuppyCount >= 0),
    FemalePuppyCount INT NULL CHECK (FemalePuppyCount >= 0),
    Description NVARCHAR(MAX) NULL,
    UNIQUE (FatherDogID, MotherDogID, BreedingDate)
);

CREATE TABLE VaccineHistory (
    VaccineID INT IDENTITY(1,1) PRIMARY KEY,
    DogID INT NOT NULL FOREIGN KEY REFERENCES Dog(DogID),
    VaccineDate DATE NOT NULL,
    VaccineName NVARCHAR(100) NOT NULL,
    Quantity DECIMAL(5,2) NULL,
    Unit NVARCHAR(20) NULL
);

CREATE TABLE ContestHistory (
    ContestID INT IDENTITY(1,1) PRIMARY KEY,
    DogID INT NOT NULL FOREIGN KEY REFERENCES Dog(DogID),
    ContestDate DATE NOT NULL,
    ContestName NVARCHAR(100) NOT NULL,
    ContestResult NVARCHAR(200) NULL
);

-- เพิ่ม Index สำหรับค้นหา
CREATE INDEX IX_Dog_BreedID ON Dog(BreedID);
CREATE INDEX IX_Dog_SaleStatus ON Dog(SaleStatus);
CREATE INDEX IX_Dog_LifeStatus ON Dog(LifeStatus);
CREATE INDEX IX_VaccineHistory_DogID ON VaccineHistory(DogID);
CREATE INDEX IX_VaccineHistory_VaccineName ON VaccineHistory(VaccineName);
CREATE INDEX IX_ContestHistory_DogID ON ContestHistory(DogID);

-- ข้อมูลตัวอย่าง
INSERT INTO Breed (BreedName, ImagePath, Description) VALUES 
(N'โกลเด้น รีทรีฟเวอร์', NULL, N'สุนัขที่มีนิสัยเป็นมิตร อ่อนโยน และฉลาด เหมาะสำหรับครอบครัวและการฝึกเป็นสุนัขช่วยเหลือ'),
(N'ลาบราดอร์ รีทรีฟเวอร์', NULL, N'สุนัขที่มีพลังงานสูง รักการเล่น และมีความจงรักภักดี เหมาะสำหรับงานค้นหาและช่วยเหลือ');

INSERT INTO Dog (DogName, DOB, Gender, Color, Price, SaleStatus, LifeStatus, OriginType, BreedID, ImagePath, PedigreeNumber) VALUES 
(N'โกลดี้', '2023-01-15', 'F', N'ทอง', 15000.00, N'กำลังขาย', N'มีชีวิต', N'ผสมพันธุ์', 1, NULL, N'PED-GR-001'),
(N'แล็บบี้', '2022-05-20', 'M', N'ดำ', 12000.00, N'ขายแล้ว', N'มีชีวิต', N'ซื้อ', 2, NULL, N'PED-LR-001');

INSERT INTO Breeding (BreedingDate, FatherDogID, MotherDogID, MalePuppyCount, FemalePuppyCount, Description) VALUES 
('2024-06-01', 2, 1, 3, 2, N'การผสมพันธุ์ครั้งนี้สำเร็จดี ลูกสุนัขแข็งแรง');

INSERT INTO VaccineHistory (DogID, VaccineDate, VaccineName, Quantity, Unit) VALUES 
(1, '2023-02-01', N'วัคซีนรวม 6 โรค', 1.00, N'dose'),
(2, '2022-06-15', N'วัคซีนพิษสุนัขบ้า', 1.00, N'dose');

INSERT INTO ContestHistory (DogID, ContestDate, ContestName, ContestResult) VALUES 
(1, '2024-03-10', N'ประกวดสุนัขนานาชาติ', N'ชนะที่ 1');

PRINT 'สร้างฐานข้อมูลและตารางสำเร็จ!';
GO

--___________________________________________________________________________________
-- เริ่มต้นการทำงานในโหมด master เพื่อจัดการฐานข้อมูล
USE master
GO

-- ตรวจสอบว่ามีฐานข้อมูลชื่อ DogFarmDB อยู่หรือไม่ ถ้ามีจะลบเพื่อสร้างใหม่
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'DogFarmDB')
BEGIN
    ALTER DATABASE DogFarmDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DogFarmDB;
END
GO

-- สร้างฐานข้อมูลใหม่ชื่อ DogFarmDB
CREATE DATABASE DogFarmDB;
GO

-- เปลี่ยนไปใช้ฐานข้อมูล DogFarmDB เพื่อสร้างตารางและเพิ่มข้อมูล
USE DogFarmDB;
GO

-- ลบตารางเก่าทั้งหมด (ถ้ามี)
IF OBJECT_ID('ContestHistory') IS NOT NULL DROP TABLE ContestHistory;
IF OBJECT_ID('VaccineHistory') IS NOT NULL DROP TABLE VaccineHistory;
IF OBJECT_ID('Breeding') IS NOT NULL DROP TABLE Breeding;
IF OBJECT_ID('Dog') IS NOT NULL DROP TABLE Dog;
IF OBJECT_ID('Breed') IS NOT NULL DROP TABLE Breed;
GO

-- สร้างตาราง Breed
CREATE TABLE Breed (
    BreedID INT IDENTITY(1,1) PRIMARY KEY,
    BreedName NVARCHAR(100) NOT NULL UNIQUE,
    ImagePath NVARCHAR(255) NULL,
    Description NVARCHAR(MAX) NULL
);

-- สร้างตาราง Dog
CREATE TABLE Dog (
    DogID INT IDENTITY(1,1) PRIMARY KEY,
    DogName NVARCHAR(100) NOT NULL,
    DOB DATE NOT NULL,
    Gender CHAR(1) NOT NULL CHECK (Gender IN ('M', 'F')),
    Color NVARCHAR(50) NULL,
    Price DECIMAL(10,2) NULL,
    SaleStatus NVARCHAR(50) NOT NULL CHECK (SaleStatus IN (N'กำลังขาย', N'ขายแล้ว', N'ยังไม่ขาย')),
    LifeStatus NVARCHAR(50) NOT NULL CHECK (LifeStatus IN (N'มีชีวิต', N'เสียชีวิต')),
    OriginType NVARCHAR(50) NOT NULL CHECK (OriginType IN (N'ซื้อ', N'ผสมพันธุ์', N'รับมา')),
    BreedID INT NULL FOREIGN KEY REFERENCES Breed(BreedID),
    ImagePath NVARCHAR(255) NULL,
    BreedingID INT NULL FOREIGN KEY REFERENCES Breeding(BreedingID),
    PedigreeNumber NVARCHAR(50) NULL
);

-- สร้างตาราง Breeding
CREATE TABLE Breeding (
    BreedingID INT IDENTITY(1,1) PRIMARY KEY,
    BreedingDate DATE NOT NULL,
    FatherDogID INT NULL FOREIGN KEY REFERENCES Dog(DogID),
    MotherDogID INT NULL FOREIGN KEY REFERENCES Dog(DogID),
    MalePuppyCount INT NULL CHECK (MalePuppyCount >= 0),
    FemalePuppyCount INT NULL CHECK (FemalePuppyCount >= 0),
    --ALTER TABLE Breeding ADD Result NVARCHAR(50) NULL;
    Description NVARCHAR(MAX) NULL,
    UNIQUE (FatherDogID, MotherDogID, BreedingDate)
);

-- สร้างตาราง VaccineHistory ด้วย PRIMARY KEY คอมโพสิตและ FOREIGN KEY
CREATE TABLE VaccineHistory (
    VaccineID INT IDENTITY(1,1),
    DogID INT NOT NULL,
    VaccineDate DATE NOT NULL,
    VaccineName NVARCHAR(100) NOT NULL,
    Quantity DECIMAL(5,2) NULL,
    Unit NVARCHAR(20) NULL,
    -- กำหนด PRIMARY KEY คอมโพสิตจาก VaccineID และ DogID
    PRIMARY KEY (VaccineID, DogID),
    -- กำหนด DogID เป็น FOREIGN KEY อ้างอิงตาราง Dog
    FOREIGN KEY (DogID) REFERENCES Dog(DogID)
);

-- สร้างตาราง ContestHistory ด้วย PRIMARY KEY คอมโพสิตและ FOREIGN KEY
CREATE TABLE ContestHistory (
    ContestID INT IDENTITY(1,1),
    DogID INT NOT NULL,
    ContestDate DATE NOT NULL,
    ContestName NVARCHAR(100) NOT NULL,
    ContestResult NVARCHAR(200) NULL,
    -- กำหนด PRIMARY KEY คอมโพสิตจาก ContestID และ DogID
    PRIMARY KEY (ContestID, DogID),
    -- กำหนด DogID เป็น FOREIGN KEY อ้างอิงตาราง Dog
    FOREIGN KEY (DogID) REFERENCES Dog(DogID)
);

-- สร้าง Index เพื่อเพิ่มประสิทธิภาพการค้นหาข้อมูล
CREATE INDEX IX_Dog_BreedID ON Dog(BreedID);
CREATE INDEX IX_Dog_SaleStatus ON Dog(SaleStatus);
CREATE INDEX IX_Dog_LifeStatus ON Dog(LifeStatus);
CREATE INDEX IX_VaccineHistory_DogID ON VaccineHistory(DogID);
CREATE INDEX IX_VaccineHistory_VaccineName ON VaccineHistory(VaccineName);
CREATE INDEX IX_ContestHistory_DogID ON ContestHistory(DogID);

-- เพิ่มข้อมูลตัวอย่างในตาราง Breed
INSERT INTO Breed (BreedName, ImagePath, Description) VALUES 
(N'โกลเด้น รีทรีฟเวอร์', NULL, N'สุนัขที่มีนิสัยเป็นมิตร อ่อนโยน และฉลาด'),
(N'ลาบราดอร์ รีทรีฟเวอร์', NULL, N'สุนัขที่มีพลังงานสูง รักการเล่น และมีความจงรักภักดี');

-- เพิ่มข้อมูลตัวอย่างในตาราง Dog
INSERT INTO Dog (DogName, DOB, Gender, Color, Price, SaleStatus, LifeStatus, OriginType, BreedID, ImagePath, PedigreeNumber) VALUES 
(N'โกลดี้', '2023-01-15', 'F', N'ทอง', 15000.00, N'กำลังขาย', N'มีชีวิต', N'ผสมพันธุ์', 1, NULL, N'PED-GR-001'),
(N'แล็บบี้', '2022-05-20', 'M', N'ดำ', 12000.00, N'ขายแล้ว', N'มีชีวิต', N'ซื้อ', 2, NULL, N'PED-LR-001');

-- เพิ่มข้อมูลตัวอย่างในตาราง Breeding
INSERT INTO Breeding (BreedingDate, FatherDogID, MotherDogID, MalePuppyCount, FemalePuppyCount, Description) VALUES 
('2024-06-01', 2, 1, 3, 2, N'การผสมพันธุ์ครั้งนี้สำเร็จดี ลูกสุนัขแข็งแรง');

-- เพิ่มข้อมูลตัวอย่างในตาราง VaccineHistory
INSERT INTO VaccineHistory (DogID, VaccineDate, VaccineName, Quantity, Unit) VALUES 
(1, '2023-02-01', N'วัคซีนรวม 6 โรค', 1.00, N'dose'),
(2, '2022-06-15', N'วัคซีนพิษสุนัขบ้า', 1.00, N'dose');

-- เพิ่มข้อมูลตัวอย่างในตาราง ContestHistory
INSERT INTO ContestHistory (DogID, ContestDate, ContestName, ContestResult) VALUES 
(1, '2024-03-10', N'ประกวดสุนัขนานาชาติ', N'ชนะที่ 1');

-- แสดงข้อความยืนยันเมื่อสร้างฐานข้อมูลและตารางสำเร็จ
PRINT 'สร้างฐานข้อมูลและตารางสำเร็จ!';
GO

--___________________________________________________________________________________
-- เพิ่มคอลัมน์ BreedingID ในตาราง Dog โดยอนุญาต NULL
ALTER TABLE Dog
ADD BreedingID INT NULL;

-- เพิ่มคอนสเตรนต์ FOREIGN KEY
ALTER TABLE Dog
ADD CONSTRAINT FK_Dog_Breeding
FOREIGN KEY (BreedingID) REFERENCES Breeding(BreedingID);