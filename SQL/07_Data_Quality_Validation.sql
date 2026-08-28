-- Check for NULL customer IDs in orders

USE northwind_sales_analysis;

SELECT
    COUNT(*) AS `Orders_With_Null_Customer`
FROM orders
WHERE CustomerID IS NULL;

-- NULL employee IDs

SELECT
    COUNT(*) AS `Orders_With_Null_Employee`
FROM orders
WHERE EmployeeID IS NULL;

-- Check for orphan order details

SELECT
    COUNT(*) AS `Orphan_Order_Details`
FROM order_details od
LEFT JOIN orders o
    ON od.OrderID = o.OrderID
WHERE o.OrderID IS NULL;

-- Check for duplicate Order IDs
SELECT
    OrderID,
    COUNT(*) AS `Duplicate_Count`
FROM orders
GROUP BY OrderID
HAVING COUNT(*) > 1;

-- Check for duplicate Product IDs

SELECT
    ProductID,
    COUNT(*) AS `Duplicate_Count`
FROM products
GROUP BY ProductID
HAVING COUNT(*) > 1;

-- Check revenue from order details

SELECT

    ROUND(
        SUM(
            UnitPrice * Quantity * (1 - Discount)
        ),
        2
    ) AS `Calculated_Revenue`

FROM order_details;

-- Reconcile orders with order details

SELECT

    COUNT(DISTINCT o.OrderID) AS `Orders`,

    COUNT(DISTINCT od.OrderID) AS `Orders_With_Details`

FROM orders o

LEFT JOIN order_details od
    ON o.OrderID = od.OrderID;
    
    -- Check unusual quantities/prices
    SELECT *

FROM order_details

WHERE Quantity <= 0
   OR UnitPrice <= 0
   OR Discount < 0
   OR Discount > 1;
   
   -- Check missing product categories
   
   SELECT

    COUNT(*) AS `Products_Without_Category`

FROM products p

LEFT JOIN categories c
    ON p.CategoryID = c.CategoryID

WHERE c.CategoryID IS NULL;


-- Check date quality

SELECT

    MIN(OrderDate) AS `Earliest_Order_Date`,

    MAX(OrderDate) AS `Latest_Order_Date`,

    COUNT(*) AS `Total_Orders`

FROM orders;

-- =========================================================
-- 8.12 FINAL REVENUE RECONCILIATION
-- =========================================================

SELECT

    ROUND(
        SUM(
            od.UnitPrice
            * od.Quantity
            * (1 - od.Discount)
        ),
        2
    ) AS `Revenue_From_Order_Details`,

    ROUND(
        (
            SELECT
                SUM(
                    od2.UnitPrice
                    * od2.Quantity
                    * (1 - od2.Discount)
                )
            FROM order_details od2
        ),
        2
    ) AS `Revenue_Reconciliation_Check`

FROM order_details od;


