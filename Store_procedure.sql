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