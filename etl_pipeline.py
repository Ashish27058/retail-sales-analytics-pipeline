"""
=============================================================================
Project  : Retail Sales Analytics Pipeline
Module   : etl_pipeline.py — Main ETL Orchestration
Engineer : Ashish Peddineni | eCloud Optimum Corp
Started  : 2025-01-22
=============================================================================
Description:
    End-to-end ETL pipeline that:
    1. Reads raw sales CSV files from Azure Blob Storage
    2. Validates schema and data quality
    3. Cleanses and transforms the data (deduplication, type casting, etc.)
    4. Loads cleansed records into Snowflake RAW schema via COPY INTO
    5. Logs audit records and alerts on failures

Dependencies:
    pip install pandas snowflake-connector-python azure-storage-blob
                python-dotenv boto3 great-expectations
=============================================================================
"""

import os
import uuid
import logging
from datetime import datetime, date
from typing import Optional

import pandas as pd
import numpy as np
from dotenv import load_dotenv
import snowflake.connector
from snowflake.connector.pandas_tools import write_pandas
from azure.storage.blob import BlobServiceClient

# ---------------------------------------------------------------------------
# Configuration & Logging
# ---------------------------------------------------------------------------
load_dotenv()
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(name)s | %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
logger = logging.getLogger("RetailETL")

BATCH_ID: str = str(uuid.uuid4())
RUN_DATE: str = datetime.utcnow().strftime("%Y-%m-%d")


# ---------------------------------------------------------------------------
# Snowflake Connection Manager
# ---------------------------------------------------------------------------
class SnowflakeConnection:
    """Context manager that handles Snowflake connection lifecycle."""

    def __init__(self):
        self.conn = None
        self.cursor = None

    def __enter__(self):
        logger.info("Connecting to Snowflake...")
        self.conn = snowflake.connector.connect(
            account=os.environ["SNOWFLAKE_ACCOUNT"],
            user=os.environ["SNOWFLAKE_USER"],
            password=os.environ["SNOWFLAKE_PASSWORD"],
            warehouse=os.environ.get("SNOWFLAKE_WH", "ETL_WH"),
            database=os.environ.get("SNOWFLAKE_DB", "RETAIL_ANALYTICS_DB"),
            schema="RAW",
            role=os.environ.get("SNOWFLAKE_ROLE", "ETL_ROLE"),
            session_parameters={
                "QUERY_TAG": f"ETL_PIPELINE | BATCH_ID={BATCH_ID}",
                "TIMEZONE": "UTC",
            },
        )
        self.cursor = self.conn.cursor()
        logger.info("Snowflake connected successfully.")
        return self.conn, self.cursor

    def __exit__(self, exc_type, exc_val, exc_tb):
        if self.cursor:
            self.cursor.close()
        if self.conn:
            self.conn.close()
        logger.info("Snowflake connection closed.")


# ---------------------------------------------------------------------------
# Azure Blob Storage Reader
# ---------------------------------------------------------------------------
class BlobStorageReader:
    """Reads CSV files from Azure Blob Storage."""

    def __init__(self, connection_string: str, container_name: str):
        self.client = BlobServiceClient.from_connection_string(connection_string)
        self.container = self.client.get_container_client(container_name)

    def list_blobs(self, prefix: str) -> list[str]:
        blobs = self.container.list_blobs(name_starts_with=prefix)
        return [b.name for b in blobs if b.name.endswith(".csv")]

    def read_csv(self, blob_name: str) -> pd.DataFrame:
        logger.info(f"Reading blob: {blob_name}")
        blob_client = self.container.get_blob_client(blob_name)
        raw_bytes = blob_client.download_blob().readall()
        df = pd.read_csv(
            pd.io.common.BytesIO(raw_bytes),
            dtype=str,                    # read everything as string first
            na_values=["", "NULL", "N/A", "#N/A"],
            keep_default_na=False,
        )
        df["_SOURCE_FILE"] = blob_name
        df["_BATCH_ID"] = BATCH_ID
        df["_LOAD_TIMESTAMP"] = datetime.utcnow().isoformat()
        logger.info(f"  → Loaded {len(df):,} rows from {blob_name}")
        return df


# ---------------------------------------------------------------------------
# Data Validation & Cleansing
# ---------------------------------------------------------------------------
class DataValidator:
    """Schema validation and data quality checks."""

    REQUIRED_COLUMNS = {
        "sales_orders": [
            "order_id", "order_date", "customer_id",
            "product_id", "quantity", "unit_price",
        ],
        "customers": [
            "customer_id", "first_name", "last_name", "email",
        ],
        "products": [
            "product_id", "product_name", "category", "list_price",
        ],
    }

    def validate_schema(self, df: pd.DataFrame, table: str) -> pd.DataFrame:
        """Assert required columns exist; raise ValueError if not."""
        required = self.REQUIRED_COLUMNS.get(table, [])
        missing = [c for c in required if c not in df.columns]
        if missing:
            raise ValueError(f"[{table}] Missing required columns: {missing}")
        logger.info(f"[{table}] Schema validation PASSED — {len(df.columns)} columns present")
        return df

    def validate_not_null(self, df: pd.DataFrame, cols: list, table: str) -> pd.DataFrame:
        """Drop rows with nulls in critical columns; log count."""
        before = len(df)
        df = df.dropna(subset=cols)
        dropped = before - len(df)
        if dropped > 0:
            logger.warning(f"[{table}] Dropped {dropped:,} rows with nulls in {cols}")
        return df

    def validate_uniqueness(self, df: pd.DataFrame, key_col: str, table: str) -> pd.DataFrame:
        """Keep first occurrence of duplicates; log count."""
        before = len(df)
        df = df.drop_duplicates(subset=[key_col], keep="first")
        dupes = before - len(df)
        if dupes > 0:
            logger.warning(f"[{table}] Removed {dupes:,} duplicate {key_col} values")
        return df

    def validate_numeric_range(
        self,
        df: pd.DataFrame,
        col: str,
        min_val: float,
        max_val: float,
        table: str,
    ) -> pd.DataFrame:
        """Flag rows outside expected numeric range."""
        numeric = pd.to_numeric(df[col], errors="coerce")
        out_of_range = ((numeric < min_val) | (numeric > max_val)).sum()
        if out_of_range > 0:
            logger.warning(f"[{table}] {out_of_range:,} rows have {col} outside [{min_val}, {max_val}]")
        return df


# ---------------------------------------------------------------------------
# Sales Orders Transformer
# ---------------------------------------------------------------------------
class SalesOrdersTransformer:
    """Transforms raw sales orders DataFrame for Snowflake RAW load."""

    def __init__(self):
        self.validator = DataValidator()

    def transform(self, df: pd.DataFrame) -> pd.DataFrame:
        logger.info(f"Transforming sales orders: {len(df):,} rows")

        # Column name normalisation
        df.columns = [c.strip().lower().replace(" ", "_") for c in df.columns]

        # Schema validation
        df = self.validator.validate_schema(df, "sales_orders")

        # Not-null enforcement on business keys
        df = self.validator.validate_not_null(
            df, ["order_id", "customer_id", "product_id", "order_date"], "sales_orders"
        )

        # Deduplication
        df = self.validator.validate_uniqueness(df, "order_id", "sales_orders")

        # Numeric cleansing
        df["quantity"] = pd.to_numeric(df["quantity"], errors="coerce").fillna(0).astype(int)
        df["unit_price"] = pd.to_numeric(df["unit_price"], errors="coerce").fillna(0.0).round(4)
        df["discount_pct"] = pd.to_numeric(df.get("discount_pct", 0), errors="coerce").fillna(0.0).round(4)

        # Date normalisation
        df["order_date"] = pd.to_datetime(df["order_date"], errors="coerce").dt.strftime("%Y-%m-%d")

        # String normalisation
        df["region"] = df.get("region", "UNKNOWN").fillna("UNKNOWN").str.upper().str.strip()
        df["status"] = df.get("status", "PENDING").fillna("PENDING").str.upper().str.strip()
        df["sales_channel"] = df.get("sales_channel", "ONLINE").fillna("ONLINE").str.upper().str.strip()

        # Rename for Snowflake target
        df = df.rename(columns={
            "order_id": "ORDER_ID",
            "order_date": "ORDER_DATE",
            "customer_id": "CUSTOMER_ID",
            "product_id": "PRODUCT_ID",
            "quantity": "QUANTITY",
            "unit_price": "UNIT_PRICE",
            "discount_pct": "DISCOUNT_PCT",
            "region": "REGION",
            "sales_channel": "SALES_CHANNEL",
            "status": "STATUS",
            "_source_file": "SOURCE_FILE",
            "_batch_id": "BATCH_ID",
            "_load_timestamp": "LOAD_TIMESTAMP",
        })

        logger.info(f"Sales orders transformation complete: {len(df):,} clean rows")
        return df[[
            "ORDER_ID", "ORDER_DATE", "CUSTOMER_ID", "PRODUCT_ID",
            "QUANTITY", "UNIT_PRICE", "DISCOUNT_PCT", "REGION",
            "SALES_CHANNEL", "STATUS", "SOURCE_FILE", "BATCH_ID", "LOAD_TIMESTAMP",
        ]]


# ---------------------------------------------------------------------------
# Snowflake Loader
# ---------------------------------------------------------------------------
class SnowflakeLoader:
    """Bulk-loads a pandas DataFrame into a Snowflake table."""

    def __init__(self, conn, cursor):
        self.conn = conn
        self.cursor = cursor

    def load(self, df: pd.DataFrame, target_table: str) -> int:
        """Use write_pandas for bulk COPY INTO via internal stage."""
        if df.empty:
            logger.warning(f"[{target_table}] Empty DataFrame — skipping load")
            return 0

        logger.info(f"[{target_table}] Loading {len(df):,} rows...")
        success, nchunks, nrows, output = write_pandas(
            conn=self.conn,
            df=df,
            table_name=target_table,
            schema="RAW",
            database="RETAIL_ANALYTICS_DB",
            auto_create_table=False,
            overwrite=False,
            chunk_size=100_000,
            compression="gzip",
        )

        if success:
            logger.info(f"[{target_table}] Successfully loaded {nrows:,} rows in {nchunks} chunks")
        else:
            logger.error(f"[{target_table}] Load failed. Output: {output}")
        return nrows

    def log_audit(self, table: str, rows_loaded: int, status: str, error: Optional[str] = None):
        sql = """
        INSERT INTO RETAIL_ANALYTICS_DB.AUDIT.PIPELINE_RUN_LOG
            (PIPELINE_NAME, RUN_ID, STATUS, START_TIME, ROWS_INSERTED, ERROR_MESSAGE)
        VALUES (%s, %s, %s, %s, %s, %s)
        """
        self.cursor.execute(sql, (
            "PL_RETAIL_SALES_INGESTION",
            BATCH_ID,
            status,
            datetime.utcnow(),
            rows_loaded,
            error,
        ))
        self.conn.commit()


# ---------------------------------------------------------------------------
# Main Orchestration
# ---------------------------------------------------------------------------
def run_etl():
    logger.info("=" * 70)
    logger.info(f"RETAIL SALES ETL PIPELINE START | BATCH_ID={BATCH_ID} | DATE={RUN_DATE}")
    logger.info("=" * 70)

    blob_reader = BlobStorageReader(
        connection_string=os.environ["AZURE_BLOB_CONNECTION_STRING"],
        container_name=os.environ.get("BLOB_CONTAINER", "retail-data"),
    )

    transformer = SalesOrdersTransformer()
    total_loaded = 0

    with SnowflakeConnection() as (conn, cursor):
        loader = SnowflakeLoader(conn, cursor)

        try:
            # ── SALES ORDERS ────────────────────────────────────────────────
            sales_blobs = blob_reader.list_blobs(prefix=f"sales/{RUN_DATE}/")
            if not sales_blobs:
                logger.warning("No sales order files found for today — checking yesterday")
                yesterday = (date.today() - pd.Timedelta(days=1)).strftime("%Y-%m-%d")
                sales_blobs = blob_reader.list_blobs(prefix=f"sales/{yesterday}/")

            sales_frames = [blob_reader.read_csv(b) for b in sales_blobs]
            if sales_frames:
                df_sales_raw = pd.concat(sales_frames, ignore_index=True)
                df_sales_clean = transformer.transform(df_sales_raw)
                rows = loader.load(df_sales_clean, "SALES_ORDERS")
                total_loaded += rows

            # ── AUDIT LOG ───────────────────────────────────────────────────
            loader.log_audit("SALES_ORDERS", total_loaded, "SUCCESS")

        except Exception as exc:
            logger.exception(f"ETL PIPELINE FAILED: {exc}")
            loader.log_audit("PIPELINE", 0, "FAILED", str(exc))
            raise

    logger.info(f"ETL PIPELINE COMPLETE | Total rows loaded: {total_loaded:,}")
    logger.info("=" * 70)
    return total_loaded


if __name__ == "__main__":
    run_etl()
