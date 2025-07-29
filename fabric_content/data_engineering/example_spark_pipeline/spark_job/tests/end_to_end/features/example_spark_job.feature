Feature: End-to-End Transform and Save Delta Table
  As a data engineer
  I want to trigger the actual Fabric pipeline to transform and save data
  So that the aggregation is correct and persisted in the lakehouse

  Scenario: Fabric example_spark_pipeline is triggered successfully
    When the Fabric pipeline is triggered to run the example_spark_pipeline job from the engineering workspace
    And I poll the pipeline every 30 seconds until it has completed
    Then the pipeline example_spark_pipeline has finished with state Completed
    And the pipeline example_spark_pipeline has completed in less than 900 seconds
    Then the target table dbo/sample_table_agg in the lakehouse gold_lake contains expected aggregated data
