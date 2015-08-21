@proposal
Feature: Creating/Editing Budget Versions in Proposal Documents

  As a researcher I want to be able to create budgets in my proposals
  so that I can calculate how much the proposal should be for.

  Background: Create a Budget Version for a 5-year proposal
    * a User exists with the role: 'Proposal Creator'
    * the Proposal Creator creates a 5-year project Proposal
    * creates a Budget Version for the Proposal

  Scenario: Copied budget periods have expected values
    Given I enter dollar amounts for all the budget periods
    When  I copy the Budget Version (all periods)
    Then  the copied budget's values are all as expected

  Scenario: "Default Periods" returns budget periods to a zeroed state
    Given I delete one of the budget periods
    And   enter dollar amounts for all the budget periods
    And   change the date range for one of the periods
    When  the Budget Version's periods are reset to defaults
    Then  all budget periods get recreated, zeroed, and given default date ranges

  Scenario: Only one budget version can be 'final'
    Given the Proposal Creator includes the Budget Version for submission
    When  I copy the Budget Version (all periods)
    Then  the copied budget is not marked 'for submission'

  Scenario: Complete Budgets are read-only
    Given the Proposal Creator includes the Budget Version for submission
    When  the Proposal Creator marks the Budget Version complete
    Then  the Budget Version is no longer editable
  @smoke
  Scenario: Adding years to the Proposal
    Given the Proposal Creator pushes the Proposal end date 2 more years
    When  the Budget Version's periods are reset to defaults
    Then  the Budget Version should have two more budget periods
  @smoke
  Scenario: Changing the Proposal's activity type
    Given the Proposal Creator changes the Proposal's activity type
    And   the Budget Version is opened
    When  the Budget is synced to the new rates
    Then  the Budget's rates are updated