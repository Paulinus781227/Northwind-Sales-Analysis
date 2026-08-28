USE northwind_sales_analysis;

-- =========================================================
-- 1. OVERALL BUSINESS KPIs
-- =========================================================

SELECT

    COUNT(DISTINCT o.OrderID) AS `Total_Orders`,

    COUNT(DISTINCT o.CustomerID) AS `Active_Customers`,

    COUNT(DISTINCT od.ProductID) AS `Products_Sold`,

    COUNT(DISTINCT o.EmployeeID) AS `Active_Sales_Employees`,

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
        NULLIF(COUNT(DISTINCT o.OrderID), 0),
        2
    ) AS `Average_Order_Value`

FROM orders o

INNER JOIN order_details od
    ON o.OrderID = od.OrderID;
    
    -- =========================================================
-- 2. SALES PERIOD
-- =========================================================

SELECT

    MIN(OrderDate) AS `First_Order_Date`,

    MAX(OrderDate) AS `Last_Order_Date`,

    DATEDIFF(
        MAX(OrderDate),
        MIN(OrderDate)
    ) AS `Days_Covered`

FROM orders;

-- =========================================================
-- 3. YEARLY REVENUE
-- =========================================================

SELECT

    YEAR(o.OrderDate) AS `Sales_Year`,

    COUNT(DISTINCT o.OrderID) AS `Total_Orders`,

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
-- 4. BEST SALES YEAR
-- =========================================================

WITH YearlySales AS
(
    SELECT

        YEAR(o.OrderDate) AS `Sales_Year`,

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
),

YearRanking AS
(
    SELECT

        *,

        RANK() OVER(
            ORDER BY Revenue DESC
        ) AS `Revenue_Rank`

    FROM YearlySales
)

SELECT

    Sales_Year,
    Revenue,
    Revenue_Rank

FROM YearRanking

WHERE Revenue_Rank = 1;

-- =========================================================
-- 5. TOP CUSTOMER
-- =========================================================

WITH CustomerSales AS
(
    SELECT

        c.CustomerID,

        c.CompanyName AS `Customer_Name`,

        c.Country,

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
),

CustomerRanking AS
(
    SELECT

        *,

        RANK() OVER(
            ORDER BY Revenue DESC
        ) AS `Revenue_Rank`

    FROM CustomerSales
)

SELECT

    CustomerID,
    Customer_Name,
    Country,
    Revenue

FROM CustomerRanking

WHERE Revenue_Rank = 1;

-- =========================================================
-- 6. TOP PRODUCT
-- =========================================================

WITH ProductSales AS
(
    SELECT

        p.ProductID,

        p.ProductName,

        cat.CategoryName AS `Category`,

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
),

ProductRanking AS
(
    SELECT

        *,

        RANK() OVER(
            ORDER BY Revenue DESC
        ) AS `Revenue_Rank`

    FROM ProductSales
)

SELECT

    ProductID,
    ProductName,
    Category,
    Revenue

FROM ProductRanking

WHERE Revenue_Rank = 1;

-- =========================================================
-- 7. TOP CATEGORY
-- =========================================================

WITH CategorySales AS
(
    SELECT

        cat.CategoryID,

        cat.CategoryName AS `Category`,

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
),

CategoryRanking AS
(
    SELECT

        *,

        RANK() OVER(
            ORDER BY Revenue DESC
        ) AS `Revenue_Rank`

    FROM CategorySales
)

SELECT

    CategoryID,
    Category,
    Revenue

FROM CategoryRanking

WHERE Revenue_Rank = 1;

-- =========================================================
-- 8. TOP SALES EMPLOYEE
-- =========================================================

WITH EmployeeSales AS
(
    SELECT

        e.EmployeeID,

        e.employeeName AS `Employee_Name`,

        COUNT(DISTINCT o.OrderID) AS `Total_Orders`,

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
),

EmployeeRanking AS
(
    SELECT

        *,

        RANK() OVER(
            ORDER BY Revenue DESC
        ) AS `Revenue_Rank`

    FROM EmployeeSales
)

SELECT

    EmployeeID,
    Employee_Name,
    Total_Orders,
    Revenue

FROM EmployeeRanking

WHERE Revenue_Rank = 1;

-- =========================================================
-- 9. TOP CUSTOMER COUNTRY
-- =========================================================

WITH CountrySales AS
(
    SELECT

        c.Country,

        COUNT(DISTINCT o.OrderID) AS `Total_Orders`,

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
),

CountryRanking AS
(
    SELECT

        *,

        RANK() OVER(
            ORDER BY Revenue DESC
        ) AS `Revenue_Rank`

    FROM CountrySales
)

SELECT

    Country,
    Total_Orders,
    Revenue

FROM CountryRanking

WHERE Revenue_Rank = 1;

-- =========================================================
-- 10. REPEAT CUSTOMER RATE
-- =========================================================

WITH CustomerOrders AS
(
    SELECT

        c.CustomerID,

        COUNT(DISTINCT o.OrderID) AS `Total_Orders`

    FROM customers c

    INNER JOIN orders o
        ON c.CustomerID = o.CustomerID

    GROUP BY c.CustomerID
)

SELECT

    COUNT(*) AS `Active_Customers`,

    SUM(
        CASE
            WHEN Total_Orders > 1
            THEN 1
            ELSE 0
        END
    ) AS `Repeat_Customers`,

    ROUND(
        (
            SUM(
                CASE
                    WHEN Total_Orders > 1
                    THEN 1
                    ELSE 0
                END
            )
            /
            COUNT(*)
        ) * 100,
        1
    ) AS `Repeat_Customer_Rate`

FROM CustomerOrders;

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

CustomerRanking AS
(
    SELECT

        *,

        ROW_NUMBER() OVER(
            ORDER BY Revenue DESC
        ) AS `Customer_Position`,

        SUM(Revenue) OVER()
        AS `Company_Revenue`

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
    ) AS `Top_10_Customer_Revenue`,

    MAX(Company_Revenue) AS `Company_Revenue`,

    ROUND(
        (
            SUM(
                CASE
                    WHEN Customer_Position <= 10
                    THEN Revenue
                    ELSE 0
                END
            )
            /
            MAX(Company_Revenue)
        ) * 100,
        1
    ) AS `Top_10_Revenue_Concentration_Percentage`

FROM CustomerRanking;

-- =========================================================
-- 12. EXECUTIVE PERFORMANCE SNAPSHOT
-- =========================================================

SELECT

    COUNT(DISTINCT o.OrderID) AS `Total_Orders`,

    COUNT(DISTINCT o.CustomerID) AS `Active_Customers`,

    COUNT(DISTINCT od.ProductID) AS `Products_Sold`,

    COUNT(DISTINCT o.EmployeeID) AS `Active_Employees`,

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
    ) AS `Average_Order_Value`,

    SUM(od.Quantity) AS `Units_Sold`

FROM orders o

INNER JOIN order_details od
    ON o.OrderID = od.OrderID;
    
    