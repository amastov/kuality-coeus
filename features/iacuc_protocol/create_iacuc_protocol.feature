@iacuc
Feature: Creating IACUC Protocols

  As a researcher I want the ability to create a protocol for animal subjects
  [KCTEST-912] IACUC Protocol Creator can add personnel member to the procedure
  [KCTEST-928,929,930] ThreeRs should be editable and display edits when saved

  Background:
    * Users exist with the following roles: IACUC Protocol Creator
    * the IACUC Protocol Creator creates an IACUC Protocol with the three R's

  Scenario: IACUC Protocol initial status
    Then the IACUC Protocol status should be Pending/In Progress
    And  there are no errors on the page

  Scenario: Personnel with qualifications can be added to a procedure and display on summary
    Given the Protocol Creator adds 1 personnel member to the IACUC Protocol
    And   adds a Species group to the IACUC Protocol
    And   adds a Procedure to the IACUC Protocol
    When  a qualification and procedure are added to the procedure person
    Then  the procedures summary will display qualifications for the personnel

  Scenario: The Three Principles fields can be edited
    When  the IACUC Protocol Creator edits the three principles of the IACUC Protocol
    Then  the three principles should have the edited values