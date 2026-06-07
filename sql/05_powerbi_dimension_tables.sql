/* ============================================================
   PROJECT: Customer & Portfolio Risk Analytics Platform
   FILE: 05_powerbi_dimension_tables.sql

   PURPOSE:
   Create dimension tables used for Power BI star-schema modeling.

   BUSINESS OBJECTIVE:
   Improve dashboard performance, scalability, filtering logic,
   and analytical structure using dimensional modeling.

   SKILLS DEMONSTRATED:
   - Dimensional modeling
   - Star schema architecture
   - Data warehouse concepts
   - Power BI optimization
   ============================================================ */

USE customer_portfolio_analytics;


/* ------------------------------------------------------------
   1. Customer Dimension
   Purpose:
   Create a unique customer reference table used for
   customer-level analysis and filtering.
   ------------------------------------------------------------ */

CREATE OR REPLACE VIEW dim_customer AS

SELECT
    CustomerID,
    MAX(CustGender) AS CustGender,
    MAX(CustomerDOB) AS CustomerDOB,
    MAX(CustLocation) AS CustLocation

FROM bank_transactions

GROUP BY CustomerID;


/* ------------------------------------------------------------
   2. Location Dimension
   Purpose:
   Create a geographical dimension table for location-based
   portfolio analysis and filtering.
   ------------------------------------------------------------ */

CREATE OR REPLACE VIEW dim_location AS

SELECT DISTINCT
    CustLocation

FROM bank_transactions;


/* ------------------------------------------------------------
   3. Date Dimension
   Purpose:
   Create a calendar dimension used for time-series analysis,
   trend monitoring, and dashboard filtering.
   ------------------------------------------------------------ */

CREATE OR REPLACE VIEW dim_date AS

SELECT DISTINCT
    TransactionDate,
    YEAR(TransactionDate) AS transaction_year,
    MONTH(TransactionDate) AS transaction_month

FROM bank_transactions;

/* ------------------------------------------------------------
   4. Transaction Fact Table
   Purpose:
   Create the central fact table for Power BI star schema.
   ------------------------------------------------------------ */

CREATE OR REPLACE VIEW fact_transactions AS

SELECT
    TransactionID,
    CustomerID,
    CustLocation,
    TransactionDate,
    TransactionAmount,
    CustAccountBalance

FROM bank_transactions;