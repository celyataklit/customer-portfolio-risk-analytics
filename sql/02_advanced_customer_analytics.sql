

/* ============================================================
   PROJECT: Customer & Portfolio Risk Analytics Platform
   FILE: 02_advanced_customer_analytics.sql

   PURPOSE:
   This script performs advanced customer analytics using
   SQL window functions, ranking functions, cumulative metrics,
   and customer behavior monitoring techniques.

   BUSINESS OBJECTIVE:
   Identify high-value customers, monitor transaction behavior,
   analyze customer activity trends, and support portfolio
   decision-making.

   SKILLS DEMONSTRATED:
   - Common Table Expressions (CTE)
   - Window Functions
   - ROW_NUMBER()
   - RANK()
   - LAG()
   - Running totals
   - Customer analytics
   - Financial behavior analysis
   ============================================================ */
   
   /* ------------------------------------------------------------
   1. Latest Transaction Per Customer
   Purpose:
   Identifies the most recent transaction for each customer
   using ROW_NUMBER() window function.

   Business Value:
   Helps monitor recent customer activity and identify
   active customer behavior.
   ------------------------------------------------------------ */

WITH latest_transactions AS (

    SELECT

        CustomerID,
        TransactionDate,
        TransactionAmount,

        ROW_NUMBER() OVER(
            PARTITION BY CustomerID
            ORDER BY TransactionDate DESC
        ) AS transaction_rank

    FROM bank_transactions

)

SELECT *

FROM latest_transactions

WHERE transaction_rank = 1;

/* ------------------------------------------------------------
   2. Running Transaction Total Per Customer
   Purpose:
   Calculates cumulative transaction value for each customer
   over time using SUM() OVER().

   Business Value:
   Supports customer lifetime value analysis and portfolio
   monitoring.
   ------------------------------------------------------------ */

SELECT

    CustomerID,
    TransactionDate,
    TransactionAmount,

    SUM(TransactionAmount) OVER(
        PARTITION BY CustomerID
        ORDER BY TransactionDate
    ) AS cumulative_transaction_total

FROM bank_transactions;

/* ------------------------------------------------------------
   3. Compare Current Transaction with Previous Transaction
   Purpose:
   Uses LAG() to compare the current transaction amount
   with the previous customer transaction.

   Business Value:
   Helps identify unusual changes in customer transaction
   behavior and spending patterns.
   ------------------------------------------------------------ */

SELECT

    CustomerID,
    TransactionDate,
    TransactionAmount,

    LAG(TransactionAmount) OVER(
        PARTITION BY CustomerID
        ORDER BY TransactionDate
    ) AS previous_transaction_amount

FROM bank_transactions;

/* ------------------------------------------------------------
   4. Customer Spending Ranking by Location
   Purpose:
   Ranks customers by transaction volume within each location.

   Business Value:
   Helps identify top-performing customers across regions
   and supports geographic portfolio analysis.
   ------------------------------------------------------------ */

SELECT

    CustLocation,
    CustomerID,

    ROUND(SUM(TransactionAmount), 2) AS total_spending,

    RANK() OVER(
        PARTITION BY CustLocation
        ORDER BY SUM(TransactionAmount) DESC
    ) AS location_rank

FROM bank_transactions

GROUP BY
    CustLocation,
    CustomerID;
    
    

