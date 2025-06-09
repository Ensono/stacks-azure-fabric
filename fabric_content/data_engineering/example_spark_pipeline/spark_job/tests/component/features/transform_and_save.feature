Feature: Transform and Save Delta Table
  As a data engineer
  I want to transform data from a source Delta table and save the result
  So that the aggregation is correct and persisted

  Scenario: Happy path for transform_and_save
    Given a source delta table created from test data
    When I run the transform_and_save function
    Then the target delta table should contain the correct aggregated data
