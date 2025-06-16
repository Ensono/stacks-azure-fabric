Feature: End-to-End Transform and Save Delta Table
  As a data engineer
  I want to trigger the actual Fabric pipeline to transform and save data
  So that the aggregation is correct and persisted in the lakehouse

  Scenario: E2E happy path for transform_and_save
    Given a source table in the lakehouse containing data matching the provided input file
    When the Fabric pipeline is triggered to run the transform_and_save job
    And I poll the pipeline every 10 seconds until it has completed
    Then the pipeline transform_and_save has finished with state Succeeded
    And the pipeline transform_and_save has completed in less than 900 seconds
    Then the target table in the lakehouse contains expected aggregated data matching the provided expected output file
