Feature: Updating the Proposal Person Certification Questionnaire

  As a Proposal Creator, I want to know about changes to the Certification
  Questionnaire when they happen, so I can apply them to unfinished
  Proposals.

  Background:
    * the CERTIFICATION_UPDATE_FEATURE_FLAG parameter is set to Y
    * Users exist with the following roles: Proposal Creator, Aggregator
    * the Aggregator cleans up the proposal person questionnaire
  @wip
  Scenario: Adding a question to the Person Certification Questionnaire
    Given the Proposal Creator creates a Proposal
    And   adds a principal investigator to the Proposal
    And   certifies the Proposal's personnel
    When  the Aggregator adds a question to the proposal person questionnaire
    Then  the Proposal Creator can answer the new certification question for the personnel
  @wip
  Scenario: Updated questionnaires don't affect submitted Proposals
    Given the Proposal Creator submits a new Proposal into routing
    When  the Aggregator adds a question to the proposal person questionnaire
    Then  the questionnaire update dialog does not appear when the Creator views the personnel