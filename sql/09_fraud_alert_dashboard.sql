/* ============================================================
   PROJECT: Customer & Portfolio Risk Analytics Platform
   FILE: 09_fraud_alert_dashboard.sql

   PURPOSE:
   Create a fraud alert dashboard view for Power BI.

   BUSINESS OBJECTIVE:
   Prioritize suspicious transactions and help risk teams monitor
   fraud alerts, high-risk customers, and unusual transaction behavior.

   SKILLS DEMONSTRATED:
   - CTEs
   - Window functions
   - Fraud alert prioritization
   - Risk ranking
   - Power BI reporting preparation
   ============================================================ */

USE customer_portfolio_analytics;

CREATE OR REPLACE VIEW vw_fraud_alert_dashboard AS

WITH alerts AS (

    SELECT
        t.TransactionID,
        t.CustomerID,
        t.CustLocation,
        t.TransactionDate,
        t.TransactionAmount,
        a.anomaly_flag,
        r.risk_score,
        r.risk_category,

        CASE
            WHEN a.anomaly_flag <> 'Normal'
                 AND r.risk_category = 'High Risk'
                THEN 'Critical Alert'

            WHEN a.anomaly_flag <> 'Normal'
                 AND r.risk_category = 'Medium Risk'
                THEN 'High Alert'

            WHEN a.anomaly_flag <> 'Normal'
                THEN 'Medium Alert'

            ELSE 'No Alert'
        END AS alert_priority

    FROM bank_transactions t

    LEFT JOIN vw_transaction_anomaly_detection a
        ON t.TransactionID = a.TransactionID

    LEFT JOIN vw_customer_risk_scoring r
        ON t.CustomerID = r.CustomerID
),

ranked_alerts AS (

    SELECT
        *,

        ROW_NUMBER() OVER (
            PARTITION BY alert_priority
            ORDER BY TransactionAmount DESC
        ) AS alert_rank,

        DENSE_RANK() OVER (
            ORDER BY risk_score DESC
        ) AS customer_risk_rank,

        PERCENT_RANK() OVER (
            ORDER BY TransactionAmount
        ) AS transaction_percent_rank

    FROM alerts
)

SELECT
    *

FROM ranked_alerts

WHERE alert_priority <> 'No Alert';