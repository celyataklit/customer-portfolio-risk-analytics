/* ============================================================
   PROJECT: Customer & Portfolio Risk Analytics Platform
   FILE: 07_transaction_anomaly_detection.sql

   PURPOSE:
   Detect unusual customer transaction behavior using SQL analytics.

   BUSINESS OBJECTIVE:
   Support fraud prevention, portfolio monitoring, and alert prioritization.

   SKILLS DEMONSTRATED:
   - CTEs
   - LAG()
   - AVG() OVER()
   - Behavioral anomaly detection
   - Transaction monitoring logic
   ============================================================ */

USE customer_portfolio_analytics;


/* ------------------------------------------------------------
   1. Transaction Anomaly Detection
   ------------------------------------------------------------ */

CREATE OR REPLACE VIEW vw_transaction_anomaly_detection AS

WITH transaction_behavior AS (

    SELECT
        TransactionID,
        CustomerID,
        CustLocation,
        TransactionDate,
        TransactionAmount,

        AVG(TransactionAmount) OVER (
            PARTITION BY CustomerID
        ) AS customer_avg_transaction_amount,

        LAG(TransactionAmount) OVER (
            PARTITION BY CustomerID
            ORDER BY TransactionDate
        ) AS previous_transaction_amount

    FROM bank_transactions
)

SELECT
    TransactionID,
    CustomerID,
    CustLocation,
    TransactionDate,
    TransactionAmount,
    ROUND(customer_avg_transaction_amount, 2) AS customer_avg_transaction_amount,
    previous_transaction_amount,

    CASE
        WHEN TransactionAmount > customer_avg_transaction_amount * 3
            THEN 'Unusual High Transaction'

        WHEN previous_transaction_amount IS NOT NULL
             AND TransactionAmount > previous_transaction_amount * 4
            THEN 'Sudden Spending Increase'

        ELSE 'Normal'
    END AS anomaly_flag

FROM transaction_behavior;