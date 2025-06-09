"""Integration test for transform_and_save using pytest-bdd and a local Spark session."""
import os
import shutil
import tempfile
import pandas as pd
import pytest
from pyspark.sql import SparkSession
from pyspark.sql.types import StructType, StructField, StringType, IntegerType
from pytest_bdd import scenario, given, when, then, parsers

from example_spark_job import transform_and_save

TEST_DATA_DIR = os.path.join(os.path.dirname(__file__), '../test_data')

@scenario('test_transform_and_save.feature', 'Transform and save happy path')
def test_transform_and_save_happy_path():
    pass

@pytest.fixture(scope="module")
def spark():
    spark = SparkSession.builder.master("local[1]").appName("pytest-spark").getOrCreate()
    yield spark
    spark.stop()

@given("a source delta table created from CSV test data")
def source_delta_table(spark):
    source_csv = os.path.abspath(os.path.join(TEST_DATA_DIR, "source_table.csv"))
    temp_dir = tempfile.mkdtemp()
    source_delta_path = os.path.join(temp_dir, "source_delta")
    df = spark.read.csv(source_csv, header=True, inferSchema=True)
    df.write.format("delta").mode("overwrite").save(source_delta_path)
    yield source_delta_path
    shutil.rmtree(temp_dir)

@given("an empty target delta table path")
def target_delta_table_path():
    temp_dir = tempfile.mkdtemp()
    target_delta_path = os.path.join(temp_dir, "target_delta")
    yield target_delta_path
    shutil.rmtree(temp_dir)

@when("the transform_and_save function is called")
def call_transform_and_save(spark, source_delta_table, target_delta_table_path):
    transform_and_save(spark, source_delta_table, target_delta_table_path)

@then("the target delta table matches the expected output")
def check_target_table(spark, target_delta_table_path):
    expected_csv = os.path.abspath(os.path.join(TEST_DATA_DIR, "expected_table.csv"))
    expected_df = pd.read_csv(expected_csv)
    result_df = spark.read.format("delta").load(target_delta_table_path)
    result_pd = result_df.toPandas().sort_values(by=["name"]).reset_index(drop=True)
    expected_pd = expected_df.sort_values(by=["name"]).reset_index(drop=True)
    pd.testing.assert_frame_equal(result_pd, expected_pd)
