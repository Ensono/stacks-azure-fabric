"""Example Spark job to create and transform Delta tables.

It creates a Delta table with sample data, saves it to a Silver lakehouse, and then transforms the data and saves it to a Gold lakehouse.

"""
import argparse

import pyspark.sql.functions as F
from pyspark.sql import SparkSession
from pyspark.sql.types import StructType, StructField, StringType, IntegerType


def get_delta_table_path(workspace_name, artifact_id, table_name):
    """Constructs the Delta table path based on the provided workspace name, artifact ID, and table name."""
    return f"abfss://{workspace_name}@onelake.dfs.fabric.microsoft.com/{artifact_id}/Tables/dbo/{table_name}"



def create_delta_table(spark: SparkSession, delta_table_path: str):
    print(f"Saving delta table: {delta_table_path}...")
    schema = StructType([
        StructField("id", IntegerType(), True),
        StructField("name", StringType(), True),
        StructField("age", IntegerType(), True)
    ])
    data = [(1, "Alice", 25), (2, "Bob", 30), (3, "Charlie", 35), (4, "David", 40)]
    df = spark.createDataFrame(data, schema)

    df.write.format("delta").mode("overwrite").save(delta_table_path)

    print(f"Delta table saved at {delta_table_path}")


def transform_and_save(spark, source_table_path, target_table_path):
    print(f"Transforming data from {source_table_path} and saving to {target_table_path}...")
    df = spark.read.format("delta").load(source_table_path)
    df = df.groupBy(F.col("name")).agg(F.max(F.col("age")).alias("max_age"))
    df.write.format("delta").mode("overwrite").save(target_table_path)
    print(f"Transformed data saved at {target_table_path}")


if __name__ == "__main__":
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
