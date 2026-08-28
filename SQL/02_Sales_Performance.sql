/*
===========================================================
PROJECT: NORTHWIND SALES & CUSTOMER PERFORMANCE ANALYSIS
FILE: 02_Sales_Performance.sql
PURPOSE:
Validate table relationships and establish the core
sales/revenue metrics for the analysis.
===========================================================
*/

USE northwind_sales_analysis;


-- =========================================================
-- 1. ORDER → CUSTOMER RELATIONSHIP CHECK
-- =========================================================

SELECT
    COUNT(*) AS `Orders_Without_Customer`
FROM orders o
LEFT JOIN customers c
    ON o.CustomerID = c.CustomerID
WHERE c.CustomerID IS NULL;


-- =========================================================
-- 2. ORDER → EMPLOYEE RELATIONSHIP CHECK
-- =========================================================

SELECT
    COUNT(*) AS `Orders_Without_Employee`
FROM orders o
LEFT JOIN employees e
    ON o.EmployeeID = e.EmployeeID
WHERE e.EmployeeID IS NULL;


-- =========================================================
-- 3. ORDER → SHIPPER RELATIONSHIP CHECK
-- =========================================================

SELECT
    COUNT(*) AS `Orders_Without_Shipper`
FROM orders o
LEFT JOIN shippers s
    ON o.ShipVia = s.ShipperID
WHERE s.ShipperID IS NULL;


-- =========================================================
-- 4. ORDER DETAILS → ORDERS RELATIONSHIP CHECK
-- =========================================================

SELECT
    COUNT(*) AS `Details_Without_Order`
FROM order_details od
LEFT JOIN orders o
    ON od.OrderID = o.OrderID
WHERE o.OrderID IS NULL;


-- =========================================================
-- 5. ORDER DETAILS → PRODUCTS RELATIONSHIP CHECK
-- =========================================================

SELECT
    COUNT(*) AS `Details_Without_Product`
FROM order_details od
LEFT JOIN products p
    ON od.ProductID = p.ProductID
WHERE p.ProductID IS NULL;


-- =========================================================
-- 6. PRODUCTS → CATEGORIES RELATIONSHIP CHECK
-- =========================================================

SELECT
    COUNT(*) AS `Products_Without_Category`
FROM products p
LEFT JOIN categories c
    ON p.CategoryID = c.CategoryID
WHERE c.CategoryID IS NULL;


-- =========================================================
-- 7. CORE SALES DATASET
-- =========================================================

SELECT

    o.OrderID,
    o.OrderDate,

    c.CustomerID,
    c.CompanyName AS `Customer_Name`,
    c.Country AS `Customer_Country`,

    e.EmployeeID,
    CONCAT(
        e.FirstName,
        ' ',
        e.LastName
    ) AS `Employee_Name`,

    p.ProductID,
    p.ProductName,

    cat.CategoryID,
    cat.CategoryName,

    od.UnitPrice,
    od.Quantity,
    od.Discount,

    ROUND(
        od.UnitPrice * od.Quantity,
        2
    ) AS `Gross_Sales`,

    ROUND(
        od.UnitPrice * od.Quantity * (1 - od.Discount),
        2
    ) AS `Net_Sales`

FROM orders o

INNER JOIN customers c
    ON o.CustomerID = c.CustomerID

INNER JOIN employees e
    ON o.EmployeeID = e.EmployeeID

INNER JOIN order_details od
    ON o.OrderID = od.OrderID

INNER JOIN products p
    ON od.ProductID = p.ProductID

INNER JOIN categories cat
    ON p.CategoryID = cat.CategoryID;


-- =========================================================
-- 8. TOTAL SALES PERFORMANCE
-- =========================================================

SELECT

    COUNT(DISTINCT o.OrderID) AS `Total_Orders`,

    SUM(od.Quantity) AS `Total_Units_Sold`,

    ROUND(
        SUM(
            od.UnitPrice * od.Quantity * (1 - od.Discount)
        ),
        2
    ) AS `Total_Revenue`,

    ROUND(
        SUM(
            od.UnitPrice * od.Quantity * (1 - od.Discount)
        )
        /
        COUNT(DISTINCT o.OrderID),
        2
    ) AS `Average_Order_Value`

FROM orders o

INNER JOIN order_details od
    ON o.OrderID = od.OrderID;


-- =========================================================
-- 9. SALES PERFORMANCE BY YEAR
-- =========================================================

SELECT

    YEAR(o.OrderDate) AS `Sales_Year`,

    COUNT(DISTINCT o.OrderID) AS `Total_Orders`,

    SUM(od.Quantity) AS `Units_Sold`,

    ROUND(
        SUM(
            od.UnitPrice * od.Quantity * (1 - od.Discount)
        ),
        2
    ) AS `Total_Revenue`

FROM orders o

INNER JOIN order_details od
    ON o.OrderID = od.OrderID

GROUP BY YEAR(o.OrderDate)

ORDER BY Sales_Year;


-- =========================================================
-- 10. MONTHLY SALES PERFORMANCE
-- =========================================================

SELECT

    YEAR(o.OrderDate) AS `Sales_Year`,

    MONTH(o.OrderDate) AS `Sales_Month`,

    MONTHNAME(o.OrderDate) AS `Month_Name`,

    COUNT(DISTINCT o.OrderID) AS `Total_Orders`,

    SUM(od.Quantity) AS `Units_Sold`,

    ROUND(
        SUM(
            od.UnitPrice * od.Quantity * (1 - od.Discount)
        ),
        2
    ) AS `Total_Revenue`

FROM orders o

INNER JOIN order_details od
    ON o.OrderID = od.OrderID

GROUP BY
    YEAR(o.OrderDate),
    MONTH(o.OrderDate),
    MONTHNAME(o.OrderDate)

ORDER BY
    Sales_Year,
    Sales_Month;


-- =========================================================
-- 11. REVENUE BY CATEGORY
-- =========================================================

SELECT

    cat.CategoryName AS `Category`,

    SUM(od.Quantity) AS `Units_Sold`,

    COUNT(DISTINCT o.OrderID) AS `Orders`,

    ROUND(
        SUM(
            od.UnitPrice * od.Quantity * (1 - od.Discount)
        ),
        2
    ) AS `Revenue`

FROM orders o

INNER JOIN order_details od
    ON o.OrderID = od.OrderID

INNER JOIN products p
    ON od.ProductID = p.ProductID

INNER JOIN categories cat
    ON p.CategoryID = cat.CategoryID

GROUP BY cat.CategoryName

ORDER BY Revenue DESC;


-- =========================================================
-- 12. TOP 10 PRODUCTS BY REVENUE
-- =========================================================

SELECT

    p.ProductName AS `Product`,

    cat.CategoryName AS `Category`,

    SUM(od.Quantity) AS `Units_Sold`,

    ROUND(
        SUM(
            od.UnitPrice * od.Quantity * (1 - od.Discount)
        ),
        2
    ) AS `Revenue`

FROM order_details od

INNER JOIN products p
    ON od.ProductID = p.ProductID

INNER JOIN categories cat
    ON p.CategoryID = cat.CategoryID

GROUP BY
    p.ProductID,
    p.ProductName,
    cat.CategoryName

ORDER BY Revenue DESC

LIMIT 10;