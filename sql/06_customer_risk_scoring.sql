/* ============================================================
   PROJECT: Customer & Portfolio Risk Analytics Platform
   FILE: 06_customer_risk_scoring.sql

   PURPOSE:
   Build a customer-level risk scoring model using SQL.

   BUSINESS OBJECTIVE:
   Identify high-risk customers based on transaction behavior,
   portfolio exposure, activity frequency, and unusual transaction patterns.

   SKILLS DEMONSTRATED:
   - CTEs
   - Window functions
   - Risk scoring logic
   - Customer profiling
   - Fraud / risk monitoring analytics
   ============================================================ */

USE customer_portfolio_analytics;


/* ------------------------------------------------------------
   1. Customer Risk Scoring View
   ------------------------------------------------------------ */

CREATE OR REPLACE VIEW vw_customer_risk_scoring AS

WITH customer_metrics AS (

    SELECT
        CustomerID,
        CustLocation,

        COUNT(TransactionID) AS total_transactions,
        ROUND(SUM(TransactionAmount), 2) AS total_transaction_volume,
        ROUND(AVG(TransactionAmount), 2) AS avg_transaction_amount,
        MAX(TransactionAmount) AS max_transaction_amount,
        MAX(CustAccountBalance) AS account_balance,

        COUNT(
            CASE
                WHEN TransactionAmount > (
                    SELECT AVG(TransactionAmount) * 5
                    FROM bank_transactions
                )
                THEN 1
            END
        ) AS high_value_transaction_count

    FROM bank_transactions

    GROUP BY
        CustomerID,
        CustLocation
),

risk_scoring AS (

    SELECT
        CustomerID,
        CustLocation,
        total_transactions,
        total_transaction_volume,
        avg_transaction_amount,
        max_transaction_amount,
        account_balance,
        high_value_transaction_count,

        CASE
            WHEN total_transaction_volume >= 100000 THEN 30
            WHEN total_transaction_volume >= 50000 THEN 20
            ELSE 10
        END
        +
        CASE
            WHEN high_value_transaction_count >= 3 THEN 30
            WHEN high_value_transaction_count BETWEEN 1 AND 2 THEN 20
            ELSE 0
        END
        +
        CASE
            WHEN account_balance >= 100000 THEN 20
            WHEN account_balance >= 50000 THEN 10
            ELSE 0
        END
        +
        CASE
            WHEN total_transactions <= 2 THEN 10
            ELSE 0
        END AS risk_score

    FROM customer_metrics
)

SELECT
    *,

    CASE
        WHEN risk_score >= 70 THEN 'High Risk'
        WHEN risk_score BETWEEN 40 AND 69 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS risk_category

FROM risk_scoring;