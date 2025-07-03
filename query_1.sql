--- ****  Workshop Basic Query 1 **** ---

--1. แสดงข้อมูลทั้งหมดของพนักงานทุกรายการ
SELECT * FROM Employees;

--2. แสดงข้อมูลทั้งหมดของสินค้าทุกรายการ
SELECT * FROM Products;

--3. แสดงข้อมูลใบสั่งซื้อทุกรายการ
SELECT * FROM Orders;

--4. แสดงข้อมูลทั้งหมดของลูกค้าทุกรายการ
SELECT * FROM Customers;

--5. แสดงข้อมูลรหัสสินค้า ชื่อสินค้า ราคาต่อหน่วย จำนวนคงเหลือ ของสินค้าทุกรายการ
SELECT ProductID, ProductName, UnitPrice, UnitsInStock FROM Products;

--6. แสดงข้อมูลรหัสลูกค้า ชื่อบริษัทลูกค้า ชื่อผู้ติดต่อ ชื่อประเทศของลูกค้าทั้งหมด
SELECT CustomerID, CompanyName, ContactName, Country FROM Customers;

--7. แสดงข้อมูลรหัสพนักงาน ชื่อ นามสกุล  ตำแหน่งงานของพนักงานทั้งหมด
SELECT EmployeeID, FirstName, LastName, Title FROM Employees;

--8. แสดงข้อมูลลูกค้าที่อยู่ในประเทศสหรัฐอเมริกา
SELECT * FROM Customers WHERE Country = 'USA';

--9. แสดงข้อมูลสินค้าที่มีราคาต่อหน่วยไม่เกิน $50
SELECT * FROM Products WHERE UnitPrice <= 50;

--10. แสดงข้อมูลสินค้าที่จัดจำหน่วยโดยบริษัทรหัส 1 และเป็นประเภทสินค้า รหัส 1
SELECT * FROM Products WHERE SupplierID = 1 AND CategoryID = 1;

--11. แสดงข้อมูลสินค้าที่มีราคาต่อหน่วยอยู่ในช่วง $10-$30
SELECT * FROM Products WHERE UnitPrice BETWEEN 10 AND 30;

--12. จงแสดงใบสั่งซื้อที่มีการสั่งซื้อในช่วงวันที่ 1 มค. 1997 - 31 สค. 1997
SELECT * FROM Orders WHERE OrderDate BETWEEN '1997-01-01' AND '1997-08-31';

--13. แสดงข้อมูลรหัสลูกค้า ชื่อบริษัท ชื่อเมือง ชื่อประเทศ ของลูกค้าที่อยู่ในประเทเบลเยี่ยม อิตาลี โปร์แลนด์
SELECT CustomerID, CompanyName, City, Country 
FROM Customers
WHERE Country IN ('Belgium', 'Italy', 'Poland');

--14. จงแสดงข้อมูลใบสั่งซื้อที่สั่งซื้อใน ปี 1997 และจัดส่งไปยังประเทศสหรัฐอเมริกา สหราชอาณาจักร สวิสเซอร์แลนด์
SELECT * FROM Orders 
WHERE YEAR(OrderDate) = 1997
AND ShipCountry IN ('USA', 'UK', 'Switzerland');

--15. แสดงรหัสลูกค้า ชื่อบริษัท ชื่อประเทศ เฉพาะลูกค้าที่มีชื่อบริษัทขึ้นต้นด้วยอักษร A
SELECT CustomerID, CompanyName, Country 
FROM Customers
WHERE CompanyName LIKE 'A%';

--16. แสดงรหัสลูกค้า ชื่อบริษัท ชื่อประเทศ เฉพาะลูกค้าที่มีชื่อบริษัทมีคำว่า the ภายในชื่อ
SELECT CustomerID, CompanyName, Country 
FROM Customers
WHERE CompanyName LIKE '%the%';

--17. แสดงรหัสลูกค้า ชื่อบริษัท ชื่อประเทศ เฉพาะลูกค้าที่มีชื่อบริษัทขึ้นต้นด้วยอักษร F ลงท้าย n
SELECT CustomerID, CompanyName, Country 
FROM Customers  
WHERE CompanyName LIKE 'F%n';

--18. แสดงรหัสลูกค้า ชื่อบริษัท ชื่อประเทศ เฉพาะลูกค้าที่มีชื่อบริษัทขึ้นต้นด้วยอักษร A หรือ F หรือ S ลงท้ายด้วย n
SELECT CustomerID, CompanyName, Country 
FROM Customers  
WHERE (CompanyName LIKE 'A%n' OR CompanyName LIKE 'F%n' OR CompanyName LIKE 'S%n');

--19. แสดงรหัสลูกค้า ชื่อบริษัท ชื่อประเทศ เฉพาะลูกค้าที่มีชื่อบริษัทยาว 20 ตัวอักษร 
SELECT CustomerID, CompanyName, Country 
FROM Customers
WHERE LEN(CompanyName) = 20;

--20. แสดงรหัสลูกค้า ชื่อบริษัท ชื่อประเทศ เฉพาะลูกค้าที่มีชื่อบริษัทไม่ได้ขึ้นต้นชื่อด้วยอักษร T หรือ W หรือ D
SELECT CustomerID, CompanyName, Country 
FROM Customers
WHERE CompanyName NOT LIKE 'T%' AND CompanyName NOT LIKE 'W%' AND CompanyName NOT LIKE 'D%';





