@IACUC
Feature: Adding Organizations to IACUC Protocols

  [KCTEST-884] As a researcher I want the ability to add Organizations to a IACUC protocol
  [KCTEST-888] Modified organization contact information is reverted to original data if protocol is not saved.

  Background: Establish a Protocol Creator
    * Users exist with the following roles: IACUC Protocol Creator, IACUC Administrator

  @KCTEST-884
  Scenario: Add an Organization to the IACUC proposal
    Given the IACUC Protocol Creator creates an IACUC Protocol
    When  the IACUC Protocol Creator adds an organization to the IACUC Protocol
    Then  the Organization that was added should display on the IACUC Protocol
    And   the added Organization information should display on the inquiry page

  @KCTEST-884
  Scenario: Organization cannot be added to the IACUC Protocol without required fields
    Given the IACUC Protocol Creator creates an IACUC Protocol
    When  the IACUC Protocol Creator adds an organization to the IACUC Protocol without the required fields
    Then  an error should appear that says organization id is required
    And   an error should appear that says organization type is required

  @KCTEST-888
  Scenario: Modify an Added Organization's contact information on an IACUC Protocol
    Given the IACUC Protocol Creator creates an IACUC Protocol
    And   adds an organization to the IACUC Protocol
    And   changes the contact information on the added Organization
    When  the IACUC Protocol Creator reopens the IACUC Protocol without saving the changes
    Then  on the IACUC Protocol the contact information for the added Organization is reverted