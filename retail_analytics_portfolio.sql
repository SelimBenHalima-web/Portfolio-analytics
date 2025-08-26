
-- =========================================
-- a) Basic KPI - Total Revenue
-- Purpose: Calculate the total revenue from all transactions.
-- Insight: Provides a high-level view of overall sales performance.
-- =========================================
SELECT SUM(quantity * price) AS Total_Revenue
FROM `Portfolio_Sales.Sales_Mall`;


-- =========================================
-- b) Revenue by Year
-- Purpose: Calculate yearly revenue.
-- Insight: Identify growth trends and compare sales performance across years.
-- =========================================
SELECT EXTRACT(YEAR FROM invoice_date) AS Year,
       SUM(quantity * price) AS Revenue
FROM `Portfolio_Sales.Sales_Mall`
GROUP BY Year
ORDER BY Year;


-- =========================================
-- c) Revenue by Shopping Mall
-- Purpose: Calculate total revenue per shopping mall.
-- Insight: Determine which malls generate the highest revenue.
-- =========================================
SELECT shopping_mall AS Shopping_Mall,
       SUM(quantity * price) AS Revenue
FROM `Portfolio_Sales.Sales_Mall`
GROUP BY Shopping_Mall
ORDER BY Revenue DESC;


-- =========================================
-- d) Revenue by Category and Mall
-- Purpose: Calculate total revenue by shopping mall and product category.
-- Insight: Identify which categories generate the most sales within each mall.
-- =========================================
SELECT shopping_mall AS Shopping_Mall,
       category AS Category,
       SUM(quantity * price) AS Revenue
FROM `Portfolio_Sales.Sales_Mall`
GROUP BY Shopping_Mall, Category
ORDER BY Shopping_Mall, Revenue DESC;


-- =========================================
-- e) Average Order Value (AOV)
-- Purpose: Compute the average order value (AOV).
-- Insight: Understand how much customers spend on average per order.
-- =========================================
WITH orders AS (
  SELECT invoice_no AS Invoice_Number,
         SUM(quantity * price) AS Order_Revenue
  FROM `Portfolio_Sales.Sales_Mall`
  GROUP BY Invoice_Number
)
SELECT AVG(Order_Revenue) AS Avg_Order_Value
FROM orders;


-- =========================================
-- f) Payment Method Mix
-- Purpose: Break down revenue by payment method.
-- Insight: Determine which payment methods are most commonly used by customers.
-- =========================================
SELECT payment_method AS Payment_Method,
       SUM(quantity * price) AS Revenue,
       ROUND(100 * SUM(quantity * price) / SUM(SUM(quantity * price)) OVER(), 2) AS Pct_Revenue
FROM `Portfolio_Sales.Sales_Mall`
GROUP BY Payment_Method
ORDER BY Revenue DESC;


-- =========================================
-- g) Customer Cohorts (Simple Example)
-- Purpose: Build customer cohorts based on their first purchase month.
-- Insight: Analyze customer retention and activity over time by cohort.
-- =========================================
WITH first_purchase AS (
  SELECT customer_id AS Customer_ID,
         MIN(invoice_date) AS First_Date
  FROM `Portfolio_Sales.Sales_Mall`
  GROUP BY Customer_ID
),
cohort AS (
  SELECT s.customer_id AS Customer_ID,
         DATE_TRUNC(f.First_Date, MONTH) AS Cohort_Month,
         DATE_TRUNC(s.invoice_date, MONTH) AS Order_Month
  FROM `Portfolio_Sales.Sales_Mall` s
  JOIN first_purchase f
  USING (Customer_ID)
)
SELECT Cohort_Month,
       Order_Month,
       COUNT(DISTINCT Customer_ID) AS Active_Customers
FROM cohort
GROUP BY Cohort_Month, Order_Month
ORDER BY Cohort_Month, Order_Month;
