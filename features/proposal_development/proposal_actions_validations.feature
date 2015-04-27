@proposal
Feature: Proposal Actions Validations

  As a researcher I want to know if my development proposal contains any errors
  so that I can fix them prior to submitting my proposal

  Background: Logged in with a proposal creator user
    * a User exists with the role: 'Proposal Creator'

  Scenario: A PI has not been added to the proposal
    Given the Proposal Creator creates a Proposal
    And   the Proposal has no principal investigator
    When  data validation is activated
    Then  an error is shown that says there is no principal investigator

  Scenario: Sponsor deadline date is missing
    Given the Proposal Creator creates a Proposal without a sponsor deadline date
    When  data validation is activated
    Then  a warning is shown that says sponsor deadline date not entered

  Scenario: Sponsor deadline date has passed
    Given the Proposal Creator creates a Proposal with a sponsor deadline in the past
    When  data validation is activated
    Then  an error is shown that says the sponsor deadline has passed

  Scenario Outline: Investigators added but not certified
    Given the Proposal Creator creates a Proposal with an un-certified <Person>
    When  data validation is activated
    Then  an error about un-certified personnel is shown

    Examples:
    | Person                 |
    | Co-Investigator        |
    | Principal Investigator |