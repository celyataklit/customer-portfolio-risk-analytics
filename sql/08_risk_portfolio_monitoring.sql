CREATE OR REPLACE VIEW vw_risk_portfolio_monitoring AS

WITH customer_summary AS (

    SELECT
        CustomerID,

        COUNT(*) AS transaction_count,

        SUM(TransactionAmount) AS total_volume,

        AVG(TransactionAmount) AS avg_transaction,

        MAX(TransactionAmount) AS max_transaction

    FROM bank_transactions

    GROUP BY CustomerID
),

customer_ranking AS (

    SELECT
        *,

        RANK() OVER(
            ORDER BY total_volume DESC
        ) AS volume_rank,

        NTILE(5) OVER(
            ORDER BY total_volume DESC
        ) AS risk_bucket

    FROM customer_summary
)

SELECT
    *,
    CASE
        WHEN risk_bucket = 1 THEN 'Very High Exposure'
        WHEN risk_bucket = 2 THEN 'High Exposure'
        WHEN risk_bucket = 3 THEN 'Medium Exposure'
        ELSE 'Low Exposure'
    END AS portfolio_segment

FROM customer_ranking;