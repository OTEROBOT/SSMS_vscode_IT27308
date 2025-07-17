--17/7/2025/14:50

--จงแสดงรหัสสินค้าชื่อสินค้า และราคาสต่อหน่อย จำนวนที่สั่งซื้อ ราคารวมของสินค้าในใบสั่งซื้อหมามยเลข 10248
SELECT * FROM [Order Details] WHERE OrderID = 10248;
SELECT * FROM Products;

--ProductID
SELECT OD.ProductID, ProductName, OD.UnitPrice, Quantity,
        OD.UnitPrice * Quantity AS 'ราคารวม'
FROM [Order Details] As OD, Products P
WHERE OD.ProductID = P.ProductID
AND OrderID = 10248;

--จงแสดงรหัสสินค้า ชื่อสินค้า ราคาต่อหน่วย ชื่อประเภทสินค้า
SELECT * FROM Products
SELECT * FROM Categories;

--products
SELECT ProductID, ProductName, UnitPrice, CategoryName
FROM Products P, Categories C
WHERE P.CategoryID = C.CategoryID;

SELECT P.ProductID, P.ProductName, P.UnitPrice, C.CategoryName
FROM Products P
JOIN Categories C ON P.CategoryID = C.CategoryID;
