-- =============================================================================
-- DBT Model  : stg_sales_orders.sql
-- Schema     : STAGING
-- Project    : Retail Sales Analytics Pipeline
-- Engineer   : Ashish Peddineni | eCloud Optimum Corp
-- Description: Cleanse and type-cast raw sales orders from RAW.SALES_ORDERS.
--              Compute derived revenue metrics. Apply data quality filters.
-- =============================================================================

WITH source AS (
    SELECT * FROM {{ source('raw', 'SALES_ORDERS') }}
),

cleansed AS (
    SELECT
        ORDER_ID,
        TRY_TO_DATE(ORDER_DATE, 'YYYY-MM-DD')           AS ORDER_DATE,
        TRIM(UPPER(CUSTOMER_ID))                          AS CUSTOMER_ID,
        TRIM(UPPER(PRODUCT_ID))                           AS PRODUCT_ID,
        TRY_TO_NUMBER(QUANTITY)::INTEGER                  AS QUANTITY,
        TRY_TO_DECIMAL(UNIT_PRICE, 18, 4)                AS UNIT_PRICE,
        COALESCE(TRY_TO_DECIMAL(DISCOUNT_PCT, 18, 4), 0) AS DISCOUNT_PCT,
        TRIM(UPPER(REGION))                               AS REGION,
        TRIM(UPPER(SALES_CHANNEL))                        AS SALES_CHANNEL,
        TRIM(UPPER(STATUS))                               AS STATUS,
        SOURCE_FILE,
        BATCH_ID,
        LOAD_TIMESTAMP::TIMESTAMP_NTZ                     AS LOAD_TIMESTAMP
    FROM source
    WHERE ORDER_ID IS NOT NULL
      AND CUSTOMER_ID IS NOT NULL
      AND PRODUCT_ID IS NOT NULL
),

with_metrics AS (
    SELECT
        *,
        QUANTITY * UNIT_PRICE                              AS GROSS_REVENUE,
        QUANTITY * UNIT_PRICE * (1 - DISCOUNT_PCT / 100)  AS NET_REVENUE,
        CURRENT_TIMESTAMP()                                AS DW_CREATED_AT
    FROM cleansed
    WHERE ORDER_DATE IS NOT NULL
      AND QUANTITY > 0
      AND UNIT_PRICE >= 0
),

-- Remove duplicates keeping latest loaded record
deduped AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY ORDER_ID
            ORDER BY LOAD_TIMESTAMP DESC
        ) AS row_num
    FROM with_metrics
)

SELECT
    ORDER_ID,
    ORDER_DATE,
    CUSTOMER_ID,
    PRODUCT_ID,
    QUANTITY,
    UNIT_PRICE,
    DISCOUNT_PCT,
    GROSS_REVENUE,
    NET_REVENUE,
    REGION,
    SALES_CHANNEL,
    STATUS,
    LOAD_TIMESTAMP,
    DW_CREATED_AT
FROM deduped
WHERE row_num = 1
