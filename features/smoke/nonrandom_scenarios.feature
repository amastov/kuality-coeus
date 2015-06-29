@smoke
Feature: Nonrandom Scenarios

  To speed up execution time of smoke tests,
  new step definitions are provided that have
  deterministic inputs.
  @wip
  Scenario: Editing finalized nonrandom Award when a pending new version exists, select 'yes'
    Given a User exists with the role 'Time And Money Modifier' in unit '000001'
    And a User exists with the role 'Award Modifier' in unit 'CS'
    And the Award Modifier creates a nonrandom Award
    #And adds a $100,000 subaward for Clemson University
    And completes the nonrandom Award requirements
    And the Award Modifier submits the Award
    And the Time & Money Modifier submits the Award's T&M document
    And the Award Modifier edits the finalized Award deterministically
    When the original Award is edited again
    Then a confirmation screen asks if you want to edit the existing pending version
    And selecting 'yes' takes you to the pending version

  Scenario Outline: Attempt to save a nonrandom proposal with an invalid sponsor code and deadline time
    Given I'm logged in with mresearcher
    And the Proposal Creator creates a nonrandom Proposal with an invalid <text>
    Then an error should appear that says <error>
  Examples:
    | text                  | error                          |
    | sponsor code          | a valid sponsor is required    |
    | sponsor deadline time | the deadline time is not valid |