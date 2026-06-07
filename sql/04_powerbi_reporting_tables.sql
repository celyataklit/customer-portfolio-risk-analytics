/* ============================================================
   PROJECT: Customer & Portfolio Risk Analytics Platform
   FILE: 04_powerbi_reporting_tables.sql

   PURPOSE:
   This script creates analytical reporting tables designed
   for Power BI dashboard development.

   BUSINESS OBJECTIVE:
   Prepare clean and aggregated datasets for executive reporting,
   customer segmentation, portfolio monitoring, and financial
   analytics visualization.

   SKILLS DEMONSTRATED:
   - SQL aggregation
   - Reporting table creation
   - Business intelligence preparation
   - Financial analytics
   - Dashboard-oriented SQL
   ============================================================ */

USE customer_portfolio_analytics;

/* ------------------------------------------------------------
   1. Customer Segmentation Reporting Table
   ------------------------------------------------------------ */

CREATE OR REPLACE VIEW vw_customer_segmentation AS

SELECT

    CustomerID,
    CustLocation,

    ROUND(SUM(TransactionAmount), 2) AS total_spending,

    COUNT(TransactionID) AS total_transactions,

    ROUND(AVG(TransactionAmount), 2) AS avg_transaction_amount,

    MAX(CustAccountBalance) AS account_balance,

    CASE

    WHEN SUM(TransactionAmount) >= 20000 THEN 'High Value'

    WHEN SUM(TransactionAmount) BETWEEN 5000 AND 19999
        THEN 'Medium Value'

    ELSE 'Low Value'

    END AS customer_segment

FROM bank_transactions

GROUP BY
    CustomerID,
    CustLocation;
    
/* ------------------------------------------------------------
   2. Monthly Portfolio Trends Reporting Table
   Purpose:
   Aggregates monthly transaction activity and portfolio KPIs.

   Business Value:
   Supports executive portfolio monitoring and
   transaction trend analysis.
   ------------------------------------------------------------ */

CREATE OR REPLACE VIEW vw_monthly_portfolio_trends AS

SELECT

    YEAR(TransactionDate) AS transaction_year,

    MONTH(TransactionDate) AS transaction_month,

    COUNT(*) AS total_transactions,

    ROUND(SUM(TransactionAmount), 2) AS total_volume,

    ROUND(AVG(TransactionAmount), 2) AS avg_transaction_amount,

    ROUND(SUM(CustAccountBalance), 2) AS portfolio_exposure

FROM bank_transactions

GROUP BY
    YEAR(TransactionDate),
    MONTH(TransactionDate);
    
/* ------------------------------------------------------------
   3. Geographic Portfolio Exposure Reporting Table
   Purpose:
   Measures portfolio exposure by customer location.

   Business Value:
   Supports geographic analytics and concentration
   risk monitoring.
   ------------------------------------------------------------ */

CREATE OR REPLACE VIEW vw_geographic_exposure AS

SELECT

    CustLocation,

    COUNT(DISTINCT CustomerID) AS total_customers,

    ROUND(SUM(TransactionAmount), 2) AS total_transaction_volume,

    ROUND(SUM(CustAccountBalance), 2) AS total_exposure

FROM bank_transactions

GROUP BY CustLocation;

/* ------------------------------------------------------------
   4. High Value Customers Reporting Table
   Purpose:
   Identifies top-performing customers by transaction activity.

   Business Value:
   Supports customer prioritization and high-value
   portfolio monitoring.
   ------------------------------------------------------------ */

CREATE OR REPLACE VIEW vw_high_value_customers AS

SELECT

    CustomerID,

    CustLocation,

    ROUND(SUM(TransactionAmount), 2) AS total_spending,

    MAX(CustAccountBalance) AS account_balance,

    DENSE_RANK() OVER(
        ORDER BY SUM(TransactionAmount) DESC
    ) AS spending_rank

FROM bank_transactions

GROUP BY
    CustomerID,
    CustLocation;

SHOW FULL TABLES
WHERE Table_type = 'VIEW';

SELECT *
FROM vw_monthly_portfolio_trends
LIMIT 10;

SELECT *
FROM vw_geographic_exposure
LIMIT 10;

SELECT *
FROM vw_high_value_customers
LIMIT 10;
    
SELECT *
FROM vw_customer_segmentation
LIMIT 10;
    