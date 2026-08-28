/*
===========================================================
PROJECT: NORTHWIND SALES & CUSTOMER PERFORMANCE ANALYSIS
FILE: 05_Employee_Performance.sql
PURPOSE:
Analyze employee sales performance, revenue contribution,
order volume, average order value, ranking and
performance classification.
===========================================================
*/

USE northwind_sales_analysis;


-- =========================================================
-- 1. EMPLOYEE SALES OVERVIEW
-- =========================================================

SELECT

    e.EmployeeID,

        e.employeeName AS `Employee_Name`,

    COUNT(DISTINCT o.OrderID) AS `Total_Orders`,

    SUM(od.Quantity) AS `Units_Sold`,

    ROUND(
        SUM(
            od.UnitPrice * od.Quantity * (1 - od.Discount)
        ),
        2
    ) AS `Total_Revenue`

FROM employees e

INNER JOIN orders o
    ON e.EmployeeID = o.EmployeeID

INNER JOIN order_details od
    ON o.OrderID = od.OrderID

GROUP BY

    e.EmployeeID,
    e.employeeName

ORDER BY Total_Revenue DESC;


-- =========================================================
-- 2. EMPLOYEE AVERAGE ORDER VALUE
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
        ) AS `Total_Revenue`

    FROM employees e

    INNER JOIN orders o
        ON e.EmployeeID = o.EmployeeID

    INNER JOIN order_details od
        ON o.OrderID = od.OrderID

    GROUP BY

        e.EmployeeID,
      e.employeeName
)

SELECT

    EmployeeID,
    Employee_Name,
    Total_Orders,
    Total_Revenue,

    ROUND(
        Total_Revenue / NULLIF(Total_Orders, 0),
        2
    ) AS `Average_Order_Value`

FROM EmployeeSales

ORDER BY Average_Order_Value DESC;


-- =========================================================
-- 3. EMPLOYEE REVENUE RANKING
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
        ) AS `Total_Revenue`

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
            ORDER BY Total_Revenue DESC
        ) AS `Revenue_Rank`,

        DENSE_RANK() OVER(
            ORDER BY Total_Revenue DESC
        ) AS `Revenue_Dense_Rank`,

        ROW_NUMBER() OVER(
            ORDER BY Total_Revenue DESC
        ) AS `Revenue_Row_Number`

    FROM EmployeeSales
)

SELECT

    EmployeeID,
    Employee_Name,
    Total_Orders,
    Total_Revenue,
    Revenue_Rank,
    Revenue_Dense_Rank,
    Revenue_Row_Number

FROM EmployeeRanking

ORDER BY Revenue_Rank;


-- =========================================================
-- 4. EMPLOYEE REVENUE CONTRIBUTION
-- =========================================================

WITH EmployeeSales AS
(
    SELECT

        e.EmployeeID,

        e.employeeName AS `Employee_Name`,

        ROUND(
            SUM(
                od.UnitPrice * od.Quantity * (1 - od.Discount)
            ),
            2
        ) AS `Total_Revenue`

    FROM employees e

    INNER JOIN orders o
        ON e.EmployeeID = o.EmployeeID

    INNER JOIN order_details od
        ON o.OrderID = od.OrderID

    GROUP BY

        e.EmployeeID,
        e.employeeName
)

SELECT

    EmployeeID,
    Employee_Name,
    Total_Revenue,

    ROUND(
        (
            Total_Revenue
            /
            SUM(Total_Revenue) OVER()
        ) * 100,
        1
    ) AS `Revenue_Contribution_Percentage`

FROM EmployeeSales

ORDER BY Total_Revenue DESC;


-- =========================================================
-- 5. EMPLOYEE PERFORMANCE BENCHMARK
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
        ) AS `Total_Revenue`

    FROM employees e

    INNER JOIN orders o
        ON e.EmployeeID = o.EmployeeID

    INNER JOIN order_details od
        ON o.OrderID = od.OrderID

    GROUP BY

        e.EmployeeID,
        e.employeeName
),

EmployeeBenchmark AS
(
    SELECT

        *,

        AVG(Total_Revenue) OVER()
        AS `Average_Employee_Revenue`

    FROM EmployeeSales
)

SELECT

    EmployeeID,
    Employee_Name,
    Total_Orders,
    Total_Revenue,
    Average_Employee_Revenue,

    ROUND(
        (
            (
                Total_Revenue
                -
                Average_Employee_Revenue
            )
            /
            NULLIF(Average_Employee_Revenue, 0)
        ) * 100,
        1
    ) AS `Percentage_From_Average`,

    CASE

        WHEN Total_Revenue >= Average_Employee_Revenue * 1.5
            THEN 'Exceptional Performer'

        WHEN Total_Revenue >= Average_Employee_Revenue
            THEN 'Above Average Performer'

        WHEN Total_Revenue >= Average_Employee_Revenue * 0.5
            THEN 'Below Average Performer'

        ELSE 'Low Performing Employee'

    END AS `Performance_Classification`

FROM EmployeeBenchmark

ORDER BY Total_Revenue DESC;


-- =========================================================
-- 6. EMPLOYEE ORDER VOLUME RANKING
-- =========================================================

WITH EmployeeOrders AS
(
    SELECT

        e.EmployeeID,
e.employeeName AS `Employee_Name`,

        COUNT(DISTINCT o.OrderID) AS `Total_Orders`

    FROM employees e

    INNER JOIN orders o
        ON e.EmployeeID = o.EmployeeID

    GROUP BY

        e.EmployeeID,
        e.employeeName
),

EmployeeRanking AS
(
    SELECT

        *,

        RANK() OVER(
            ORDER BY Total_Orders DESC
        ) AS `Order_Volume_Rank`

    FROM EmployeeOrders
)

SELECT

    EmployeeID,
    Employee_Name,
    Total_Orders,
    Order_Volume_Rank

FROM EmployeeRanking

ORDER BY Order_Volume_Rank;


-- =========================================================
-- 7. EMPLOYEE YEARLY PERFORMANCE
-- =========================================================

SELECT

    e.EmployeeID,
e.employeeName AS `Employee_Name`,

    YEAR(o.OrderDate) AS `Sales_Year`,

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
    e.employeeName,
    YEAR(o.OrderDate)

ORDER BY

    Employee_Name,
    Sales_Year;


-- =========================================================
-- 8. EMPLOYEE REVENUE BY COUNTRY
-- =========================================================

SELECT

    e.EmployeeID,
e.employeeName AS `Employee_Name`,

    c.Country,

    ROUND(
        SUM(
            od.UnitPrice * od.Quantity * (1 - od.Discount)
        ),
        2
    ) AS `Revenue`

FROM employees e

INNER JOIN orders o
    ON e.EmployeeID = o.EmployeeID

INNER JOIN customers c
    ON o.CustomerID = c.CustomerID

INNER JOIN order_details od
    ON o.OrderID = od.OrderID

GROUP BY

    e.EmployeeID,
    e.employeeName,
    c.Country

ORDER BY

    Employee_Name,
    Revenue DESC;


-- =========================================================
-- 9. FINAL EMPLOYEE PERFORMANCE SUMMARY
-- =========================================================

WITH EmployeeSales AS
(
    SELECT

        e.EmployeeID,
e.employeeName AS `Employee_Name`,

        COUNT(DISTINCT o.OrderID) AS `Total_Orders`,

        SUM(od.Quantity) AS `Units_Sold`,

        ROUND(
            SUM(
                od.UnitPrice * od.Quantity * (1 - od.Discount)
            ),
            2
        ) AS `Total_Revenue`

    FROM employees e

    INNER JOIN orders o
        ON e.EmployeeID = o.EmployeeID

    INNER JOIN order_details od
        ON o.OrderID = od.OrderID

    GROUP BY

        e.EmployeeID,
        e.employeeName
),

EmployeeMetrics AS
(
    SELECT

        *,

        RANK() OVER(
            ORDER BY Total_Revenue DESC
        ) AS `Revenue_Rank`,

        AVG(Total_Revenue) OVER()
        AS `Average_Employee_Revenue`

    FROM EmployeeSales
)

SELECT

    EmployeeID,
    Employee_Name,
    Total_Orders,
    Units_Sold,
    Total_Revenue,
    Revenue_Rank,

    ROUND(
        (
            Total_Revenue
            /
            SUM(Total_Revenue) OVER()
        ) * 100,
        1
    ) AS `Revenue_Contribution_Percentage`,

    ROUND(
        (
            (
                Total_Revenue
                -
                Average_Employee_Revenue
            )
            /
            NULLIF(Average_Employee_Revenue, 0)
        ) * 100,
        1
    ) AS `Percentage_From_Average`,

    CASE

        WHEN Revenue_Rank <= 3
            THEN 'Top Performer'

        WHEN Total_Revenue >= Average_Employee_Revenue
            THEN 'Above Average Performer'

        ELSE 'Below Average Performer'

    END AS `Performance_Classification`

FROM EmployeeMetrics

ORDER BY Revenue_Rank;