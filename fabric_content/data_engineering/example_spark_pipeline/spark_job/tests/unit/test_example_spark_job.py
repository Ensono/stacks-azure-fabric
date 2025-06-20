from ...example_spark_job import get_delta_table_path


def test_get_delta_table_path():
    """Test the get_delta_table_path function."""
    workspace_id = "workspace_123"
    lakehouse_id = "lakehouse_456"
    table_name = "table_789"

    expected_path = f"abfss://{workspace_id}@onelake.dfs.fabric.microsoft.com/{lakehouse_id}/Tables/dbo/{table_name}"
    actual_path = get_delta_table_path(workspace_id, lakehouse_id, table_name)

    assert actual_path == expected_path
