import os
import shutil
import sys
import tempfile

import pytest
from pyspark.sql import SparkSession
from pytest_bdd import scenarios, given, when, then, parsers
from chispa.dataframe_comparer import assert_df_equality

from data_engineering.example_spark_pipeline.spark_job import example_spark_job

scenarios("../features/transform_and_save.feature")

@pytest.fixture(scope="session")
def spark():
    """Fixture to create a Spark session for testing."""
    spark = (
        SparkSession.builder
        .appName("Testing PySpark Example")
        .config("spark.driver.bindAddress", "127.0.0.1")
        .config("spark.driver.host", "127.0.0.1")
        .config("spark.jars.packages", "io.delta:delta-spark_2.12:3.1.0")
        .config("spark.sql.extensions", "io.delta.sql.DeltaSparkSessionExtension")
        .config("spark.sql.catalog.spark_catalog", "org.apache.spark.sql.delta.catalog.DeltaCatalog")
        .config("spark.jars.repositories", "https://repo1.maven.org/maven2,https://mvnrepository.com/artifact")
        .getOrCreate()
    )
    yield spark
    spark.stop()

@pytest.fixture(scope="module")
def temp_delta_dirs():
    """Fixture to create and clean up temporary directories for source and target Delta tables."""
    source_dir = tempfile.mkdtemp()
    target_dir = tempfile.mkdtemp()
    yield source_dir, target_dir
    shutil.rmtree(source_dir)
    shutil.rmtree(target_dir)

@given(parsers.parse("a source delta table created from test data at '{source_data_path}'"))
def create_source_table(spark, temp_delta_dirs, source_data_path):
    """Given step to create a source Delta table from a CSV test data file."""
    source_dir, _ = temp_delta_dirs
    test_data_path = os.path.join(os.path.dirname(__file__), source_data_path)
    source_data_frame = spark.read.format("csv").option("header", True).option("inferSchema", True).load(test_data_path)
    source_data_frame.write.format("delta").mode("overwrite").save(source_dir)

@then(parsers.parse("the target delta table should contain the correct aggregated data from '{expected_data_path}'"))
def check_aggregated(spark, temp_delta_dirs, expected_data_path):
    """Then step to check that the target Delta table contains the expected aggregated data."""
    _, target_dir = temp_delta_dirs
    data_frame = spark.read.format("delta").load(target_dir)
    expected_path = os.path.join(os.path.dirname(__file__), expected_data_path)
    expected_data_frame = spark.read.format("csv").option("header", True).option("inferSchema", True).load(expected_path)

    assert_df_equality(
        data_frame,
        expected_data_frame.orderBy("name"),
        ignore_nullable=True,
        ignore_row_order=True
    )

@when("I trigger the example_spark_job")
def run_main(monkeypatch, spark, temp_delta_dirs):
    """When step to run the example_spark_job main function with test-specific patching."""
    source_dir, target_dir = temp_delta_dirs
    # Patch sys.argv to simulate CLI arguments for the main function
    monkeypatch.setattr(sys, "argv", [
        "example_spark_job.py",
        "silver_workspace_id",
        "silver_lakehouse_id",
        "gold_workspace_id",
        "gold_lakehouse_id"
    ])
    # Patch get_delta_table_path to use our temp dirs
    def fake_get_delta_table_path(workspace_id, lakehouse_id, table_name):
        if table_name == "sample_table":
            return source_dir
        else:
            return target_dir
    monkeypatch.setattr(example_spark_job, "get_delta_table_path", fake_get_delta_table_path)
    # Patch create_delta_table to do nothing (since we already created it in the fixture)
    monkeypatch.setattr(example_spark_job, "create_delta_table", lambda *a, **kw: None)
    # Patch SparkSession.builder.getOrCreate to return our test spark session
    monkeypatch.setattr(example_spark_job.SparkSession.builder, "getOrCreate", lambda self=None: spark)
    # Call main
    example_spark_job.main()
