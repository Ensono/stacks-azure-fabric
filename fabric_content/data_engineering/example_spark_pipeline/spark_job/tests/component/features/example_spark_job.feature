Feature: Transform and Save Delta Table
  As a data engineer
  I want to transform data from a source Delta table and save the result
  So that the aggregation is correct and persisted

  Scenario: Happy path for the example_spark_job
    Given a source table containing data matching '../test_data/input/input_data.csv'
    When the spark job is triggered
    Then the target table contains expected aggregated data matching '../test_data/output/expected_table.csv'
