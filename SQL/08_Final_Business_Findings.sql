USE northwind_sales_analysis;


-- =========================================================
-- 1. OVERALL BUSINESS PERFORMANCE
-- =========================================================

SELECT

    COUNT(DISTINCT o.OrderID) AS `Total_Orders`,

    COUNT(DISTINCT o.CustomerID) AS `Active_Customers`,

    COUNT(DISTINCT od.ProductID) AS `Products_Sold`,

    COUNT(DISTINCT o.EmployeeID) AS `Active_Employees`,

    SUM(od.Quantity) AS `Units_Sold`,

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
-- 2. YEARLY PERFORMANCE
-- =========================================================

SELECT

    YEAR(o.OrderDate) AS `Sales_Year`,

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

GROUP BY YEAR(o.OrderDate)

ORDER BY Sales_Year;


-- =========================================================
-- 3. MONTHLY PERFORMANCE
-- =========================================================

SELECT

    DATE_FORMAT(o.OrderDate, '%Y-%m') AS `Sales_Month`,

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

GROUP BY DATE_FORMAT(o.OrderDate, '%Y-%m')

ORDER BY Sales_Month;


-- =========================================================
-- 4. TOP 10 CUSTOMERS
-- =========================================================

SELECT

    c.CustomerID,

    c.CompanyName AS `Customer_Name`,

    c.Country,

    COUNT(DISTINCT o.OrderID) AS `Orders`,

    ROUND(
        SUM(
            od.UnitPrice * od.Quantity * (1 - od.Discount)
        ),
        2
    ) AS `Revenue`

FROM customers c

INNER JOIN orders o
    ON c.CustomerID = o.CustomerID

INNER JOIN order_details od
    ON o.OrderID = od.OrderID

GROUP BY

    c.CustomerID,
    c.CompanyName,
    c.Country

ORDER BY Revenue DESC

LIMIT 10;


-- =========================================================
-- 5. TOP 10 PRODUCTS
-- =========================================================

SELECT

    p.ProductID,

    p.ProductName,

    cat.CategoryName AS `Category`,

    SUM(od.Quantity) AS `Units_Sold`,

    ROUND(
        SUM(
            od.UnitPrice * od.Quantity * (1 - od.Discount)
        ),
        2
    ) AS `Revenue`

FROM products p

INNER JOIN order_details od
    ON p.ProductID = od.ProductID

INNER JOIN categories cat
    ON p.CategoryID = cat.CategoryID

GROUP BY

    p.ProductID,
    p.ProductName,
    cat.CategoryName

ORDER BY Revenue DESC

LIMIT 10;


-- =========================================================
-- 6. CATEGORY PERFORMANCE
-- =========================================================

SELECT

    cat.CategoryName AS `Category`,

    COUNT(DISTINCT p.ProductID) AS `Products`,

    SUM(od.Quantity) AS `Units_Sold`,

    ROUND(
        SUM(
            od.UnitPrice * od.Quantity * (1 - od.Discount)
        ),
        2
    ) AS `Revenue`

FROM categories cat

INNER JOIN products p
    ON cat.CategoryID = p.CategoryID

INNER JOIN order_details od
    ON p.ProductID = od.ProductID

GROUP BY

    cat.CategoryID,
    cat.CategoryName

ORDER BY Revenue DESC;


-- =========================================================
-- 7. EMPLOYEE PERFORMANCE
-- =========================================================

SELECT

    e.EmployeeID,

    e.employeeName AS `Employee_Name`,

    COUNT(DISTINCT o.OrderID) AS `Orders`,

    SUM(od.Quantity) AS `Units_Sold`,

    ROUND(
        SUM(
            od.UnitPrice * od.Quantity * (1 - od.Discount)
        ),
        2
    ) AS `Revenue`

FROM employees e

INNER JOIN orders o
    ON e.EmployeeID = o.EmployeeID

INNER JOIN order_details od
    ON o.OrderID = od.OrderID

GROUP BY

    e.EmployeeID,
    e.employeeName

ORDER BY Revenue DESC;


-- =========================================================
-- 8. COUNTRY PERFORMANCE
-- =========================================================

SELECT

    c.Country,

    COUNT(DISTINCT o.OrderID) AS `Orders`,

    COUNT(DISTINCT c.CustomerID) AS `Customers`,

    ROUND(
        SUM(
            od.UnitPrice * od.Quantity * (1 - od.Discount)
        ),
        2
    ) AS `Revenue`

FROM customers c

INNER JOIN orders o
    ON c.CustomerID = o.CustomerID

INNER JOIN order_details od
    ON o.OrderID = od.OrderID

GROUP BY c.Country

ORDER BY Revenue DESC;


-- =========================================================
-- 9. REPEAT CUSTOMER ANALYSIS
-- =========================================================

WITH CustomerOrders AS
(
    SELECT

        c.CustomerID,

        c.CompanyName AS `Customer_Name`,

        COUNT(DISTINCT o.OrderID) AS `Orders`

    FROM customers c

    INNER JOIN orders o
        ON c.CustomerID = o.CustomerID

    GROUP BY

        c.CustomerID,
        c.CompanyName
)

SELECT

    COUNT(*) AS `Active_Customers`,

    SUM(
        CASE
            WHEN Orders > 1 THEN 1
            ELSE 0
        END
    ) AS `Repeat_Customers`,

    ROUND(
        SUM(
            CASE
                WHEN Orders > 1 THEN 1
                ELSE 0
            END
        )
        /
        COUNT(*) * 100,
        1
    ) AS `Repeat_Customer_Rate`

FROM CustomerOrders;


-- =========================================================
-- 10. LOW-PERFORMING PRODUCTS
-- =========================================================

SELECT

    p.ProductID,

    p.ProductName,

    cat.CategoryName AS `Category`,

    SUM(od.Quantity) AS `Units_Sold`,

    ROUND(
        SUM(
            od.UnitPrice * od.Quantity * (1 - od.Discount)
        ),
        2
    ) AS `Revenue`

FROM products p

INNER JOIN order_details od
    ON p.ProductID = od.ProductID

INNER JOIN categories cat
    ON p.CategoryID = cat.CategoryID

GROUP BY

    p.ProductID,
    p.ProductName,
    cat.CategoryName

ORDER BY Revenue ASC

LIMIT 10;


-- =========================================================
-- 11. TOP 10 CUSTOMER REVENUE CONCENTRATION
-- =========================================================

WITH CustomerSales AS
(
    SELECT

        c.CustomerID,

        c.CompanyName AS `Customer_Name`,

        ROUND(
            SUM(
                od.UnitPrice * od.Quantity * (1 - od.Discount)
            ),
            2
        ) AS `Revenue`

    FROM customers c

    INNER JOIN orders o
        ON c.CustomerID = o.CustomerID

    INNER JOIN order_details od
        ON o.OrderID = od.OrderID

    GROUP BY

        c.CustomerID,
        c.CompanyName
),

RankedCustomers AS
(
    SELECT

        *,

        ROW_NUMBER() OVER(
            ORDER BY Revenue DESC
        ) AS `Customer_Position`

    FROM CustomerSales
)

SELECT

    ROUND(
        SUM(
            CASE
                WHEN Customer_Position <= 10
                THEN Revenue
                ELSE 0
            END
        ),
        2
    ) AS `Top_10_Revenue`,

    ROUND(
        SUM(Revenue),
        2
    ) AS `Total_Revenue`,

    ROUND(
        SUM(
            CASE
                WHEN Customer_Position <= 10
                THEN Revenue
                ELSE 0
            END
        )
        /
        SUM(Revenue) * 100,
        1
    ) AS `Top_10_Revenue_Percentage`

FROM RankedCustomers;


-- =========================================================
-- 12. DISCOUNT ANALYSIS
-- =========================================================

SELECT

    ROUND(
        AVG(Discount) * 100,
        2
    ) AS `Average_Discount_Percentage`,

    ROUND(
        SUM(
            UnitPrice * Quantity * Discount
        ),
        2
    ) AS `Estimated_Discount_Value`

FROM order_details;


-- =========================================================
-- 13. FINAL DATASET SIZE
-- =========================================================

SELECT

    (SELECT COUNT(*) FROM customers)
        AS `Total_Customers`,

    (SELECT COUNT(*) FROM orders)
        AS `Total_Orders`,

    (SELECT COUNT(*) FROM order_details)
        AS `Total_Order_Details`,

    (SELECT COUNT(*) FROM products)
        AS `Total_Products`,

    (SELECT COUNT(*) FROM categories)
        AS `Total_Categories`,

    (SELECT COUNT(*) FROM employees)
        AS `Total_Employees`;