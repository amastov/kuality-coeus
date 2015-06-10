@smoke
Feature: Nonrandom Scenarios

  To speed up execution time of smoke tests,
  new step definitions are provided that have
  deterministic inputs.

  Scenario: Editing finalized nonrandom Award when a pending new version exists, select 'yes'
    Given a User exists with the role 'Time And Money Modifier' in unit '000001' (descends hierarchy)
    And a User exists with the role 'Award Modifier' in unit 'CS'
    And the Award Modifier creates a nonrandom Award
    And adds a subaward to the Award
    And completes the nonrandom Award requirements
    And the Award Modifier submits the Award
    And the Time & Money Modifier submits the Award's T&M document
    And the Award Modifier edits the finalized Award deterministically
    When the original Award is edited again
    Then a confirmation screen asks if you want to edit the existing pending version
    And selecting 'yes' takes you to the pending version