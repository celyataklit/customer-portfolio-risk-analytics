/* ============================================================
   PROJECT: Customer & Portfolio Risk Analytics Platform
   FILE: 01_portfolio_kpis.sql
   PURPOSE:
   This script calculates the main portfolio-level KPIs used to
   monitor customer activity, transaction volume, portfolio exposure,
   and business performance.

   DATASET:
   bank_transactions

   AUTHOR:
   Celya Taklit

   SKILLS DEMONSTRATED:
   - SQL aggregation
   - Business KPI calculation
   - Portfolio analytics
   - Financial transaction analysis
   ============================================================ */
   
   
   /* ------------------------------------------------------------
   1. Total Number of Transactions
   Purpose:
   Measures the total transaction activity available in the portfolio.
   This KPI gives a first view of dataset size and customer activity.
   ------------------------------------------------------------ */
SELECT
    COUNT(*) AS total_transactions
FROM bank_transactions;

/* ------------------------------------------------------------
   2. Total Number of Unique Customers
   Purpose:
   Identifies the number of distinct customers in the transaction base.
   This KPI is used to evaluate portfolio coverage.
   ------------------------------------------------------------ */

SELECT 
    COUNT(DISTINCT CustomerID) AS total_customers
FROM bank_transactions;

/* ------------------------------------------------------------
   3. Total Transaction Volume
   Purpose:
   Calculates the total monetary value processed across all transactions.
   This is a core business KPI for portfolio activity monitoring.
   ------------------------------------------------------------ */

SELECT 
    ROUND(SUM(TransactionAmount), 2) AS total_transaction_volume
FROM bank_transactions;


/* ------------------------------------------------------------
   4. Average Transaction Amount
   Purpose:
   Measures the average transaction size across the portfolio.
   This helps understand customer spending behavior.
   ------------------------------------------------------------ */
SELECT 
    ROUND(AVG(TransactionAmount), 2) AS avg_transaction_amount
FROM bank_transactions;

/* ------------------------------------------------------------
   5. Customer Segmentation by Transaction Value
   Purpose:
   Segments customers into High, Medium, and Low Value groups based
   on total transaction amount. This supports customer prioritization,
   portfolio monitoring, and business decision-making.
   ------------------------------------------------------------ */
	
SELECT
    CustomerID,
    ROUND(SUM(TransactionAmount), 2) AS total_customer_spending,
    CASE
        WHEN SUM(TransactionAmount) >= 100000 THEN 'High Value'
        WHEN SUM(TransactionAmount) BETWEEN 50000 AND 99999 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_segment
FROM bank_transactions
GROUP BY CustomerID;

/* ------------------------------------------------------------
   6. Top Customers Ranking
   Purpose:
   Ranks customers by total transaction value using RANK() OVER().
   ------------------------------------------------------------ */

SELECT
    CustomerID,
    ROUND(SUM(TransactionAmount), 2) AS total_spending,
    RANK() OVER(
        ORDER BY SUM(TransactionAmount) DESC
    ) AS customer_rank
FROM bank_transactions
GROUP BY CustomerID
LIMIT 20;



/* ------------------------------------------------------------
   7. Monthly Transaction Trends
   Purpose:
   Tracks monthly transaction count, total volume, and average amount.
   ------------------------------------------------------------ */

SELECT
    YEAR(TransactionDate) AS transaction_year,
    MONTH(TransactionDate) AS transaction_month,
    COUNT(*) AS total_transactions,
    ROUND(SUM(TransactionAmount), 2) AS monthly_transaction_volume,
    ROUND(AVG(TransactionAmount), 2) AS avg_transaction_amount
FROM bank_transactions
GROUP BY
    YEAR(TransactionDate),
    MONTH(TransactionDate)
ORDER BY
    transaction_year,
    transaction_month;
    