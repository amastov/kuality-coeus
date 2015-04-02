@IACUC
Feature: Creating IACUC Protocols

  As a researcher I want the ability to create a protocol for animal subjects
  [KCTEST-34] IACUC Protocol should display an error message when a required field is missed on the Protocol tab
  [KCTEST-912] IACUC Protocol Creator can add personnel member to the procedure
  [KCTEST-928,929,930] ThreeRs should be editable and display edits when saved

  Background: Establish a Protocol Creator
    * Users exist with the following roles: IACUC Protocol Creator, IACUC Administrator

  Scenario: Create a IACUC proposal
    When the IACUC Protocol Creator creates an IACUC Protocol
    Then there are no errors on the page
    And  the IACUC Protocol status should be Pending/In Progress

  @KCTEST-34
  Scenario: IACUC Protocol overview is missing a required field
    When the IACUC Protocol Creator creates an IACUC Protocol but misses a required field
    Then an error should appear saying the field is required

  @KCTEST-912
   Scenario: Personnel with qualifications can be added to a procedure and display on summary
    When the IACUC Protocol Creator creates an IACUC Protocol
    And  adds 1 personnel member to the IACUC Protocol
    Then the personnel member added to the IACUC Protocol is present
    When adds a Species group to the IACUC Protocol
    And  adds a Procedure to the IACUC Protocol
    And  adds a person to the procedure for the species with qualifications
    Then the procedures summary will display qualifications for the personnel

  @KCTEST-928 @KCTEST-929 @KCTEST-930 @unit-testy
  Scenario: The Three Principles fields can be edited
    Given the IACUC Protocol Creator creates an IACUC Protocol with the three principles, reduction, refinement, replacement
    And   edits the Principles of reduction
    And   edits the Principles of refinement
    And   edits the Principles of replacement
    Then  the three principles should have the edited values after saving the IACUC Protocol