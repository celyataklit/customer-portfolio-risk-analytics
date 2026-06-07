/* ============================================================
   PROJECT: Customer & Portfolio Risk Analytics Platform
   FILE: 03_risk_monitoring_analytics.sql

   PURPOSE:
   This script focuses on portfolio risk monitoring,
   customer behavior analysis, and transaction risk indicators.

   BUSINESS OBJECTIVE:
   Detect unusual transaction activity, monitor portfolio exposure,
   identify dormant customers, and support financial risk analytics.

   SKILLS DEMONSTRATED:
   - Advanced SQL analytics
   - Risk monitoring
   - Window functions
   - CTEs
   - Financial behavior analysis
   - Portfolio exposure monitoring
   - Business intelligence analytics
   ============================================================ */
   
   /* ------------------------------------------------------------
   1. High Value Transactions Detection
   Purpose:
   Identifies unusually large transactions across the portfolio.

   Business Value:
   Supports transaction monitoring, risk management,
   and suspicious activity detection.
   ------------------------------------------------------------ */

SELECT

    TransactionID,
    CustomerID,
    CustLocation,
    TransactionDate,
    TransactionAmount

FROM bank_transactions

WHERE TransactionAmount >

(
    SELECT AVG(TransactionAmount) * 5
    FROM bank_transactions
)

ORDER BY TransactionAmount DESC;

/* ------------------------------------------------------------
   2. Dormant Customers Identification
   Purpose:
   Identifies customers with very low transaction activity.

   Business Value:
   Helps monitor inactive customers and supports
   customer retention strategies.
   ------------------------------------------------------------ */

SELECT

    CustomerID,

    COUNT(TransactionID) AS total_transactions,

    ROUND(SUM(TransactionAmount), 2) AS total_spending

FROM bank_transactions

GROUP BY CustomerID

HAVING COUNT(TransactionID) <= 2;

/* ------------------------------------------------------------
   3. Portfolio Exposure by Location
   Purpose:
   Measures total account balance exposure by geographic area.

   Business Value:
   Supports geographic concentration risk monitoring.
   ------------------------------------------------------------ */

SELECT

    CustLocation,

    ROUND(SUM(CustAccountBalance), 2) AS total_location_exposure,

    COUNT(DISTINCT CustomerID) AS total_customers

FROM bank_transactions

GROUP BY CustLocation

ORDER BY total_location_exposure DESC;

/* ------------------------------------------------------------
   4. Rolling Transaction Average
   Purpose:
   Calculates moving average transaction values per customer.

   Business Value:
   Supports customer behavior trend analysis and
   transaction pattern monitoring.
   ------------------------------------------------------------ */

SELECT

    CustomerID,
    TransactionDate,
    TransactionAmount,

    ROUND(
        AVG(TransactionAmount) OVER(
            PARTITION BY CustomerID
            ORDER BY TransactionDate
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ),
        2
    ) AS rolling_avg_transaction

FROM bank_transactions;

/* ------------------------------------------------------------
   5. Top Risk Exposure Customers
   Purpose:
   Identifies customers with the highest account balances.

   Business Value:
   Supports portfolio exposure monitoring and high-value
   customer risk assessment.
   ------------------------------------------------------------ */

SELECT

    CustomerID,

    MAX(CustAccountBalance) AS max_balance,

    DENSE_RANK() OVER(
        ORDER BY MAX(CustAccountBalance) DESC
    ) AS exposure_rank

FROM bank_transactions

GROUP BY CustomerID

LIMIT 20;