--Student ID 66040233110
--Student Name นาย ยศวริศ อาจนนท์ลา

-- *********แบบฝึกหัด Query ครั้งที่ 3***************

 -- ***** Select From Multi-table *******
 --1. จงแสดงรหัสสินค้า ชื่อสินค้า ราคาต่อหน่วย เฉพาะสินค้าประเภท Seafood

 --แบบ Product
 SELECT     ProductID, ProductName, UnitPrice
 FROM       Products As P , Categories As C
 WHERE      P.CategoryID = C.CategoryID AND CategoryName = 'Seafood';

--แบบ Join
SELECT      *
FROM        Products AS P INNER JOIN Categories AS C ON 
                P.CategoryID = C.CategoryID
WHERE       C.CategoryName = 'Seafood';

---------------------------------------------------------------------
--2.จงแสดงชื่อบริษัทลูกค้า ประเทศที่ลูกค้าอยู่ และจำนวนใบสั่งซื้อที่ลูกค้านั้น ๆ ที่รายการสั่งซื้อในปี 1997

--แบบ Product
SELECT     C.CompanyName, C.Country, COUNT(O.OrderID) AS OrderCount
FROM       Customers As C , Orders As O
WHERE      C.CustomerID = O.CustomerID AND YEAR(O.OrderDate) = 1997
GROUP BY   C.CompanyName, C.Country;

--แบบ Join
SELECT     C.CompanyName, C.Country, COUNT(O.OrderID) AS OrderCount
FROM       Customers AS C INNER JOIN Orders AS O ON C.CustomerID = O.CustomerID
WHERE      YEAR(O.OrderDate) = 1997
GROUP BY   C.CompanyName, C.Country;

---------------------------------------------------------------------
--3. จงแสดงรหัสสินค้า ชื่อสินค้า ราคาต่อหน่วย ชื่อบริษัทและประเทศที่จัดจำหน่ายสินค้านั้น ๆ

--แบบ Product
SELECT     P.ProductID, P.ProductName, P.UnitPrice, S.CompanyName, S.Country
FROM       Products AS P, Suppliers AS S
WHERE      P.SupplierID = S.SupplierID;

--แบบ Join
SELECT     P.ProductID, P.ProductName, P.UnitPrice, S.CompanyName, S.Country
FROM       Products AS P INNER JOIN Suppliers AS S ON P.SupplierID = S.SupplierID;


---------------------------------------------------------------------
--4. ชื่อ-นามสกุลของพนักงานขาย ตำแหน่งงาน และจำนวนใบสั่งซื้อที่แต่ละคนเป็นผู้ทำรายการขาย 
--เฉพาะที่ทำรายการขายช่วงเดือนมกราคม-เมษายน ปี 1997 และแสดงเฉพาะพนักงานที่ทำรายการขายมากกว่า 10 ใบสั่งซื้อ

--แบบ Product
SELECT     E.FirstName, E.LastName, E.Title, COUNT(O.OrderID) AS OrderCount
FROM       Employees AS E, Orders AS O
WHERE      E.EmployeeID = O.EmployeeID AND 
           MONTH(O.OrderDate) BETWEEN 1 AND 4 AND YEAR(O.OrderDate) = 1997
GROUP BY   E.FirstName, E.LastName, E.Title
HAVING     COUNT(O.OrderID) > 10;

--แบบ Join
SELECT     E.FirstName, E.LastName, E.Title, COUNT(O.OrderID) AS OrderCount
FROM       Employees AS E INNER JOIN Orders AS O ON E.EmployeeID = O.EmployeeID
WHERE      MONTH(O.OrderDate) BETWEEN 1 AND 4 AND YEAR(O.OrderDate) = 1997
GROUP BY   E.FirstName, E.LastName, E.Title
HAVING     COUNT(O.OrderID) > 10;

---------------------------------------------------------------------
--5.จงแสดงรหัสสินค้า ชื่อสินค้า ยอดขายรวม(ไม่คิดส่วนลด) ของสินค้าแต่ละชนิด

--แบบ Product
SELECT     P.ProductID, P.ProductName, SUM(OD.UnitPrice * OD.Quantity) AS SumPrice
FROM       Products AS P, [Order Details] AS OD
WHERE      P.ProductID = OD.ProductID
GROUP BY   P.ProductID, P.ProductName;

--แบบ Join
SELECT     P.ProductID, P.ProductName, SUM(OD.UnitPrice * OD.Quantity) AS SumPrice
FROM       Products AS P INNER JOIN [Order Details] AS OD ON P.ProductID = OD.ProductID
GROUP BY   P.ProductID, P.ProductName;

---------------------------------------------------------------------
--6.จงแสดงรหัสบริษัทจัดส่ง ชื่อบริษัทจัดส่ง จำนวนใบสั่งซื้อที่จัดส่งไปยังประเทศสหรัฐอเมริกา, 
--อิตาลี, สหราชอาณาจักร, แคนาดา ในเดือนมกราคม-สิงหาคม ปี 1997 

--แบบ Product
SELECT     S.ShipperID, S.CompanyName, COUNT(O.OrderID) AS OrderCount
FROM       Shippers AS S, Orders AS O
WHERE      S.ShipperID = O.ShipVia AND 
           O.ShipCountry IN ('USA', 'Italy', 'UK', 'Canada') AND 
           MONTH(O.OrderDate) BETWEEN 1 AND 8 AND YEAR(O.OrderDate) = 1997
GROUP BY   S.ShipperID, S.CompanyName;

--แบบ Join
SELECT     S.ShipperID, S.CompanyName, COUNT(O.OrderID) AS OrderCount
FROM       Shippers AS S INNER JOIN Orders AS O ON S.ShipperID = O.ShipVia
WHERE      O.ShipCountry IN ('USA', 'Italy', 'UK', 'Canada') AND 
           MONTH(O.OrderDate) BETWEEN 1 AND 8 AND YEAR(O.OrderDate) = 1997
GROUP BY   S.ShipperID, S.CompanyName;


---------------------------------------------------------------------
-- *** 3 ตาราง ****
/*7 : จงแสดงเลขเดือน ยอดสั่งซื้อรวม(ไม่คิดส่วนลด) เฉพาะรายการสั่งซื้อที่ทำรายการขายในปี 1996 
และจัดส่งไปยังประเทศสหราชอาณาจักร,เบลเยี่ยม, โปรตุเกส */
--**แบบ Product**--

SELECT MONTH(O.OrderDate) AS Month, 
       SUM(OD.UnitPrice * OD.Quantity) AS TotalSales
FROM [Order Details] AS OD, Orders AS O
WHERE OD.OrderID = O.OrderID 
  AND O.ShipCountry IN ('UK', 'Belgium', 'Portugal') 
  AND YEAR(O.OrderDate) = 1996
GROUP BY MONTH(O.OrderDate);


--**แบบ Join**--
SELECT MONTH(O.OrderDate) AS Month, 
       SUM(OD.UnitPrice * OD.Quantity) AS TotalSales
FROM Orders AS O 
INNER JOIN [Order Details] AS OD ON O.OrderID = OD.OrderID
WHERE O.ShipCountry IN ('UK', 'Belgium', 'Portugal') 
  AND YEAR(O.OrderDate) = 1996
GROUP BY MONTH(O.OrderDate);


--------------------------------------------------------------------------------

/*8 : จงแสดงข้อมูลรหัสลูกค้า ชื่อบริษัทลูกค้า และยอดรวม(ไม่คิดส่วนลด) เฉพาะใบสั่งซื้อที่ทำรายการสั่งซื้อในเดือน มค. ปี 1997 
จัดเรียงข้อมูลตามยอดสั่งซื้อมากไปหาน้อย*/
--แบบ Product
SELECT     C.CustomerID, C.CompanyName, SUM(OD.UnitPrice * OD.Quantity) AS TotalSales
FROM       Customers AS C, Orders AS O, [Order Details] AS OD
WHERE      C.CustomerID = O.CustomerID 
  AND O.OrderID = OD.OrderID 
  AND MONTH(O.OrderDate) = 1 
  AND YEAR(O.OrderDate) = 1997
GROUP BY   C.CustomerID, C.CompanyName
ORDER BY   TotalSales DESC;



--แบบ Join
SELECT     C.CustomerID, C.CompanyName, SUM(OD.UnitPrice * OD.Quantity) AS TotalSales
FROM       Customers AS C INNER JOIN Orders AS O ON C.CustomerID = O.CustomerID
INNER JOIN [Order Details] AS OD ON O.OrderID = OD.OrderID
WHERE      MONTH(O.OrderDate) = 1 AND YEAR(O.OrderDate) = 1997
GROUP BY   C.CustomerID, C.CompanyName
ORDER BY   TotalSales DESC;


---------------------------------------------------------------------------------

/*9 : จงแสดงรหัสผู้จัดส่ง ชื่อบริษัทผู้จัดส่ง ยอดรวมค่าจัดส่ง เฉพาะรายการสั่งซื้อที่ Nancy Davolio เป็นผู้ทำรายการขาย*/
--แบบ Product


--แบบ Join


---------------------------------------------------------------------------------
/*10 : จงแสดงข้อมูลรหัสใบสั่งซื้อ วันที่สั่งซื้อ รหัสลูกค้าที่สั่งซื้อ ประเทศที่จัดส่ง จำนวนที่สั่งซื้อทั้งหมด ของสินค้าชื่อ Tofu ในช่วงปี 1997*/
--แบบ Product


--แบบ Join

-----------------------------------------------------------------------------
/*11 : จงแสดงข้อมูลรหัสสินค้า ชื่อสินค้า ยอดขายรวม(ไม่คิดส่วนลด) ของสินค้าแต่ละรายการเฉพาะที่มีการสั่งซื้อในเดือน มค.-สค. ปี 1997*/
--แบบ Product


--แบบ Join

-----------------------------------------------------------------------------
-- *** 4 ตาราง ****
/*12 : จงแสดงข้อมูลรหัสประเภทสินค้า ชื่อประเภทสินค้า ยอดสั่งซื้อรวม(ไม่คิดส่วนลด) เฉพาะที่มีการจัดส่งไปประเทศสหรัฐอเมริกา ในปี 1997*/
--แบบ Product


--แบบ Join

----------------------------------------------------------------------------
/*13 : จงแสดงรหัสพนักงาน ชื่อและนามสกุล(แสดงในคอลัมน์เดียวกัน) ยอดขายรวมของพนักงานแต่ละคน เฉพาะรายการขายที่จัดส่งโดยบริษัท Speedy Express 
ไปยังประเทศสหรัฐอเมริกา และทำการสั่งซื้อในปี 1997 */
--แบบ Product


--แบบ Join

--------------------------------------------------------------------------
/*14 : จงแสดงรหัสสินค้า ชื่อสินค้า ยอดขายรวม เฉพาะสินค้าที่นำมาจัดจำหน่ายจากประเทศญี่ปุ่น และมีการสั่งซื้อในปี 1997 และจัดส่งไปยังประเทศสหรัฐอเมริกา */
--แบบ Product
SELECT     P.ProductID, P.ProductName, SUM(OD.UnitPrice * OD.Quantity) AS TotalSales
FROM       Products AS P, [Order Details] AS OD, Orders AS O, Suppliers AS S
WHERE      P.ProductID = OD.ProductID 
  AND OD.OrderID = O.OrderID 
  AND P.SupplierID = S.SupplierID 
  AND S.Country = 'Japan' 
  AND YEAR(O.OrderDate) = 1997 
  AND O.ShipCountry = 'USA'
  GROUP BY P.ProductID, P.ProductName;


--แบบ Join
SELECT     P.ProductID, P.ProductName, SUM(OD.UnitPrice * OD.Quantity) AS TotalSales
FROM       Products AS P
INNER JOIN [Order Details] AS OD ON P.ProductID = OD.ProductID
INNER JOIN Orders AS O ON OD.OrderID = O.OrderID
INNER JOIN Suppliers AS S ON P.SupplierID = S.SupplierID
WHERE      S.Country = 'Japan' 
  AND YEAR(O.OrderDate) = 1997 
  AND O.ShipCountry = 'USA'
GROUP BY   P.ProductID, P.ProductName;



----------------------------------------------------------------------------
-- *** 5 ตาราง ***
/*15 : จงแสดงรหัสลูกค้า ชื่อบริษัทลูกค้า ยอดสั่งซื้อรวมของการสั่งซื้อสินค้าประเภท Beverages ของลูกค้าแต่ละบริษัท  และสั่งซื้อในปี 1997 จัดเรียงตามยอดสั่งซื้อจากมากไปหาน้อย*/
--แบบ Product
SELECT     C.CustomerID, C.CompanyName, SUM(OD.UnitPrice * OD.Quantity) AS TotalSales
FROM       Customers AS C, Orders AS O, [Order Details] AS OD, Products AS P, Categories AS CA
WHERE      C.CustomerID = O.CustomerID 
  AND O.OrderID = OD.OrderID 
  AND OD.ProductID = P.ProductID 
  AND P.CategoryID = CA.CategoryID 
  AND CA.CategoryName = 'Beverages' 
  AND YEAR(O.OrderDate) = 1997


--แบบ Join
SELECT     C.CustomerID, C.CompanyName, SUM(OD.UnitPrice * OD.Quantity) AS TotalSales
FROM       Customers AS C
                          INNER JOIN Orders           AS O  ON C.CustomerID = O.CustomerID
                          INNER JOIN [Order Details]  AS OD ON O.OrderID    = OD.OrderID
                          INNER JOIN Products         AS P  ON OD.ProductID = P.ProductID
                          INNER JOIN Categories       AS CA ON P.CategoryID = CA.CategoryID
WHERE      CA.CategoryName = 'Beverages' 
                          AND YEAR(O.OrderDate) = 1997
GROUP BY   C.CustomerID, C.CompanyName



---------------------------------------------------------------------------
/*16 : จงแสดงรหัสผู้จัดส่ง ชื่อบริษัทที่จัดส่ง จำนวนใบสั่งซื้อที่จัดส่งสินค้าประเภท Seafood ไปยังประเทศสหรัฐอเมริกา ในปี 1997 */
--แบบ Product


--แบบ Join

---------------------------------------------------------------------------
-- *** 6 ตาราง ***
/*17 : จงแสดงรหัสประเภทสินค้า ชื่อประเภท ยอดสั่งซื้อรวม(ไม่คิดส่วนลด) ที่ทำรายการขายโดย Margaret Peacock ในปี 1997 
และสั่งซื้อโดยลูกค้าที่อาศัยอยู่ในประเทศสหรัฐอเมริกา สหราชอาณาจักร แคนาดา */

--แบบ Product


--แบบ Join

---------------------------------------------------------------------------
/*18 : จงแสดงรหัสสินค้า ชื่อสินค้า ยอดสั่งซื้อรวม(ไม่คิดส่วนลด) ของสินค้าที่จัดจำหน่ายโดยบริษัทที่อยู่ประเทศสหรัฐอเมริกา ที่มีการสั่งซื้อในปี 1997 
จากลูกค้าที่อาศัยอยู่ในประเทศสหรัฐอเมริกา และทำการขายโดยพนักงานที่อาศัยอยู่ในประเทศสหรัฐอเมริกา */

--แบบ Product


--แบบ Join


---------------------------------------------------------------------------