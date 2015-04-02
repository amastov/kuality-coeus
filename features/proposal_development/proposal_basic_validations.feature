@Proposal
Feature: Basic validations for Development Proposals

  As a researcher I want the ability to see an error whenever I miss
  a required field/parameter during the creation of a Proposal.

  Background: Logged in with a proposal creator user
    * a User exists with the role: 'Proposal Creator'

  Scenario: Attempt to save a proposal missing a required field
    When the Proposal Creator creates a Proposal while missing a required field
    Then an error should appear saying the field is required

  Scenario: Attempt to save a proposal with an invalid sponsor code
    When the Proposal Creator creates a Proposal with an invalid sponsor code
    Then an error should appear that says a valid sponsor is required

  Scenario: Create Proposal with an invalid project date
    When the Proposal Creator creates a Proposal with an invalid project date
    Then an error message says the date must be in a valid format

  Scenario: Create Proposal with end date prior to start date
    When the Proposal Creator creates a Proposal with an end date prior to the start date
    Then an error should appear that says the start date must be before the end

  Scenario: Proposal Project Title with extended characters
    When the Proposal Creator creates a Proposal with a project title containing extended characters
    Then an error should appear that says the project title can't contain special characters

  Scenario: Proposal's sponsor deadline time is invalid
    When the Proposal Creator creates a Proposal with an invalid sponsor deadline time
    Then an error should appear that says the deadline time is not valid

  Scenario Outline: Proposals with invalid Award or IP IDs
    When the Proposal Creator creates a non-'New' Proposal with <Type>
    Then an error should appear that says <Error>

    Examples:
    | Type                        | Error                                           |
    | an invalid Award ID         | the Award ID is invalid                         |
    | an IP ID that doesn't exist | a valid IP ID must be selected                  |
    | a non-alphanumeric IP ID    | the IP ID can only have alphanumeric characters |