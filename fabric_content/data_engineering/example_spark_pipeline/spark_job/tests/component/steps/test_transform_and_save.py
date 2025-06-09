import os
import shutil
import tempfile
import pandas as pd
import pytest
from pyspark.sql import SparkSession
from data_engineering.example_spark_pipeline.spark_job.example_spark_job import transform_and_save
from pytest_bdd import scenarios, given, when, then, parsers

scenarios("../features/transform_and_save.feature")

@pytest.fixture(scope="module")
def spark():
    spark = (
        SparkSession.builder
        .master("local[1]")
        .appName("pytest-spark")
        .config("spark.driver.bindAddress", "127.0.0.1")
        .config("spark.driver.host", "127.0.0.1")
        .config("spark.jars.packages", "io.delta:delta-core_2.12:3.1.0")
        .config("spark.sql.extensions", "io.delta.sql.DeltaSparkSessionExtension")
        .config("spark.sql.catalog.spark_catalog", "org.apache.spark.sql.delta.catalog.DeltaCatalog")
        .getOrCreate()
    )
    yield spark
    spark.stop()

@pytest.fixture(scope="module")
def temp_delta_dirs():
    source_dir = tempfile.mkdtemp()
    target_dir = tempfile.mkdtemp()
    yield source_dir, target_dir
    shutil.rmtree(source_dir)
    shutil.rmtree(target_dir)

@given("a source delta table created from test data")
def create_source_table(spark, temp_delta_dirs):
    source_dir, _ = temp_delta_dirs
    test_data_path = os.path.join(os.path.dirname(__file__), "../test_data/source_table.csv")
    df = pd.read_csv(test_data_path)
    sdf = spark.createDataFrame(df)
    sdf.write.format("delta").mode("overwrite").save(source_dir)

@when("I run the transform_and_save function")
def run_transform(spark, temp_delta_dirs):
    source_dir, target_dir = temp_delta_dirs
    transform_and_save(spark, source_dir, target_dir)

@then("the target delta table should contain the correct aggregated data")
def check_aggregated(spark, temp_delta_dirs):
    _, target_dir = temp_delta_dirs
    df = spark.read.format("delta").load(target_dir)
    result = {row['name']: row['max_age'] for row in df.collect()}
    assert result == {"Alice": 25, "Bob": 30, "Charlie": 35, "David": 40}
