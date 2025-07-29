import os
import shutil
import sys
import tempfile
from typing import Generator, Tuple
from unittest.mock import patch

import pytest
from pyspark.sql import SparkSession
from pytest_bdd import scenarios, given, when, then, parsers
from chispa.dataframe_comparer import assert_df_equality

from data_engineering.example_spark_pipeline.spark_job import example_spark_job

scenarios("../features/example_spark_job.feature")


@pytest.fixture(scope="session")
def spark() -> Generator[SparkSession, None, None]:
    """Fixture to create a Spark session for testing."""
    spark = (
        SparkSession.builder.appName("Testing PySpark Example")
        .config("spark.driver.bindAddress", "127.0.0.1")
        .config("spark.driver.host", "127.0.0.1")
        .config("spark.jars.packages", "io.delta:delta-spark_2.12:3.1.0")
        .config("spark.sql.extensions", "io.delta.sql.DeltaSparkSessionExtension")
        .config(
            "spark.sql.catalog.spark_catalog",
            "org.apache.spark.sql.delta.catalog.DeltaCatalog",
        )
        .config(
            "spark.jars.repositories",
            "https://repo1.maven.org/maven2,https://mvnrepository.com/artifact",
        )
        .getOrCreate()
    )
    yield spark
    spark.stop()


@pytest.fixture(scope="module")
def temp_delta_dirs() -> Generator[Tuple[str, str], None, None]:
    """Fixture to create and clean up temporary directories for source and target Delta tables."""
    source_dir = tempfile.mkdtemp()
    target_dir = tempfile.mkdtemp()
    yield source_dir, target_dir
    shutil.rmtree(source_dir)
    shutil.rmtree(target_dir)


@given(parsers.parse("a source table containing data matching '{input_data_path}'"))
def create_source_table_from_csv(spark: SparkSession, temp_delta_dirs: Tuple[str, str], input_data_path: str) -> None:
    """Given step to create a source Delta table from a CSV file."""
    source_dir, _ = temp_delta_dirs
    csv_path = os.path.join(os.path.dirname(__file__), input_data_path)
    source_data_frame = spark.read.format("csv").option("header", True).option("inferSchema", True).load(csv_path)
    source_data_frame.write.format("delta").mode("overwrite").save(source_dir)


@when("the spark job is triggered")
def run_main(monkeypatch, temp_delta_dirs: Tuple[str, str]) -> None:
    """When step to run the example_spark_job main function with test-specific patching."""
    source_dir, target_dir = temp_delta_dirs
    monkeypatch.setattr(
        sys,
        "argv",
        [
            "example_spark_job.py",
            "silver_workspace_id",
            "silver_lakehouse_id",
            "gold_workspace_id",
            "gold_lakehouse_id",
        ],
    )

    def fake_get_table_url(self, table_name: str, schema: str = "dbo") -> str:
        if table_name == "sample_table":
            return source_dir
        else:
            return target_dir

    with patch.object(example_spark_job.LakehouseClient, "get_table_url", new=fake_get_table_url):
        example_spark_job.main()


@then(parsers.parse("the target table contains expected aggregated data matching '{expected_data_path}'"))
def check_aggregated(spark: SparkSession, temp_delta_dirs: Tuple[str, str], expected_data_path: str) -> None:
    """Then step to check that the target Delta table contains the expected aggregated data."""
    _, target_dir = temp_delta_dirs
    data_frame = spark.read.format("delta").load(target_dir)
    expected_path = os.path.join(os.path.dirname(__file__), expected_data_path)
    expected_data_frame = (
        spark.read.format("csv").option("header", True).option("inferSchema", True).load(expected_path)
    )
    assert_df_equality(data_frame, expected_data_frame, ignore_nullable=True, ignore_row_order=True)
