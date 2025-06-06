from pyspark.sql.types import StructType, StructField, StringType, IntegerType
from pyspark.sql import functions as F
from pyspark.sql import DataFrame

from ... import example_spark_job
from ...example_spark_job import create_delta_table, get_delta_table_path, transform_and_save

def test_get_delta_table_path():
    """Test the get_delta_table_path function."""
    workspace_id = "workspace_123"
    lakehouse_id = "lakehouse_456"
    table_name = "table_789"

    expected_path = f"abfss://{workspace_id}@onelake.dfs.fabric.microsoft.com/{lakehouse_id}/Tables/dbo/{table_name}"
    actual_path = get_delta_table_path(workspace_id, lakehouse_id, table_name)

    assert actual_path == expected_path


def test_create_delta_table(mocker):
    """Test the create_delta_table function."""
    # Mock SparkSession and DataFrame
    mock_spark = mocker.Mock()
    mock_df = mocker.Mock()

    # Mock createDataFrame to return mock_df
    mock_spark.createDataFrame.return_value = mock_df

    # Mock the write chain
    mock_write = mocker.Mock()
    mock_df.write = mock_write
    mock_write.format.return_value = mock_write
    mock_write.mode.return_value = mock_write

    # Call the function
    delta_path = "mock/path"
    expected_schema = StructType([
        StructField("id", IntegerType(), True),
        StructField("name", StringType(), True),
        StructField("age", IntegerType(), True)
    ])
    expected_data = [(1, "Alice", 25), (2, "Bob", 30), (3, "Charlie", 35), (4, "David", 40)]
    create_delta_table(mock_spark, delta_path)

    # Assertions
    mock_spark.createDataFrame.assert_called_once_with(expected_data, expected_schema)
    mock_write.format.assert_called_once_with("delta")
    mock_write.mode.assert_called_once_with("overwrite")
    mock_write.save.assert_called_once_with(delta_path)


def test_transform_and_save(mocker):
    """Test the transform_and_save function."""
    # Patch F.col and F.max using object patching to avoid SparkContext errors
    mocker.patch.object(example_spark_job.F, "col", return_value="mock_col")
    mock_max = mocker.Mock()
    mock_max.alias.return_value = "mock_max_age"
    mocker.patch.object(example_spark_job.F, "max", return_value=mock_max)

    # Mock SparkSession
    mock_spark = mocker.Mock()

    # Mock the DataFrame returned by spark.read.format(...).load(...)
    mock_df = mocker.Mock(spec=DataFrame)
    mock_transformed_df = mocker.Mock(spec=DataFrame)

    # Mock the read chain
    mock_read = mocker.Mock()
    mock_spark.read = mock_read
    mock_read.format.return_value = mock_read
    mock_read.load.return_value = mock_df

    # Mock transformation chain: groupBy().agg()
    mock_grouped = mocker.Mock()
    mock_df.groupBy.return_value = mock_grouped
    mock_grouped.agg.return_value = mock_transformed_df

    # Mock write chain
    mock_write = mocker.Mock()
    mock_transformed_df.write = mock_write
    mock_write.format.return_value = mock_write
    mock_write.mode.return_value = mock_write

    # Call the function
    transform_and_save(mock_spark, "mock/source", "mock/target")

    # Assertions
    mock_df.groupBy.assert_called_once_with("mock_col")
    mock_grouped.agg.assert_called_once_with("mock_max_age")
    mock_write.format.assert_called_once_with("delta")
    mock_write.mode.assert_called_once_with("overwrite")
    mock_write.save.assert_called_once_with("mock/target")
