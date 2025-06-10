import os
import shutil
import tempfile
import pandas as pd
import pytest
from pyspark.sql import SparkSession
from data_engineering.example_spark_pipeline.spark_job.example_spark_job import transform_and_save
from pytest_bdd import scenarios, given, when, then, parsers
from chispa.dataframe_comparer import assert_df_equality

scenarios("../features/transform_and_save.feature")

@pytest.fixture(scope="session")
def spark():
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
    source_dir = tempfile.mkdtemp()
    target_dir = tempfile.mkdtemp()
    yield source_dir, target_dir
    shutil.rmtree(source_dir)
    shutil.rmtree(target_dir)

@given(parsers.parse("a source delta table created from test data at '{source_data_path}'"))
def create_source_table(spark, temp_delta_dirs, source_data_path):
    source_dir, _ = temp_delta_dirs
    test_data_path = os.path.join(os.path.dirname(__file__), source_data_path)
    data_frame = pd.read_csv(test_data_path)
    source_data_frame = spark.createDataFrame(data_frame)
    source_data_frame.write.format("delta").mode("overwrite").save(source_dir)

@when("I run the transform_and_save function")
def run_transform(spark, temp_delta_dirs):
    source_dir, target_dir = temp_delta_dirs
    transform_and_save(spark, source_dir, target_dir)

@then(parsers.parse("the target delta table should contain the correct aggregated data from '{expected_data_path}'"))
def check_aggregated(spark, temp_delta_dirs, expected_data_path):
    _, target_dir = temp_delta_dirs
    data_frame = spark.read.format("delta").load(target_dir)
    expected_path = os.path.join(os.path.dirname(__file__), expected_data_path)
    expected_data = pd.read_csv(expected_path)
    expected_data_frame = spark.createDataFrame(expected_data)

    assert_df_equality(
        data_frame.orderBy("name"),
        expected_data_frame.orderBy("name"),
        ignore_nullable=True
    )
