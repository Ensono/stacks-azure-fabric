"""
End-to-end BDD steps for testing the Fabric Spark pipeline using pytest-bdd, Spark, and chispa.
"""

from pytest_bdd import scenarios, when, then, parsers
from chispa.dataframe_comparer import assert_df_equality
from pyspark.sql import SparkSession
import os
import requests

from ..fabric_helper import FabricHelper

scenarios("../features/transform_and_save.feature")

ENGINEERING_WORKSPACE_ID = os.getenv("ENGINEERING_WORKSPACE_ID")
GOLD_WORKSPACE_ID = os.getenv("GOLD_WORKSPACE_ID")
GOLD_LAKEHOUSE_ID = os.getenv("GOLD_LAKEHOUSE_ID")
FABRIC_CLIENT_ID = os.getenv("FABRIC_CLIENT_ID")
FABRIC_CLIENT_SECRET = os.getenv("FABRIC_CLIENT_SECRET")
FABRIC_TENANT_ID = os.getenv("FABRIC_TENANT_ID")

spark = (
    SparkSession.builder
        .appName("Testing PySpark Example")
        .config("spark.driver.bindAddress", "127.0.0.1")
        .config("spark.driver.host", "127.0.0.1")
        .config("spark.jars.packages", "io.delta:delta-spark_2.12:3.1.0,org.apache.hadoop:hadoop-azure:3.3.6,com.azure:azure-storage-blob:12.30.0")
        .config("spark.sql.extensions", "io.delta.sql.DeltaSparkSessionExtension")
        .config("spark.sql.catalog.spark_catalog", "org.apache.spark.sql.delta.catalog.DeltaCatalog")
        .config("fs.azure.account.auth.type", "OAuth")
        .config("fs.azure.account.oauth.provider.type", "org.apache.hadoop.fs.azurebfs.oauth2.ClientCredsTokenProvider")
        .config("fs.azure.account.oauth2.client.id", FABRIC_CLIENT_ID)
        .config("fs.azure.account.oauth2.client.secret", FABRIC_CLIENT_SECRET)
        .config("fs.azure.account.oauth2.client.endpoint", f"https://login.microsoftonline.com/{FABRIC_TENANT_ID}/oauth2/token")
        .config(
            "spark.jars.packages",
            "io.delta:delta-spark_2.12:3.1.0,"
            "org.apache.hadoop:hadoop-azure:3.4.1,"
            "org.apache.hadoop:hadoop-common:3.4.1,"
            "com.azure:azure-storage-blob:12.30.0"
        )
        .config("spark.jars.repositories", "https://repo1.maven.org/maven2,https://mvnrepository.com/artifact")
        .getOrCreate()
)


def get_workspace_id_by_name(workspace_name: str) -> str:
    """
    Helper to map workspace names to their corresponding IDs.
    """
    workspace_ids = {
        "engineering": ENGINEERING_WORKSPACE_ID,
        "gold": GOLD_WORKSPACE_ID,
    }
    if workspace_name not in workspace_ids:
        raise ValueError(f"Unknown workspace name: {workspace_name}")
    return workspace_ids[workspace_name]


def get_pipeline_id_by_name(items, pipeline_name: str) -> str:
    """
    Helper to find the pipeline ID by display name from the workspace items list.
    """
    for item in items:
        if item.get("displayName") == pipeline_name and item.get("type") == "DataPipeline":
            return item.get("id")
    raise ValueError(f"Pipeline with name '{pipeline_name}' not found in workspace items.")


@when(parsers.parse("the Fabric pipeline is triggered to run the {pipeline_name} job from the {workspace_name} workspace"))
def trigger_fabric_pipeline(test_context, pipeline_name, workspace_name):
    """
    Trigger the Fabric pipeline from the specified workspace by dynamically resolving the pipeline_id from the workspace items API.
    The pipeline_name and workspace_name parameters are used to look up the pipeline ID and workspace ID.
    """
    fabric = FabricHelper(
        tenant_id=FABRIC_TENANT_ID,
        client_id=FABRIC_CLIENT_ID,
        client_secret=FABRIC_CLIENT_SECRET
    )
    workspace_id = get_workspace_id_by_name(workspace_name)
    # Get all items in the specified workspace
    url = f"https://api.fabric.microsoft.com/v1/workspaces/{workspace_id}/items"
    headers = fabric.get_auth_header()
    response = requests.get(url, headers=headers)
    response.raise_for_status()
    items = response.json().get("value", [])
    # Find the pipeline with the given name
    pipeline_id = get_pipeline_id_by_name(items, pipeline_name)
    payload = {}  # Customize if you need to pass parameters
    fabric.trigger_pipeline(workspace_id, pipeline_id, payload)
    print(f"✅ Pipeline {pipeline_name} triggered successfully from {workspace_name} workspace")
    test_context['pipeline_id'] = pipeline_id
    test_context['workspace_id'] = workspace_id


@when(parsers.parse("I poll the pipeline every {interval:d} seconds until it has completed"))
def poll_pipeline_until_complete(test_context, interval):
    """
    Poll the Fabric pipeline run status every `interval` seconds until it completes.
    Store the final status and duration in the test_context.
    """
    fabric = FabricHelper(
        tenant_id=FABRIC_TENANT_ID,
        client_id=FABRIC_CLIENT_ID,
        client_secret=FABRIC_CLIENT_SECRET
    )
    workspace_id = test_context['workspace_id']
    pipeline_id = test_context['pipeline_id']
    status, duration = fabric.poll_pipeline_until_complete(
        workspace_id, pipeline_id, interval=interval
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
    Reads the table directly from abfss using Spark, avoiding local file download.
    """
    expected_output_path = os.path.abspath(
        os.path.join(os.path.dirname(__file__), "../../end_to_end/test_data/output/expected_table.csv")
    )
    table_name = "dbo/sample_table_agg"  # Adjust as needed or make this a parameter

    abfss_table_path = (
        f"abfss://{GOLD_WORKSPACE_ID}@onelake.dfs.fabric.microsoft.com/"
        f"{GOLD_LAKEHOUSE_ID}/Tables/{table_name}"
    )

    actual_df = spark.read.format("delta").load(abfss_table_path)
    expected_df = spark.read.csv(expected_output_path, header=True, inferSchema=True)
    assert_df_equality(actual_df, expected_df, ignore_row_order=True, ignore_nullable=True)
    print(f"✅ Lakehouse table {table_name} from {lakehouse_name} was read and compared successfully")
