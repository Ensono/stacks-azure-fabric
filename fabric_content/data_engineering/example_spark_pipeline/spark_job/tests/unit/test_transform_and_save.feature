Feature: Transform and save integration

  Scenario: Transform and save happy path
    Given a source delta table created from CSV test data
    And an empty target delta table path
    When the transform_and_save function is called
    Then the target delta table matches the expected output
