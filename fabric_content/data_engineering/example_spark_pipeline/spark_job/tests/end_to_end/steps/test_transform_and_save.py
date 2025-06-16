from pytest_bdd import scenarios, given, when, then, parsers
from chispa.dataframe_comparer import assert_df_equality
from pyspark.sql import SparkSession

scenarios("../features/transform_and_save.feature")

@given(parsers.parse("a source table in the lakehouse containing data matching the provided input file"))
def reference_existing_lakehouse_file(test_context):
    # Instead of loading, just record the path to the existing file in the lakehouse
    test_context['input_lakehouse_path'] = "<provide_lakehouse_input_path_here>"

@when("the Fabric pipeline is triggered to run the transform_and_save job")
def trigger_fabric_pipeline(test_context):
    # TODO: Implement logic to trigger the actual Fabric pipeline
    # Should set test_context['pipeline_run_id'] or similar for polling
    pass

@when(parsers.parse("I poll the pipeline every {interval:d} seconds until it has completed"))
def poll_pipeline_until_complete(test_context, interval):
    """
    Polls the Fabric pipeline run status every `interval` seconds until it completes.
    Stores the final status and duration in the test_context.
    """
    import time
    # Placeholder: Replace with your actual Fabric pipeline run ID
    pipeline_run_id = test_context.get('pipeline_run_id', '<pipeline_run_id>')
    # Placeholder: Replace with your actual Fabric API/client
    def get_pipeline_status_and_duration(run_id):
        # Should return (status: str, duration_seconds: int or None)
        # Example: ("InProgress", None) or ("Succeeded", 123)
        raise NotImplementedError("Replace with Fabric API call")

    start_time = time.time()
    while True:
        status, duration = get_pipeline_status_and_duration(pipeline_run_id)
        if status in ("Succeeded", "Failed", "Cancelled"):  # Terminal states
            test_context['pipeline_status'] = status
            test_context['pipeline_duration'] = duration if duration is not None else int(time.time() - start_time)
            break
        time.sleep(interval)

@then(parsers.parse("the pipeline transform_and_save has finished with state {expected_state}"))
def assert_pipeline_state(test_context, expected_state):
    actual_state = test_context.get('pipeline_status')
    assert actual_state == expected_state, f"Expected pipeline state '{expected_state}', got '{actual_state}'"

@then(parsers.parse("the pipeline transform_and_save has completed in less than {max_seconds:d} seconds"))
def assert_pipeline_duration(test_context, max_seconds):
    duration = test_context.get('pipeline_duration')
    assert duration is not None, "Pipeline duration was not set."
    assert duration < max_seconds, f"Pipeline took {duration} seconds, which exceeds the limit of {max_seconds} seconds."

@then(parsers.parse("the target table in the lakehouse contains expected aggregated data matching the provided expected output file"))
def assert_target_table(test_context):
    """
    Reads the target table from the lakehouse and compares it to the expected output file using chispa.
    Assumes test_context['lakehouse_target_path'] and test_context['expected_output_path'] are set.
    """
    spark = SparkSession.builder.getOrCreate()
    # TODO: Replace with actual logic to get the correct paths
    expected_output_path = test_context.get('expected_output_path', '<expected_output_path>')
    target_table_path = test_context.get('lakehouse_target_path', '<lakehouse_target_path>')

    # Read both tables as Spark DataFrames
    actual_df = spark.read.format("delta").load(target_table_path)
    expected_df = spark.read.csv(expected_output_path, header=True, inferSchema=True)

    # Use chispa to assert equality (ignores row order and nullability by default)
    assert_df_equality(actual_df, expected_df, ignore_row_order=True, ignore_nullable=True)
