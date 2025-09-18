CREATE PROCEDURE CountProductsByCategory AS
BEGIN
SELECT C.CategoryID, 
       C.CategoryName, 
       COUNT(P.ProductID) AS NumProduct
FROM Products AS P 
INNER JOIN Categories AS C ON P.CategoryID = C.CategoryID
GROUP BY C.CategoryID, C.CategoryName;
END

EXEC CountProductsByCategory;
--CountProductsByCategory ตัว s ไม่เหมือนชาวบ้าน
-------------------------------------------------------------------------------

CREATE PROCEDURE WorkShop8
    @CategoryID INT,
    @Year VARCHAR(15)
AS
BEGIN
    SELECT C.CustomerID, C.CompanyName, SUM(OD.UnitPrice * OD.Quantity) AS TotalSales
    FROM Customers AS C
    INNER JOIN Orders AS O ON C.CustomerID = O.CustomerID
    INNER JOIN [Order Details] AS OD ON O.OrderID = OD.OrderID
    INNER JOIN Products AS P ON OD.ProductID = P.ProductID
    INNER JOIN Categories AS CA ON P.CategoryID = CA.CategoryID
    WHERE CA.CategoryID = @CategoryID
      AND YEAR(O.OrderDate) = @Year
    GROUP BY C.CustomerID, C.CompanyName
END



EXEC WorkShop8 @CategoryID = 1, @Year = '1997';
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--แสดงข้อมูลรหัสพนักงาน ชื่อ+นามสกุล ตำแหน่งงาน ยอดขายรวมของสินค้ารหัส @productID
--จัดเรียงข้อมูลตามยอดขายสูงสุด

CREATE PROCEDURE dbo.WorkShop9_sp
    @ProductID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        E.EmployeeID,
        EmployeeName = CONCAT(E.FirstName, N' ', E.LastName),
        E.Title,
        TotalSales = SUM(OD.UnitPrice * OD.Quantity * (1 - OD.Discount))
    FROM dbo.Employees AS E
    INNER JOIN dbo.Orders AS O
        ON O.EmployeeID = E.EmployeeID
    INNER JOIN dbo.[Order Details] AS OD
        ON OD.OrderID = O.OrderID
    WHERE OD.ProductID = @ProductID
    GROUP BY
        E.EmployeeID,
        E.FirstName,
        E.LastName,
        E.Title
    ORDER BY
        TotalSales DESC;
END


EXEC dbo.WorkShop9_sp @ProductID = 1;


-------------------------------------------------------------------------------

CREATE PROCEDURE Proc_Customer_Orders
    @CustomerID nchar(5)
AS
BEGIN
    SELECT c.CustomerID, c.CompanyName, c.ContactName, c.ContactTitle,
           o.OrderID, o.OrderDate, o.ShipCountry,
           SUM(od.Quantity * od.UnitPrice) AS TotalOrder
    FROM Customers c
    INNER JOIN Orders o ON c.CustomerID = o.CustomerID
    INNER JOIN [Order Details] od ON o.OrderID = od.OrderID
    WHERE c.CustomerID = @CustomerID
    GROUP BY c.CustomerID, c.CompanyName, c.ContactName, c.ContactTitle,
             o.OrderID, o.OrderDate, o.ShipCountry
    ORDER BY o.OrderDate;
END;

EXEC Proc_Customer_Orders 'ALFKI';

EXEC Proc_Customer_Orders @CustomerID = 'ALFKI';

-------------------------------------------------------------------------------

--ของเตินร์

CREATE PROCEDURE Proc_Customer_Order
    @CustomerID NCHAR(5) = NULL
AS
BEGIN
    SELECT 
        YEAR(OrderDate) AS Year_Order,
        SUM(UnitPrice * Quantity) AS Sum_Order
    FROM 
        Orders AS O
        INNER JOIN [Order Details] AS OD ON O.[OrderID] = OD.[OrderID]
    WHERE 
        (@CustomerID IS NULL OR O.CustomerID = @CustomerID)
    GROUP BY 
        YEAR(OrderDate)
    ORDER BY 
        YEAR(OrderDate)
END

-------------------------------------------------------------------------------

--สร้างฐานข้อมูลใหม่ ชื่อ
CREATE DATABASE Company_DB;
GO
USE Company_DB;

CREATE TABLE Department (
    dept_id CHAR(3),
    dept_name NVARCHAR(30),
    dept_desc NVARCHAR(200),
    dept_phone VARCHAR(10),
    dept_email VARCHAR(60),
    CONSTRAINT PK_Dept PRIMARY KEY (dept_id)   
);
GO

INSERT INTO Department
VALUES('IT', 'Information Technology', '---', '021234567', 'it@udru.ac.th');

INSERT INTO Department(dept_id, dept_name)
VALUES('HR', 'Human Resource');

--------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE UpdateDepartment_SP
    @dept_id CHAR(3),    -- รหัสแผนกเดิม
    @id CHAR(3),         -- รหัสแผนกใหม่
    @dept_name NVARCHAR(30),
    @dept_desc NVARCHAR(200),
    @dept_phone VARCHAR(10),
    @dept_email VARCHAR(60)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- ตรวจสอบว่ารหัสเดิม (@dept_id) มีอยู่ในตารางหรือไม่
        IF NOT EXISTS (SELECT 1 FROM Department WHERE dept_id = @dept_id)
        BEGIN
            -- ถ้าไม่มีรหัสเดิม ให้ทำการ INSERT ข้อมูลใหม่
            INSERT INTO Department (dept_id, dept_name, dept_desc, dept_phone, dept_email)
            VALUES (@id, @dept_name, @dept_desc, @dept_phone, @dept_email);

            IF @@ROWCOUNT = 0
            BEGIN
                ROLLBACK TRANSACTION;
                RETURN -2; -- การเพิ่มข้อมูลล้มเหลว
            END
        END
        ELSE
        BEGIN
            -- ถ้ามีรหัสเดิม ตรวจสอบว่ารหัสใหม่ (@id) ซ้ำหรือไม่
            IF @dept_id <> @id AND EXISTS (SELECT 1 FROM Department WHERE dept_id = @id)
            BEGIN
                ROLLBACK TRANSACTION;
                RETURN -1; -- รหัสแผนกใหม่ซ้ำ
            END

            -- อัปเดตข้อมูล
            UPDATE Department
            SET dept_id = @id,
                dept_name = @dept_name,
                dept_desc = ISNULL(@dept_desc, dept_desc),
                dept_phone = ISNULL(@dept_phone, dept_phone),
                dept_email = ISNULL(@dept_email, dept_email)
            WHERE dept_id = @dept_id;

            IF @@ROWCOUNT = 0
            BEGIN
                ROLLBACK TRANSACTION;
                RETURN -2; -- ไม่พบรหัสแผนกเดิม หรืออัปเดตล้มเหลว
            END
        END

        COMMIT TRANSACTION;
        RETURN 1; -- ทำงานสำเร็จ (เพิ่มหรืออัปเดต)
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorNumber INT = ERROR_NUMBER();
        RAISERROR (@ErrorMessage, 16, 1);
        RETURN -3; -- ข้อผิดพลาดทั่วไป
    END CATCH
END;
GO
    







SELECT * FROM Department;

-------------------------------------------------------------------------------

INSERT INTO Department
VALUES('HR', 'Human Resource', '---', '0990683325', 'Hr@gmail.com')

SELECT * FROM Department;







-------------------------------------------------------------------------------


CREATE PROCEDURE InsertDepartment_SP
(
    -- ประกาศพารามิเตอร์
    @id CHAR(3),
    @name NVARCHAR(30),
    @desc NVARCHAR(200),
    @phone VARCHAR(10),
    @email VARCHAR(70)
)
AS
BEGIN
    BEGIN TRANSACTION -- เริ่มการทำงาน Transaction
        -- ตรวจสอบข้อมูลซ้ำก่อนเพิ่ม
        IF EXISTS (SELECT * FROM Department WHERE dept_id = @id)
        BEGIN
            -- กรณีพบรหัสซ้ำ
            ROLLBACK TRANSACTION -- ยกเลิก Transaction
            RETURN -1 -- ส่งค่ารหัสข้อผิดพลาด
        END
        ELSE
        BEGIN
            -- เพิ่มข้อมูลลงในตาราง
            INSERT INTO Department (dept_id, dept_name, dept_desc, dept_phone, dept_email)
            VALUES (@id, @name, @desc, @phone, @email)

            -- ตรวจสอบข้อผิดพลาด
            IF @@ERROR <> 0
            BEGIN
                ROLLBACK TRANSACTION -- ยกเลิก Transaction
                RETURN 0 -- ส่งค่ารหัสข้อผิดพลาด
            END
        END

    -- หากไม่มีข้อผิดพลาด ให้ยืนยันการทำงานของ Transaction
    COMMIT TRANSACTION
    RETURN 1 -- ส่งค่ารหัสสำเร็จ
END





EXEC InsertDepartment_SP
    @id = 'FIR',
    @name = 'Human Resource',
    @desc = '---',
    @phone = '1564898765',
    @email = 'Ohm@gmail.com'





SELECT * FROM Department





-------------------------------------------------------------------------------

DROP PROCEDURE UpdateDepartment_SP


CREATE PROCEDURE UpdateDepartment_SP
(
    -- ประกาศพารามิเตอร์
    @dept_id CHAR(3), -- รหัสแผนกเดิม
    @id CHAR(3), -- รหัสแผนกใหม่
    @name NVARCHAR(30), -- ชื่อแผนก
    @desc NVARCHAR(200), -- หมายเหตุ
    @phone VARCHAR(10), -- โทรศัพท์
    @email VARCHAR(70) -- อีเมล
)
AS
BEGIN
    BEGIN TRANSACTION -- เริ่มการทำงาน Transaction
        -- ตรวจสอบว่ารหัสใหม่ซ้ำหรือไม่ (ถ้าเปลี่ยนรหัส)
        IF @dept_id <> @id AND EXISTS (SELECT * FROM Department WHERE dept_id = @id)
        BEGIN
            ROLLBACK TRANSACTION -- ยกเลิก Transaction
            RETURN -1 -- ส่งค่ารหัสข้อผิดพลาด (รหัสซ้ำ)
        END
        ELSE
        BEGIN
            -- อัปเดตข้อมูลในตาราง
            UPDATE Department
            SET dept_id = @id,
                dept_name = @name,
                dept_desc = @desc,
                dept_phone = @phone,
                dept_email = @email
            WHERE dept_id = @dept_id

            -- ตรวจสอบข้อผิดพลาด
            IF @@ERROR <> 0
            BEGIN
                ROLLBACK TRANSACTION -- ยกเลิก Transaction
                RETURN 0 -- ส่งค่ารหัสข้อผิดพลาด
            END
        END

    -- หากไม่มีข้อผิดพลาด ให้ยืนยันการทำงานของ Transaction
    COMMIT TRANSACTION
    RETURN 1 -- ส่งค่ารหัสสำเร็จ
END

-------------------------------------------------------------------------------

-------------------------------------------------------------------------------

-------------------------------------------------------------------------------

-------------------------------------------------------------------------------

-------------------------------------------------------------------------------