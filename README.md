# Retail Sales Analytics Pipeline
## eCloud Optimum Corp | Data Engineer: Ashish Peddineni

---

## Project Purpose

This repository contains all technical deliverables for the **Retail Sales Analytics Pipeline**, a production-grade cloud data engineering project developed by Ashish Peddineni in his role as Data Engineer at eCloud Optimum Corp (Princeton, NJ).

These materials are submitted as evidence for the **Motion to Reopen (MTR) filing** to demonstrate specialty occupation status, specifically addressing:
- **Point 2:** Enhanced technical position description with cloud architecture diagrams, Snowflake schema designs, and ADF pipeline workflows
- **Point 3:** Project deliverables, work products, and code commits demonstrating 20+ hrs/week of qualifying work
- **Point 6:** Technical documentation demonstrating degree-level specialization

---

## Repository Structure

```
retail-sales-analytics-pipeline/
│
├── Technical_Position_Description_Ashish_Peddineni.docx   ← SUBMIT THIS
│
├── architecture/
│   └── retail_pipeline_architecture.svg     ← System architecture diagram
│
├── snowflake/
│   └── schema_design.sql                    ← Full Snowflake DDL (RAW → STAGING → ANALYTICS)
│
├── adf/
│   └── retail_sales_pipeline.json           ← Azure Data Factory pipeline definition
│
├── python/
│   └── etl_pipeline.py                      ← Python ETL orchestration script
│
├── dbt/
│   ├── dbt_project.yml                      ← DBT project configuration
│   └── models/
│       ├── staging/
│       │   └── stg_sales_orders.sql         ← DBT staging model
│       └── marts/
│           └── fact_sales.sql               ← DBT incremental fact table
│
└── README.md                                ← This file
```

---

## Technology Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Orchestration | **Azure Data Factory** | Pipeline scheduling, Copy Activities, monitoring |
| Data Warehouse | **Snowflake** | Multi-schema DWH (RAW → STAGING → ANALYTICS) |
| ETL | **Python + pandas** | Data ingestion, validation, transformation |
| Transformation | **DBT** | SQL-based data modeling and testing |
| Source Storage | **Azure Blob Storage** | Sales CSV files |
| Source Storage | **AWS S3** | Product catalog CSV files |
| Workflow | **Apache Airflow** | DAG-based task orchestration |
| BI | **Power BI / Tableau** | Dashboards and reporting |
| Monitoring | **Datadog / Grafana** | Pipeline health and alerting |
| CI/CD | **Git + Jenkins** | Version control and deployment |
| Containers | **Docker** | Python app containerization |

---

## Pipeline Architecture

```
[Azure Blob] → ADF Copy Activity ─┐
[AWS S3]     → ADF Copy Activity ─┼→ Snowflake RAW → [Python ETL] → Snowflake STAGING → [DBT] → Snowflake ANALYTICS → Power BI
[On-Prem DB] → ADF Copy Activity ─┘
                                              ↕
                                     Audit Log (AUDIT schema)
                                              ↕
                                     Datadog Monitoring
```

---

## Snowflake Schema Design

### Three-Layer Medallion Architecture

| Schema | Tables | Purpose |
|--------|--------|---------|
| **RAW** | SALES_ORDERS, CUSTOMERS, PRODUCTS | Source-aligned raw ingestion |
| **STAGING** | STG_SALES_ORDERS, STG_CUSTOMERS, STG_PRODUCTS | Cleansed, typed, deduplicated |
| **ANALYTICS** | FACT_SALES, DIM_CUSTOMERS, DIM_PRODUCTS, DIM_DATE, DIM_REGION | Star-schema for BI |
| **AUDIT** | PIPELINE_RUN_LOG, DATA_QUALITY_RESULTS | Pipeline observability |

### Key Design Decisions
- **Clustering Keys** on FACT_SALES (ORDER_DATE_SK, REGION_SK) for BI query optimization
- **SCD Type 2** on DIM_CUSTOMERS and DIM_PRODUCTS for historical tracking
- **Generated Columns** for GROSS_REVENUE, NET_REVENUE, MARGIN_PCT
- **Multi-Cluster Warehouse** (ETL_WH) for parallel load scalability
- **RBAC** with ETL_ROLE, ANALYST_ROLE, DBT_ROLE following least-privilege principle

---

## How to Run

### Prerequisites
```bash
pip install pandas snowflake-connector-python azure-storage-blob python-dotenv
```

### Environment Variables (.env)
```
SNOWFLAKE_ACCOUNT=<your_account>
SNOWFLAKE_USER=<etl_user>
SNOWFLAKE_PASSWORD=<password>
AZURE_BLOB_CONNECTION_STRING=<connection_string>
```

### Deploy Snowflake Schema
```sql
-- Run in Snowflake SQL worksheet
\i snowflake/schema_design.sql
```

### Run Python ETL
```bash
python python/etl_pipeline.py
```

### Run DBT Models
```bash
cd dbt
dbt deps
dbt run --models staging
dbt run --models marts
dbt test
```

---


