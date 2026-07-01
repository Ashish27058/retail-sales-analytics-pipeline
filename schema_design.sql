-- =============================================================================
-- DBT Model  : fact_sales.sql
-- Schema     : ANALYTICS
-- Project    : Retail Sales Analytics Pipeline
-- Engineer   : Ashish Peddineni | eCloud Optimum Corp
-- Description: Central fact table. Joins staging models to dimension tables
--              and computes gross profit and margin. Incremental load by
--              ORDER_DATE to support daily updates efficiently.
-- =============================================================================

{{
    config(
        materialized     = 'incremental',
        unique_key       = 'ORDER_ID',
        incremental_strategy = 'merge',
        cluster_by       = ['ORDER_DATE_SK', 'REGION_SK'],
        tags             = ['marts', 'daily'],
        on_schema_change = 'append_new_columns'
    )
}}

WITH stg_orders AS (
    SELECT * FROM {{ ref('stg_sales_orders') }}
    {% if is_incremental() %}
    WHERE ORDER_DATE >= (SELECT MAX(ORDER_DATE_SK)::VARCHAR FROM {{ this }})::DATE
    {% endif %}
),

dim_customers AS (
    SELECT * FROM {{ ref('dim_customers') }}
    WHERE IS_CURRENT = TRUE
),

dim_products AS (
    SELECT * FROM {{ ref('dim_products') }}
    WHERE IS_CURRENT = TRUE
),

dim_date AS (
    SELECT * FROM {{ ref('dim_date') }}
),

dim_region AS (
    SELECT * FROM {{ ref('dim_region') }}
),

joined AS (
    SELECT
        -- Surrogate keys
        d.DATE_SK                                         AS ORDER_DATE_SK,
        c.CUSTOMER_SK,
        p.PRODUCT_SK,
        r.REGION_SK,

        -- Degenerate dimensions
        o.ORDER_ID,
        o.SALES_CHANNEL,
        o.STATUS                                          AS ORDER_STATUS,

        -- Measures
        o.QUANTITY,
        o.UNIT_PRICE,
        o.DISCOUNT_PCT,
        o.GROSS_REVENUE,
        o.NET_REVENUE,
        p.UNIT_COST,
        o.NET_REVENUE - (o.QUANTITY * p.UNIT_COST)        AS GROSS_PROFIT,
        CASE
            WHEN o.NET_REVENUE = 0 THEN 0
            ELSE ROUND(
                (o.NET_REVENUE - (o.QUANTITY * p.UNIT_COST)) / NULLIF(o.NET_REVENUE, 0) * 100,
                2
            )
        END                                               AS GROSS_MARGIN_PCT,

        -- Audit
        CURRENT_TIMESTAMP()                               AS DW_CREATED_AT,
        CURRENT_TIMESTAMP()                               AS DW_UPDATED_AT

    FROM stg_orders o
    LEFT JOIN dim_customers c ON o.CUSTOMER_ID = c.CUSTOMER_ID
    LEFT JOIN dim_products  p ON o.PRODUCT_ID  = p.PRODUCT_ID
    LEFT JOIN dim_date      d ON o.ORDER_DATE  = d.FULL_DATE
    LEFT JOIN dim_region    r ON o.REGION      = r.REGION_NAME
)

SELECT * FROM joined
