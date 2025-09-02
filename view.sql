CREATE VIEW Current_Products AS
SELECT ProductID, ProductName, UnitPrice, UnitsInStock
FROM Products
WHERE Discontinued = 0;

-----------------------------------------------------------------------------

SELECT *
From Current_Products
where UnitPrice > 50;

-----------------------------------------------------------------------------
CREATE VIEW ProductsByvolume AS
SELECT     P.ProductID, P.ProductName, SUM(OD.UnitPrice * OD.Quantity) AS TotalSales
FROM       Products AS P, [Order Details] AS OD, Orders AS O, Suppliers AS S
GROUP BY    P.ProductID, P.ProductName;

-----------------------------------------------------------------------------

CREATE VIEW ProductsByVolume AS
SELECT 
    P.ProductID, 
    P.ProductName, 
    OD.UnitPrice, 
    OD.Quantity, 
    O.OrderDate, 
    ShipCountry,
    S.Country AS SupplierCountry, 
    O.ShipCountry AS OrderCountry
FROM   Products AS P
INNER JOIN [Order Details] AS OD ON P.ProductID = OD.ProductID
INNER JOIN Orders AS O ON OD.OrderID = O.OrderID
INNER JOIN Suppliers AS S ON P.SupplierID = S.SupplierID;

GROUP BY P.ProductID, P.ProductName;


-----------------------------------------------------------------------------

ALTER VIEW ProductsByVolume AS
SELECT 
    P.ProductID, 
    P.ProductName, 
    OD.UnitPrice, 
    OD.Quantity, 
    O.OrderDate, 
    S.Country AS SupplierCountry, 
    O.ShipCountry
FROM   Products AS P
INNER JOIN [Order Details] AS OD ON P.ProductID = OD.ProductID
INNER JOIN Orders AS O ON OD.OrderID = O.OrderID
INNER JOIN Suppliers AS S ON P.SupplierID = S.SupplierID;


-----------------------------------------------------------------------------

SELECT 
    ProductID, 
    ProductName, 
    SUM(UnitPrice * Quantity) AS Sale_Volume
FROM ProductsByVolume
WHERE SupplierCountry = 'Japan' 
  AND YEAR(OrderDate) = 1997 
  AND ShipCountry = 'USA'
GROUP BY ProductID, ProductName;


-----------------------------------------------------------------------------

ALTER VIEW ProductsByVolume AS
SELECT 
    p.ProductID,
    p.ProductName,
    p.SupplierID,
    od.UnitPrice,
    od.Quantity,
    o.OrderDate,
    o.ShipCountry,
    s.Country AS SupplierCountry
FROM   Products AS p
INNER JOIN [Order Details] AS od ON p.ProductID = od.ProductID
INNER JOIN Orders AS o ON od.OrderID = o.OrderID
INNER JOIN Suppliers AS s ON p.SupplierID = s.SupplierID;


-----------------------------------------------------------------------------

SELECT * FROM ProductsByvolume

-----------------------------------------------------------------------------

DROP VIEW ProductsByvolume;

-----------------------------------------------------------------------------