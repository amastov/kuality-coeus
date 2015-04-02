@IACUC
Feature: IACUC Protocol adding special reviews and verify correct error messages display

  Add special reviews to the IACUC Protocol and verify errors display when fields are entered incorrectly
  [KCTEST-1134] Protocol Creator can add and edit Special Reviews on their IACUC Protcol
  [KCTEST-1140] When incorrectly completed the Special Review should display correct error messages

  Background: Establish a Protocol Creator
    * Users exist with the following roles: IACUC Protocol Creator, IACUC Administrator

  @KCTEST-1134
  Scenario: Add special review to the IACUC Protocol
    When the IACUC Protocol Creator creates an IACUC Protocol
    And  adds a Special Review to the IACUC Protocol
    Then the first Special Review should be displayed on the IACUC Protocol

  @KCTEST-1134
  Scenario: Edit special review on the IACUC Protocol
    Given the IACUC Protocol Creator creates an IACUC Protocol
    And   the IACUC Protocol Creator adds a Special Review to the IACUC Protocol
    When  the IACUC Protocol Creator edits the first Special Review on the IACUC Protocol
    Then  the first Special Review should not be displayed on the IACUC Protocol
    And   the edited Special Review should display on the IACUC Protocol

  @KCTEST-1140
  Scenario: Verify Special Review error messages display for type, approval status, and invalid dates
    Given the IACUC Protocol Creator creates an IACUC Protocol
    When  adds a Special Review with incorrect data
    Then  error messages should appear for the required fields on the Special Review
    And   error messages should appear for invalid dates on the Special Review

  @KCTEST-1140
  Scenario: Verify Special Review error messages display for human subjects when approved with an exemption
    Given the IACUC Protocol Creator creates an IACUC Protocol
    When  adds a Special Review for human subjects, status approved, and an exemption
    Then  an error should appear that says the protocol number is required for human subjects
    And   an error should appear that says human subject cannot have exemptions

  Scenario: Verify Special Review error messages display for application date later than approval and expiration dates.
    Given the IACUC Protocol Creator creates an IACUC Protocol
    When  adds a Special Review to generate error messages for incorrect date structures
    Then  error messages should appear for incorrect date structures on the Special Review