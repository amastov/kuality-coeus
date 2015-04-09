@Proposal @Smoke
Feature: Creating a proposal development document

  As a researcher I want the ability to create a proposal
  so that I can get funding for my research.

  Background: Logged in with a proposal creator user
    * a User exists with the role: 'Proposal Creator'
  @failing
  Scenario: Successful initiation of proposal with federal sponsor type
    When  the Proposal Creator creates a Proposal with a 'Federal' sponsor type
    Then  The S2S opportunity search should become available

  Scenario: Activating data validation on good Proposal
    Given the Proposal Creator creates a Proposal
    And   adds a principal investigator to the Proposal
    And   sets valid credit splits for the Proposal
    When  data validation is activated
    Then  there are no data validation errors or warnings for the Proposal