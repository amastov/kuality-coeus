@smoke
Feature: Nonrandom Scenarios

  To speed up execution time of smoke tests,
  new step definitions are provided that have
  deterministic inputs.
  @wip
  Scenario: Editing finalized nonrandom Award when a pending new version exists, select 'yes'
    Given a User exists with the role 'Time And Money Modifier' in unit '000001'
    And   a User exists with the role 'Award Modifier' in unit 'CS'
    And   the Award Modifier creates a nonrandom Award
    #And adds a $100,000 subaward for Clemson University
    And   completes the nonrandom Award requirements
    And   the Award Modifier submits the Award
    And   the Time & Money Modifier submits the Award's T&M document
    And   the Award Modifier edits the finalized Award deterministically
    When  the original Award is edited again
    Then  a confirmation screen asks if you want to edit the existing pending version
    And   selecting 'yes' takes you to the pending version

  Scenario: Copying a Proposal
    Given mresearcher creates a non-random Proposal
    Then  the Proposal can be copied