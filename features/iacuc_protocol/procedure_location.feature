@iacuc @wip
Feature: Add, edit, delete procedures locations on IACUC protocol

  As a researcher I want the ability to create, add, edit and delete procedure locations for an IACUC Protocol
  [KCTEST-915] Application Admin can create new prodecure locations  & types for IACUC Protocols
  [KCTEST-918] IACUC Protocol Creator can create, edit and delete Procedure locations

  Background: Establish a Protocol Creator
    * Users exist with the following roles: IACUC Protocol Creator, IACUC Administrator

  Scenario: Edit the location of a procedure on the IACUC Protocol
    Given the IACUC Protocol Creator creates an IACUC Protocol with one Species
    And   adds a Procedure to the IACUC Protocol
    And   assigns a location to the Procedure with a type of 'Performance Site' on the IACUC Protocol
    When  edits the location type, name, room, description on the IACUC Protocol
    And   reloads the IACUC Protocol to the procedures summary tab
    Then  the edited location information should be displayed in the Procedure summary

  Scenario: Delete a location from a procedure on the IACUC Protocol
    Given the IACUC Protocol Creator creates an IACUC Protocol with one Species
    And   adds a Procedure to the IACUC Protocol
    When  assigns a location to the Procedure with a type of 'Performance Site' on the IACUC Protocol
    And   assigns a second location to the Procedure with a type of 'Performance Site' on the IACUC Protocol
    And   deletes the first location from the Procedure
    Then  the first location is not listed in the Procedure summary
    And   the second location is listed on the IACUC Protocol