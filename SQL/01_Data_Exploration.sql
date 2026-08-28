/*
===========================================================
PROJECT: NORTHWIND SALES & CUSTOMER PERFORMANCE ANALYSIS
FILE: 01_Data_Exploration.sql
PURPOSE:
Initial database exploration, structure validation,
record counts, date-range validation and NULL checks.
===========================================================
*/

USE northwind_sales_analysis;



-- Selecting the database
USE northwind_sales_analysis;
-- ==========================

-- Inspecting all 7 tables
DESCRIBE categories;

DESCRIBE customers;

DESCRIBE employees;

DESCRIBE order_details;

DESCRIBE orders;

DESCRIBE products;

DESCRIBE shippers;

-- ==========================

-- Previewing the important tables
SELECT *
FROM orders
LIMIT 10;

SELECT *
FROM order_details
LIMIT 10;

SELECT *
FROM products
LIMIT 10;

SELECT *
FROM customers
LIMIT 10;

-- ====================
-- Establishing the dataset size
SELECT 'Categories' AS Table_Name, COUNT(*) AS Row_Count
FROM categories

UNION ALL

SELECT 'Customers', COUNT(*)
FROM customers

UNION ALL

SELECT 'Employees', COUNT(*)
FROM employees

UNION ALL

SELECT 'Order Details', COUNT(*)
FROM order_details

UNION ALL

SELECT 'Orders', COUNT(*)
FROM orders

UNION ALL

SELECT 'Products', COUNT(*)
FROM products

UNION ALL

SELECT 'Shippers', COUNT(*)
FROM shippers;

-- =====================

-- Checking the date range
SELECT
    MIN(OrderDate) AS First_Order_Date,
    MAX(OrderDate) AS Last_Order_Date,
    COUNT(*) AS Total_Orders
FROM orders;

-- ============

-- Checking for NULLs in the key fields
SELECT
    COUNT(*) AS Total_Orders,
    COUNT(OrderID) AS Orders_With_Order_ID,
    COUNT(CustomerID) AS Orders_With_Customer_ID,
    COUNT(EmployeeID) AS Orders_With_Employee_ID
FROM orders;

SELECT
    COUNT(*) AS Total_Order_Details,
    COUNT(OrderID) AS Details_With_Order_ID,
    COUNT(ProductID) AS Details_With_Product_ID,
    COUNT(Quantity) AS Details_With_Quantity
FROM order_details;







