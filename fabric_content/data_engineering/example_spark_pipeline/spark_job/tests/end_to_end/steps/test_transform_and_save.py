"""
End-to-end BDD steps for testing the Fabric Spark pipeline using pytest-bdd, Spark, and chispa.
"""

from pytest_bdd import scenarios, when, then, parsers
from chispa.dataframe_comparer import assert_df_equality
from pyspark.sql import SparkSession
import os

from ..fabric_helper import FabricHelper

scenarios("../features/transform_and_save.feature")

WORKSPACE_ID = "8794a888-b6c6-4fe5-8f69-6eb0467f5246"
PIPELINE_ID = "4085a673-cec4-4600-9d05-ed8d36f910c9"
WORKSPACE_NAME = "test-fabric-gold"

spark = (
    SparkSession.builder
        .appName("Testing PySpark Example")
        .config("spark.driver.bindAddress", "127.0.0.1")
        .config("spark.driver.host", "127.0.0.1")
        .config("spark.jars.packages", "io.delta:delta-spark_2.12:3.1.0,org.apache.hadoop:hadoop-azure:3.3.6,com.azure:azure-storage-blob:12.30.0")
        .config("spark.sql.extensions", "io.delta.sql.DeltaSparkSessionExtension")
        .config("spark.sql.catalog.spark_catalog", "org.apache.spark.sql.delta.catalog.DeltaCatalog")
        .config("spark.jars.repositories", "https://repo1.maven.org/maven2,https://mvnrepository.com/artifact")
        .getOrCreate()
)


@when(parsers.parse("the Fabric pipeline is triggered to run the {pipeline_name} job"))
def trigger_fabric_pipeline(test_context, pipeline_name):
    """
    Trigger the Fabric pipeline and store the pipeline run id in the test context.
    The pipeline_name parameter can be used to select the pipeline or for logging.
    """
    fabric = FabricHelper()
    payload = {}  # Customize if you need to pass parameters
    # For now, we still use the hardcoded PIPELINE_ID, but you could map pipeline_name to ID if needed
    fabric.trigger_pipeline(WORKSPACE_ID, PIPELINE_ID, payload)
    print(f"✅ Pipeline {pipeline_name} triggered successfully")


@when(parsers.parse("I poll the pipeline every {interval:d} seconds until it has completed"))
def poll_pipeline_until_complete(test_context, interval):
    """
    Poll the Fabric pipeline run status every `interval` seconds until it completes.
    Store the final status and duration in the test_context.
    """
    fabric = FabricHelper()
    pipeline_run_id = test_context.get('pipeline_run_id', None)
    status, duration = fabric.poll_pipeline_until_complete(
        WORKSPACE_ID, PIPELINE_ID, run_id=pipeline_run_id, interval=interval
    )
    test_context['pipeline_status'] = status
    test_context['pipeline_duration'] = duration


@then(parsers.parse("the pipeline {pipeline_name} has finished with state {expected_state}"))
def assert_pipeline_state(test_context, expected_state):
    """
    Assert that the pipeline finished with the expected state.
    """
    actual_state = test_context.get('pipeline_status')
    assert actual_state == expected_state, f"Expected pipeline state '{expected_state}', got '{actual_state}'"


@then(parsers.parse("the pipeline {pipeline_name} has completed in less than {max_seconds:d} seconds"))
def assert_pipeline_duration(test_context, max_seconds):
    """
    Assert that the pipeline completed in less than the specified number of seconds.
    """
    duration = test_context.get('pipeline_duration')
    assert duration is not None, "Pipeline duration was not set."
    assert duration < max_seconds, f"Pipeline took {duration} seconds, which exceeds the limit of {max_seconds} seconds."


@then(parsers.parse("the target table in the lakehouse {lakehouse_name} contains expected aggregated data"))
def assert_target_table(test_context, lakehouse_name):
    """
    Read the target table from the specified lakehouse and compare it to the expected output file using chispa.
    Uses the expected output from end_to_end/test_data/output/expected_table.csv.
    Downloads the Parquet file to a temp file and reads it locally with Spark.
    Cleans up the temp file after use.
    """
    fabric = FabricHelper()
    expected_output_path = os.path.abspath(
        os.path.join(os.path.dirname(__file__), "../../end_to_end/test_data/output/expected_table.csv")
    )
    table_name = "dbo/sample_table_agg"  # Adjust as needed or make this a parameter

    local_parquet_path = fabric.download_table_parquet_to_local(lakehouse_name, table_name, WORKSPACE_NAME)
    print(f"✅ Lakehouse table {table_name} downloaded to {local_parquet_path}")

    try:
        actual_df = spark.read.parquet(local_parquet_path)
        expected_df = spark.read.csv(expected_output_path, header=True, inferSchema=True)
        assert_df_equality(actual_df, expected_df, ignore_row_order=True, ignore_nullable=True)
    finally:
        if os.path.exists(local_parquet_path):
            os.remove(local_parquet_path)
            print(f"🧹 Deleted temp file {local_parquet_path}")
