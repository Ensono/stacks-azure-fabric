"""Example Spark job to create and transform Delta tables.

It creates a Delta table with sample data, saves it to a Silver lakehouse, and then transforms the data and saves it to a Gold lakehouse.

"""
import argparse
import logging

import pyspark.sql.functions as F
from pyspark.sql import SparkSession
from pyspark.sql.types import StructType, StructField, StringType, IntegerType


def add_handler(fmt: str, logger: logging.Logger) -> None:
    """Add a new StreamHandler with the specified format to the provided logger.

    Args:
        fmt: The format string to be used by the logging formatter.
        logger: The logger instance to which the handler will be added.
    """
    handler = logging.StreamHandler()
    handler.setLevel(logging.INFO)
    formatter = logging.Formatter(datefmt="%Y-%m-%d %H:%M:%S", fmt=fmt)
    handler.setFormatter(formatter)
    logger.addHandler(handler)


def get_logger(name: str) -> logging.Logger:
    """Creates a base logger.

    Args:
        name: The name of the logger.

    Returns:
        Logger instance.
    """
    fmt = "%(asctime)s - %(name)s - %(levelname)s - %(message)s"

    logger = logging.getLogger(name)
    logger.setLevel(logging.INFO)

    if not logger.handlers:
        add_handler(fmt, logger)

    return logger


logger = get_logger("example_spark_job")


def get_delta_table_path(workspace_id: str, lakehouse_id: str, table_name: str) -> str:
    """Constructs the Delta table path based on the provided workspace ID, lakehouse ID, and table name.

    Args:
        workspace_id: The ID of the workspace.
        lakehouse_id: The ID of the lakehouse.
        table_name: The name of the table.

    Returns:
        The full URI path to the Delta table.

    """
    return f"abfss://{workspace_id}@onelake.dfs.fabric.microsoft.com/{lakehouse_id}/Tables/dbo/{table_name}"


def create_delta_table(spark: SparkSession, delta_table_path: str) -> None:
    """Creates a Delta table with sample data and saves it to the specified path."""
    logger.info(f"Saving delta table: {delta_table_path}...")
    schema = StructType([
        StructField("id", IntegerType(), True),
        StructField("name", StringType(), True),
        StructField("age", IntegerType(), True)
    ])
    data = [(1, "Alice", 25), (2, "Bob", 30), (3, "Charlie", 35), (4, "David", 40)]
    df = spark.createDataFrame(data, schema)

    df.write.format("delta").mode("overwrite").save(delta_table_path)

    logger.info(f"Delta table saved at {delta_table_path}")


def transform_and_save(spark: SparkSession, source_table_path: str, target_table_path: str) -> None:
    """Transforms the data from the source Delta table and saves it to the target Delta table."""
    logger.info(f"Transforming data from {source_table_path} and saving to {target_table_path}...")
    df = spark.read.format("delta").load(source_table_path)
    df = df.groupBy(F.col("name")).agg(F.max(F.col("age")).alias("max_age"))
    df.write.format("delta").mode("overwrite").save(target_table_path)
    logger.info(f"Transformed data saved at {target_table_path}")


def main():
    """Main function to parse arguments and execute the Spark job."""
    parser = argparse.ArgumentParser(description="Sample Spark job.")

    parser.add_argument("silver_workspace_id", type=str, help="Silver workspace ID")
    parser.add_argument("silver_lakehouse_id", type=str, help="Silver lakehouse ID")
    parser.add_argument("gold_workspace_id", type=str, help="Gold workspace ID")
    parser.add_argument("gold_lakehouse_id", type=str, help="Gold lakehouse ID")
    args = parser.parse_args()

    silver_table_path = get_delta_table_path(args.silver_workspace_id, args.silver_lakehouse_id, "sample_table")
    gold_table_path = get_delta_table_path(args.gold_workspace_id, args.gold_lakehouse_id, "sample_table_agg")

    spark = SparkSession.builder.appName("TestSparkApp").getOrCreate()
    create_delta_table(spark, silver_table_path)
    transform_and_save(spark, silver_table_path, gold_table_path)
    logger.info("Spark job completed successfully.")


if __name__ == "__main__":
    main()
