"""Example Spark job to create and transform Delta tables.

It creates a Delta table with sample data, saves it to a Silver lakehouse,
and then transforms the data and saves it to a Gold lakehouse.

"""

import argparse

import pyspark.sql.functions as F
from pyspark.sql import DataFrame, SparkSession
from pyspark.sql.types import StructType, StructField, StringType, IntegerType
from stacks.data.logger import get_logger
from stacks.data.platforms.fabric.etl import transform_and_save_as_delta
from stacks.data.platforms.fabric.lakehouse import LakehouseClient
from stacks.data.pyspark.pyspark_utils import get_spark_session, read_datasource

APP_NAME = "example_spark_job"

logger = get_logger(APP_NAME)


def create_delta_table(spark: SparkSession, delta_table_path: str) -> None:
    """Creates a Delta table with sample data and saves it to the specified path."""
    logger.info(f"Saving delta table: {delta_table_path}...")
    schema = StructType(
        [
            StructField("id", IntegerType(), True),
            StructField("name", StringType(), True),
            StructField("age", IntegerType(), True),
        ]
    )
    data = [(1, "Alice", 25), (2, "Bob", 30), (3, "Charlie", 35), (4, "David", 40)]
    df = spark.createDataFrame(data, schema)

    df.write.format("delta").mode("overwrite").save(delta_table_path)

    logger.info(f"Delta table saved at {delta_table_path}")


def transform(df: DataFrame) -> DataFrame:
    """Transforms the input DataFrame by grouping by 'name' and calculating the maximum 'age'."""
    return df.groupBy(F.col("name")).agg(F.max(F.col("age")).alias("max_age"))


def main():
    """Main function to parse arguments and execute the Spark job."""
    parser = argparse.ArgumentParser(description="Sample Spark job.")

    parser.add_argument("silver_workspace_id", type=str, help="Silver workspace ID")
    parser.add_argument("silver_lakehouse_id", type=str, help="Silver lakehouse ID")
    parser.add_argument("gold_workspace_id", type=str, help="Gold workspace ID")
    parser.add_argument("gold_lakehouse_id", type=str, help="Gold lakehouse ID")
    args = parser.parse_args()

    silver_lakehouse_client = LakehouseClient(args.silver_workspace_id, args.silver_lakehouse_id)
    gold_lakehouse_client = LakehouseClient(args.gold_workspace_id, args.gold_lakehouse_id)

    silver_table_path = silver_lakehouse_client.get_table_url("sample_table")
    target_table_name = "sample_table_agg"
    gold_table_path = gold_lakehouse_client.get_table_url(target_table_name)

    spark = get_spark_session(APP_NAME)
    create_delta_table(spark, silver_table_path)
    df = read_datasource(spark, silver_table_path, "delta")
    transform_and_save_as_delta(spark, gold_lakehouse_client, df, transform, target_table_name)
    logger.info(f"Transformed data saved at {gold_table_path}.")
    logger.info("Spark job completed successfully.")


if __name__ == "__main__":
    main()
