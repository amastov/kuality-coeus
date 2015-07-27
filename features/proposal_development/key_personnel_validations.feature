@proposal
Feature: Proposal Key Personnel Validations

  As a researcher I want to know if there are problems
  with my Proposal's key personnel so that I can fix them
  before I submit the Proposal

  Background: The admin user creates a proposal
    * a User exists with the role: 'Proposal Creator'
    * the Proposal Creator creates a Proposal

  Scenario Outline: I should see an error when I add Credit Split percentages above 100 or less than 0
    When I add a Principal Investigator with a <Split> credit split of <Percentage>
    Then an error should appear that says the credit split is not a valid percentage

    Examples:
    | Split           | Percentage |
    | Responsibility  | -0.01      |
    | Financial       | 1000       |
  @wip
  Scenario: Data Validation of Credit Split not totalling 100%
    Given I add a Principal Investigator with a Financial credit split of 99.99
    When  data validation is activated
    Then  an error should say the credit split does not equal 100%
  # https://kualico.atlassian.net/browse/RESKC-666
  @system_failure
  Scenario: I should see an error when I add a key person without a specified proposal role
    When I add a key person without a key person role
    Then an error should appear that says a key person role is required

  Scenario: Can't add the same person to Personnel twice
    When I add a principal investigator to the Proposal
    Then the same person cannot be added to the Proposal personnel again