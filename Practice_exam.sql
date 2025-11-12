-- ลบ Stored Procedure เดิม (ถ้ามี)
DROP PROCEDURE IF EXISTS GetCustomerCountries;
GO
DROP PROCEDURE IF EXISTS GetCustomerCitiesByCountry;
GO
DROP PROCEDURE IF EXISTS GetSalesByCategoryForCity;
GO
DROP PROCEDURE IF EXISTS GetProductDetailsByCategoryAndCity;
GO


EXEC GetSalesByCategoryForCity @City = 'Seattle';
GO
EXEC GetProductDetailsByCategoryAndCity @City = 'Seattle', @CategoryName = 'Seafood';
GO

-- สร้าง Stored Procedure ใหม่

-- 1. GetCustomerCountries
CREATE PROCEDURE GetCustomerCountries
AS
BEGIN
    SELECT DISTINCT Country
    FROM Customers
    ORDER BY Country;
END;
GO

-- 2. GetCustomerCitiesByCountry
CREATE PROCEDURE GetCustomerCitiesByCountry
    @Country NVARCHAR(50)
AS
BEGIN
    SELECT DISTINCT City
    FROM Customers
    WHERE Country = @Country
    ORDER BY City;
END;
GO

-- 3. GetSalesByCategoryForCity
CREATE PROCEDURE GetSalesByCategoryForCity
    @City NVARCHAR(50)
AS
BEGIN
    SELECT 
        c.CategoryID,
        c.CategoryName,
        SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)) AS TotalSale
    FROM 
        Categories c
        INNER JOIN Products p ON c.CategoryID = p.CategoryID
        INNER JOIN [Order Details] od ON p.ProductID = od.ProductID
        INNER JOIN Orders o ON od.OrderID = o.OrderID
        INNER JOIN Customers cust ON o.CustomerID = cust.CustomerID
    WHERE 
        cust.City = @City
    GROUP BY 
        c.CategoryID, c.CategoryName
    ORDER BY 
        TotalSale DESC;
END;
GO

-- 4. GetProductDetailsByCategoryAndCity
CREATE PROCEDURE GetProductDetailsByCategoryAndCity
    @City NVARCHAR(50),
    @CategoryName NVARCHAR(50)
AS
BEGIN
    SELECT 
        p.ProductID,
        p.ProductName,
        s.CompanyName,
        s.Country,
        SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)) AS TotalSale
    FROM 
        Products p
        INNER JOIN [Order Details] od ON p.ProductID = od.ProductID
        INNER JOIN Orders o ON od.OrderID = o.OrderID
        INNER JOIN Customers cust ON o.CustomerID = cust.CustomerID
        INNER JOIN Categories c ON p.CategoryID = c.CategoryID
        INNER JOIN Suppliers s ON p.SupplierID = s.SupplierID
    WHERE 
        cust.City = @City
        AND c.CategoryName = @CategoryName
    GROUP BY 
        p.ProductID, p.ProductName, s.CompanyName, s.Country
    ORDER BY 
        p.ProductID ASC, TotalSale DESC;
END;
GO

-- คำสั่งดูโครงสร้างตารางและข้อมูลตัวอย่าง 

-- 1. ตาราง Customers
-- โชว์โครงสร้างตาราง (คอลัมน์, ประเภทข้อมูล, ความยาว, ตำแหน่ง)
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, ORDINAL_POSITION
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Customers'
ORDER BY ORDINAL_POSITION;
GO

-- ข้อมูลตัวอย่าง (10 แถวแรก)
SELECT TOP 10 CustomerID, CompanyName, City, Country 
FROM Customers 
ORDER BY Country, City;
GO

-- 2. ตาราง Orders
-- โชว์โครงสร้างตาราง
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, ORDINAL_POSITION
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Orders'
ORDER BY ORDINAL_POSITION;
GO

-- ข้อมูลตัวอย่าง
SELECT TOP 10 OrderID, CustomerID, OrderDate 
FROM Orders 
ORDER BY OrderDate;
GO

-- 3. ตาราง [Order Details]
-- โชว์โครงสร้างตาราง
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, ORDINAL_POSITION
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = '[Order Details]'
ORDER BY ORDINAL_POSITION;
GO

-- ข้อมูลตัวอย่าง
SELECT TOP 10 OrderID, ProductID, Quantity, UnitPrice, Discount 
FROM [Order Details] 
ORDER BY OrderID;
GO

-- 4. ตาราง Products
-- โชว์โครงสร้างตาราง
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, ORDINAL_POSITION
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Products'
ORDER BY ORDINAL_POSITION;
GO

-- ข้อมูลตัวอย่าง
SELECT TOP 10 ProductID, ProductName, CategoryID, SupplierID 
FROM Products 
ORDER BY ProductID;
GO

-- 5. ตาราง Categories
-- โชว์โครงสร้างตาราง
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, ORDINAL_POSITION
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Categories'
ORDER BY ORDINAL_POSITION;
GO

-- ข้อมูลตัวอย่าง
SELECT TOP 10 CategoryID, CategoryName 
FROM Categories 
ORDER BY CategoryID;
GO

-- 6. ตาราง Suppliers
-- โชว์โครงสร้างตาราง
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, ORDINAL_POSITION
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Suppliers'
ORDER BY ORDINAL_POSITION;
GO

-- ข้อมูลตัวอย่าง
SELECT TOP 10 SupplierID, CompanyName, Country 
FROM Suppliers 
ORDER BY SupplierID;
GO

-- คำสั่งทดสอบข้อมูลดิบและ Stored Procedure

-- ตรวจสอบข้อมูลดิบสำหรับการคำนวณ TotalSale (ตัวอย่าง: Seattle, Seafood)
SELECT 
    c.CategoryName,
    p.ProductID,
    p.ProductName,
    od.Quantity,
    od.UnitPrice,
    od.Discount,
    (od.Quantity * od.UnitPrice * (1 - od.Discount)) AS LineTotal,
    o.OrderDate
FROM 
    [Order Details] od
    INNER JOIN Products p ON od.ProductID = p.ProductID
    INNER JOIN Categories c ON p.CategoryID = c.CategoryID
    INNER JOIN Orders o ON od.OrderID = o.OrderID
    INNER JOIN Customers cust ON o.CustomerID = cust.CustomerID
WHERE 
    cust.City = 'Seattle'
    AND c.CategoryName = 'Seafood'
ORDER BY p.ProductID, o.OrderDate;
GO

-- ทดสอบ Stored Procedure
EXEC GetSalesByCategoryForCity @City = 'Seattle';
GO
EXEC GetProductDetailsByCategoryAndCity @City = 'Seattle', @CategoryName = 'Seafood';
GO
EXEC GetCustomerCountries;
GO
EXEC GetCustomerCitiesByCountry @Country = 'USA';
GO
EXEC GetSalesByCategoryForCity @City = 'London';
GO
EXEC GetProductDetailsByCategoryAndCity @City = 'London', @CategoryName = 'Beverages';
GO