/*
===========================================================
PROJECT: NORTHWIND SALES & CUSTOMER PERFORMANCE ANALYSIS
FILE: 04_Product_Analysis.sql
PURPOSE:
Analyze product performance, category performance,
product rankings, revenue contribution and product
performance classification.
===========================================================
*/

USE northwind_sales_analysis;


-- =========================================================
-- 1. PRODUCT OVERVIEW
-- =========================================================

SELECT

    COUNT(*) AS `Total_Products`,

    COUNT(DISTINCT CategoryID) AS `Categories_With_Products`

FROM products;


-- =========================================================
-- 2. PRODUCT SALES SUMMARY
-- =========================================================

WITH ProductSales AS
(
    SELECT

        p.ProductID,

        p.ProductName,

        cat.CategoryName AS `Category`,

        SUM(od.Quantity) AS `Units_Sold`,

        COUNT(DISTINCT od.OrderID) AS `Orders`,

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
)

SELECT

    ProductID,
    ProductName,
    Category,
    Units_Sold,
    Orders,
    Revenue,

    ROUND(
        Revenue / NULLIF(Orders, 0),
        2
    ) AS `Average_Revenue_Per_Order`

FROM ProductSales

ORDER BY Revenue DESC;


-- =========================================================
-- 3. TOP 10 PRODUCTS BY REVENUE
-- =========================================================

WITH ProductSales AS
(
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
)

SELECT

    ProductID,
    ProductName,
    Category,
    Units_Sold,
    Revenue

FROM ProductSales

ORDER BY Revenue DESC

LIMIT 10;


-- =========================================================
-- 4. BOTTOM 10 PRODUCTS BY REVENUE
-- =========================================================

WITH ProductSales AS
(
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
)

SELECT

    ProductID,
    ProductName,
    Category,
    Units_Sold,
    Revenue

FROM ProductSales

ORDER BY Revenue ASC

LIMIT 10;


-- =========================================================
-- 5. PRODUCT REVENUE RANKING
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
        ) AS `Revenue_Rank`,

        DENSE_RANK() OVER(
            ORDER BY Revenue DESC
        ) AS `Revenue_Dense_Rank`,

        ROW_NUMBER() OVER(
            ORDER BY Revenue DESC
        ) AS `Revenue_Row_Number`

    FROM ProductSales
)

SELECT

    ProductID,
    ProductName,
    Category,
    Revenue,
    Revenue_Rank,
    Revenue_Dense_Rank,
    Revenue_Row_Number

FROM ProductRanking

ORDER BY Revenue_Rank;


-- =========================================================
-- 6. PRODUCT REVENUE CONTRIBUTION
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
)

SELECT

    ProductID,
    ProductName,
    Category,
    Revenue,

    ROUND(
        (
            Revenue
            /
            SUM(Revenue) OVER()
        ) * 100,
        1
    ) AS `Revenue_Contribution_Percentage`

FROM ProductSales

ORDER BY Revenue DESC;


-- =========================================================
-- 7. PRODUCT PERFORMANCE CLASSIFICATION
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

ProductBenchmarks AS
(
    SELECT

        *,

        AVG(Revenue) OVER()
        AS `Average_Product_Revenue`

    FROM ProductSales
)

SELECT

    ProductID,
    ProductName,
    Category,
    Revenue,
    Average_Product_Revenue,

    ROUND(
        (
            (
                Revenue
                -
                Average_Product_Revenue
            )
            /
            NULLIF(Average_Product_Revenue, 0)
        ) * 100,
        1
    ) AS `Percentage_From_Average`,

    CASE

        WHEN Revenue >= Average_Product_Revenue * 2
            THEN 'Exceptional Product'

        WHEN Revenue >= Average_Product_Revenue
            THEN 'Above Average Product'

        WHEN Revenue >= Average_Product_Revenue * 0.5
            THEN 'Below Average Product'

        ELSE 'Low Performing Product'

    END AS `Product_Performance_Classification`

FROM ProductBenchmarks

ORDER BY Revenue DESC;


-- =========================================================
-- 8. CATEGORY PERFORMANCE SUMMARY
-- =========================================================

WITH CategorySales AS
(
    SELECT

        cat.CategoryID,

        cat.CategoryName AS `Category`,

        COUNT(DISTINCT p.ProductID) AS `Products`,

        SUM(od.Quantity) AS `Units_Sold`,

        COUNT(DISTINCT od.OrderID) AS `Orders`,

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
)

SELECT

    CategoryID,
    Category,
    Products,
    Units_Sold,
    Orders,
    Revenue,

    ROUND(
        Revenue / NULLIF(Orders, 0),
        2
    ) AS `Average_Revenue_Per_Order`

FROM CategorySales

ORDER BY Revenue DESC;


-- =========================================================
-- 9. CATEGORY REVENUE CONTRIBUTION
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
)

SELECT

    CategoryID,
    Category,
    Revenue,

    ROUND(
        (
            Revenue
            /
            SUM(Revenue) OVER()
        ) * 100,
        1
    ) AS `Revenue_Contribution_Percentage`

FROM CategorySales

ORDER BY Revenue DESC;


-- =========================================================
-- 10. CATEGORY RANKING & CLASSIFICATION
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
    Revenue,
    Revenue_Rank,

    CASE

        WHEN Revenue_Rank <= 3
            THEN 'Top Performing Category'

        WHEN Revenue_Rank <= 6
            THEN 'Middle Performing Category'

        ELSE 'Lower Performing Category'

    END AS `Category_Performance_Classification`

FROM CategoryRanking

ORDER BY Revenue_Rank;


-- =========================================================
-- 11. CATEGORY PRODUCT MIX
-- =========================================================

SELECT

    cat.CategoryName AS `Category`,

    COUNT(DISTINCT p.ProductID) AS `Total_Products`,

    COUNT(DISTINCT od.ProductID) AS `Products_Sold`,

    COUNT(DISTINCT p.ProductID)
    -
    COUNT(DISTINCT od.ProductID) AS `Products_Not_Sold`

FROM categories cat

INNER JOIN products p
    ON cat.CategoryID = p.CategoryID

LEFT JOIN order_details od
    ON p.ProductID = od.ProductID

GROUP BY cat.CategoryID, cat.CategoryName

ORDER BY Products_Not_Sold DESC;