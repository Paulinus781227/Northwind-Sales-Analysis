/*
===========================================================
PROJECT: NORTHWIND SALES & CUSTOMER PERFORMANCE ANALYSIS
FILE: 03_Customer_Analysis.sql
PURPOSE:
Analyze customer activity, revenue contribution,
customer ranking, repeat purchasing behavior and
customer performance classification.
===========================================================
*/

USE northwind_sales_analysis;


-- =========================================================
-- 1. CUSTOMER OVERVIEW
-- =========================================================

SELECT

    COUNT(*) AS `Total_Customers`,

    COUNT(
        CASE
            WHEN CustomerID IS NOT NULL
            THEN 1
        END
    ) AS `Customers_With_ID`

FROM customers;


-- =========================================================
-- 2. ACTIVE VS INACTIVE CUSTOMERS
-- =========================================================

SELECT

    COUNT(DISTINCT c.CustomerID) AS `Active_Customers`

FROM customers c

INNER JOIN orders o
    ON c.CustomerID = o.CustomerID;


SELECT

    COUNT(*) AS `Inactive_Customers`

FROM customers c

LEFT JOIN orders o
    ON c.CustomerID = o.CustomerID

WHERE o.CustomerID IS NULL;


-- =========================================================
-- 3. CUSTOMER ORDER & REVENUE SUMMARY
-- =========================================================

WITH CustomerSales AS
(
    SELECT

        c.CustomerID,

        c.CompanyName AS `Customer_Name`,

        c.Country,

        COUNT(DISTINCT o.OrderID) AS `Total_Orders`,

        SUM(od.Quantity) AS `Units_Purchased`,

        ROUND(
            SUM(
                od.UnitPrice * od.Quantity * (1 - od.Discount)
            ),
            2
        ) AS `Total_Revenue`

    FROM customers c

    INNER JOIN orders o
        ON c.CustomerID = o.CustomerID

    INNER JOIN order_details od
        ON o.OrderID = od.OrderID

    GROUP BY

        c.CustomerID,
        c.CompanyName,
        c.Country
)

SELECT

    CustomerID,
    Customer_Name,
    Country,
    Total_Orders,
    Units_Purchased,
    Total_Revenue,

    ROUND(
        Total_Revenue / NULLIF(Total_Orders, 0),
        2
    ) AS `Average_Order_Value`

FROM CustomerSales

ORDER BY Total_Revenue DESC;


-- =========================================================
-- 4. TOP 10 CUSTOMERS BY REVENUE
-- =========================================================

WITH CustomerSales AS
(
    SELECT

        c.CustomerID,

        c.CompanyName AS `Customer_Name`,

        c.Country,

        COUNT(DISTINCT o.OrderID) AS `Total_Orders`,

        ROUND(
            SUM(
                od.UnitPrice * od.Quantity * (1 - od.Discount)
            ),
            2
        ) AS `Total_Revenue`

    FROM customers c

    INNER JOIN orders o
        ON c.CustomerID = o.CustomerID

    INNER JOIN order_details od
        ON o.OrderID = od.OrderID

    GROUP BY

        c.CustomerID,
        c.CompanyName,
        c.Country
)

SELECT

    CustomerID,
    Customer_Name,
    Country,
    Total_Orders,
    Total_Revenue

FROM CustomerSales

ORDER BY Total_Revenue DESC

LIMIT 10;


-- =========================================================
-- 5. CUSTOMER REVENUE RANKING
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
        ) AS `Total_Revenue`

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

        RANK() OVER(
            ORDER BY Total_Revenue DESC
        ) AS `Revenue_Rank`,

        DENSE_RANK() OVER(
            ORDER BY Total_Revenue DESC
        ) AS `Revenue_Dense_Rank`,

        ROW_NUMBER() OVER(
            ORDER BY Total_Revenue DESC
        ) AS `Revenue_Row_Number`

    FROM CustomerSales
)

SELECT

    CustomerID,
    Customer_Name,
    Total_Revenue,
    Revenue_Rank,
    Revenue_Dense_Rank,
    Revenue_Row_Number

FROM CustomerRanking

ORDER BY Revenue_Rank;


-- =========================================================
-- 6. CUSTOMER REVENUE CONTRIBUTION
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
        ) AS `Total_Revenue`

    FROM customers c

    INNER JOIN orders o
        ON c.CustomerID = o.CustomerID

    INNER JOIN order_details od
        ON o.OrderID = od.OrderID

    GROUP BY

        c.CustomerID,
        c.CompanyName
)

SELECT

    CustomerID,
    Customer_Name,
    Total_Revenue,

    ROUND(
        (
            Total_Revenue
            /
            SUM(Total_Revenue) OVER()
        ) * 100,
        1
    ) AS `Revenue_Contribution_Percentage`

FROM CustomerSales

ORDER BY Total_Revenue DESC;


-- =========================================================
-- 7. REPEAT CUSTOMER ANALYSIS
-- =========================================================

WITH CustomerOrders AS
(
    SELECT

        c.CustomerID,

        c.CompanyName AS `Customer_Name`,

        COUNT(DISTINCT o.OrderID) AS `Total_Orders`

    FROM customers c

    INNER JOIN orders o
        ON c.CustomerID = o.CustomerID

    GROUP BY

        c.CustomerID,
        c.CompanyName
)

SELECT

    COUNT(*) AS `Customers_With_Orders`,

    SUM(
        CASE
            WHEN Total_Orders > 1
            THEN 1
            ELSE 0
        END
    ) AS `Repeat_Customers`,

    SUM(
        CASE
            WHEN Total_Orders = 1
            THEN 1
            ELSE 0
        END
    ) AS `One_Time_Customers`

FROM CustomerOrders;


-- =========================================================
-- 8. CUSTOMER ORDER FREQUENCY CLASSIFICATION
-- =========================================================

WITH CustomerOrders AS
(
    SELECT

        c.CustomerID,

        c.CompanyName AS `Customer_Name`,

        COUNT(DISTINCT o.OrderID) AS `Total_Orders`

    FROM customers c

    INNER JOIN orders o
        ON c.CustomerID = o.CustomerID

    GROUP BY

        c.CustomerID,
        c.CompanyName
)

SELECT

    CustomerID,
    Customer_Name,
    Total_Orders,

    CASE

        WHEN Total_Orders >= 10
            THEN 'Highly Active Customer'

        WHEN Total_Orders >= 5
            THEN 'Active Customer'

        WHEN Total_Orders >= 2
            THEN 'Repeat Customer'

        ELSE 'One-Time Customer'

    END AS `Customer_Activity_Classification`

FROM CustomerOrders

ORDER BY Total_Orders DESC;


-- =========================================================
-- 9. CUSTOMER REVENUE CLASSIFICATION
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
        ) AS `Total_Revenue`

    FROM customers c

    INNER JOIN orders o
        ON c.CustomerID = o.CustomerID

    INNER JOIN order_details od
        ON o.OrderID = od.OrderID

    GROUP BY

        c.CustomerID,
        c.CompanyName
),

CustomerBenchmarks AS
(
    SELECT

        *,

        AVG(Total_Revenue) OVER()
        AS `Average_Customer_Revenue`

    FROM CustomerSales
)

SELECT

    CustomerID,
    Customer_Name,
    Total_Revenue,
    Average_Customer_Revenue,

    ROUND(
        (
            (
                Total_Revenue
                -
                Average_Customer_Revenue
            )
            /
            NULLIF(Average_Customer_Revenue, 0)
        ) * 100,
        1
    ) AS `Percentage_From_Average`,

    CASE

        WHEN Total_Revenue >= Average_Customer_Revenue * 2
            THEN 'Exceptional Customer'

        WHEN Total_Revenue >= Average_Customer_Revenue
            THEN 'Above Average Customer'

        WHEN Total_Revenue >= Average_Customer_Revenue * 0.5
            THEN 'Below Average Customer'

        ELSE 'Low Value Customer'

    END AS `Customer_Value_Classification`

FROM CustomerBenchmarks

ORDER BY Total_Revenue DESC;


-- =========================================================
-- 10. CUSTOMER COUNTRY PERFORMANCE
-- =========================================================

SELECT

    c.Country AS `Country`,

    COUNT(DISTINCT c.CustomerID) AS `Customers`,

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

GROUP BY c.Country

ORDER BY Revenue DESC;


-- =========================================================
-- 11. TOP CUSTOMERS WITH COUNTRY AND REVENUE SHARE
-- =========================================================

WITH CustomerSales AS
(
    SELECT

        c.CustomerID,

        c.CompanyName AS `Customer_Name`,

        c.Country,

        COUNT(DISTINCT o.OrderID) AS `Total_Orders`,

        ROUND(
            SUM(
                od.UnitPrice * od.Quantity * (1 - od.Discount)
            ),
            2
        ) AS `Total_Revenue`

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

CustomerMetrics AS
(
    SELECT

        *,

        RANK() OVER(
            ORDER BY Total_Revenue DESC
        ) AS `Revenue_Rank`,

        ROUND(
            (
                Total_Revenue
                /
                SUM(Total_Revenue) OVER()
            ) * 100,
            1
        ) AS `Revenue_Share_Percentage`

    FROM CustomerSales
)

SELECT

    CustomerID,
    Customer_Name,
    Country,
    Total_Orders,
    Total_Revenue,
    Revenue_Rank,
    Revenue_Share_Percentage

FROM CustomerMetrics

WHERE Revenue_Rank <= 10

ORDER BY Revenue_Rank;