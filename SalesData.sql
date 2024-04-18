-- Initial data inspection
SELECT *
FROM sales_data;

-- Identifying the unique values for some of the columns 
SELECT DISTINCT(STATUS) 
FROM sales_data;

SELECT DISTINCT(PRODUCTLINE) 
FROM sales_data;

SELECT DISTINCT(YEAR_ID) 
FROM sales_data;

SELECT DISTINCT(COUNTRY) 
FROM sales_data;
 
SELECT DISTINCT(CUSTOMERNAME) 
FROM sales_data;



-- DATA ANALYSIS -- 

-- QUESTION 1. Among all product lines, which one has the highest sales? --
SELECT 
    PRODUCTLINE,
    ROUND(SUM(SALES), 3) as Revenue
FROM 
    sales_data
GROUP BY 
    PRODUCTLINE
ORDER BY 
    Revenue DESC;
-- As shown, Classic Cars is the leading product line in terms of sales, while Trains exhibits the lowest sales among the product lines.



-- QUESTION 2. Which year recorded the highest sales? --
SELECT 
    YEAR_ID as Year,
    ROUND(SUM(SALES), 3) as Revenue
FROM 
    sales_data
GROUP BY 
    YEAR_ID
ORDER BY 
    Revenue DESC;
--  It can be seen that 2004 has the highest sales. And 2005 stands out with the lowest sales.



-- QUESTION 2A. Why did the sales dip in 2005? --
SELECT 
    YEAR_ID as Year,
    MONTH_ID as Month
FROM 
    sales_data
GROUP BY 
    YEAR_ID, MONTH_ID
ORDER BY 
    Year ASC, CAST(Month AS UNSIGNED) ASC;
--  Sales data were only recorded for the first 5 months of 2005, in contrast to 2003 and 2004, which have sales data recorded for all 12 months.



-- QUESTION 3. Which month experienced the highest sales? What was the revenue during that month? --
SELECT
    MONTH_ID,
    PRODUCTLINE,
    SUM(SALES) as Revenue,
    COUNT(ORDERNUMBER) as Number_of_Orders
FROM
    sales_data
WHERE
    YEAR_ID = 2003 AND MONTH_ID = 11 -- for 2003
GROUP BY
    MONTH_ID, PRODUCTLINE
ORDER BY
    Revenue DESC;

SELECT
    MONTH_ID,
    PRODUCTLINE,
    SUM(SALES) as Revenue,
    COUNT(ORDERNUMBER) as Number_of_Orders
FROM
    sales_data
WHERE
    YEAR_ID = 2004 AND MONTH_ID = 11 -- for 2004
GROUP BY
    MONTH_ID, PRODUCTLINE
ORDER BY
    Revenue DESC;
-- November stands out as the month with the highest sales for both 2003 and 2004.
-- Classic Cars is the product line that sold the most in November of 2003 and 2004. 
-- Trains, as in the question 1, remains the product line with the smallest sales.



-- QUESTION 4. Which country achieved the highest product sales? -- 
SELECT 
    COUNTRY,
    ROUND(SUM(SALES), 3) as Revenue
FROM 
    sales_data
GROUP BY 
    COUNTRY
ORDER BY 
    Revenue DESC;
-- United States achieved the highest product sales, generating a revenue of $3,627,982.83. 
-- Following USA, Spain and France secured the second and third positions respectively



-- QUESTION 5. Who stands out as the top customer? --

-- Convert string dates to date data types
UPDATE sales_data
SET ORDERDATE = STR_TO_DATE(ORDERDATE, '%m/%d/%Y %H:%i');

-- Calculate Recency (R), Frequency (F), and Monetary Value (M) for each customer
WITH customer_rfm AS (
    SELECT
        CUSTOMERNAME as CustomerName,
        MAX(ORDERDATE) as LastPurchaseDate,
        COUNT(ORDERNUMBER) as NumberOfTransactions,
        SUM(SALES) AS MoneyValue
    FROM
        sales_data
    GROUP BY
        CUSTOMERNAME
)

-- Calculate Recency
SELECT
    CustomerName,
    LastPurchaseDate,
    DATEDIFF(CURRENT_DATE, LastPurchaseDate) as Recency,
    NumberOfTransactions,
    MoneyValue
FROM
    customer_rfm
ORDER BY
    MoneyValue DESC;
-- Customers like "Euro Shopping Channel" and "Mini Gifts Distributors Ltd." made purchases relatively recently.
-- "Euro Shopping Channel" and "Mini Gifts Distributors Ltd." have high frequencies, indicating they made numerous purchases.
-- Customers like "Bavarian Collectables Imports, Co." and "Boards & Toys Co." have lower frequencies, suggesting they made fewer purchases.
-- "Euro Shopping Channel" and "Mini Gifts Distributors Ltd." have made significant monetary contributions. 
-- "Boards & Toys Co." and "Atelier graphique" have lower total spending.sales_datasales_data



-- QUESTION 6. What products are usually sold together? --
WITH TransactionItems AS (
    -- Identifying transaction items (products) for each order along with product line
    SELECT s.ORDERNUMBER, s.PRODUCTCODE, s.PRODUCTLINE
    FROM sales_data s
),
OrderSummary AS (
    -- Aggregating transaction data to summarize products purchased together in each order
    SELECT ORDERNUMBER, GROUP_CONCAT(PRODUCTCODE ORDER BY PRODUCTCODE) AS ProductList
    FROM TransactionItems
    GROUP BY ORDERNUMBER
),
ProductPairs AS (
    -- Generating all possible pairs of products within each order along with product lines
    SELECT o1.ORDERNUMBER, p1.PRODUCTCODE AS Product1, p1.PRODUCTLINE AS ProductLine1,
           p2.PRODUCTCODE AS Product2, p2.PRODUCTLINE AS ProductLine2
    FROM OrderSummary o1
    JOIN TransactionItems p1 ON o1.ORDERNUMBER = p1.ORDERNUMBER
    JOIN TransactionItems p2 ON o1.ORDERNUMBER = p2.ORDERNUMBER
    WHERE p1.PRODUCTCODE < p2.PRODUCTCODE -- Ensure unique pairs
)
-- Counting occurrences of each product pair across all orders
SELECT Product1, ProductLine1, Product2, ProductLine2, COUNT(*) AS PairFrequency
FROM ProductPairs
GROUP BY Product1, ProductLine1, Product2, ProductLine2
ORDER BY PairFrequency DESC;
