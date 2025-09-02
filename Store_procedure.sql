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