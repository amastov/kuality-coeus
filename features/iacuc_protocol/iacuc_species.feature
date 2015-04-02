@IACUC
Feature: Add, edit, delete species on IACUC protocol

  As a researcher I want the ability to add, edit and remove species on an IACUC Protocol
  [KCTEST-904] Species count should display errors when non-numbers are used as a value
  [KCTEST-912] Add personnel to the species with qualifacations

  Background: Establish a Protocol Creator
    * Users exist with the following roles: IACUC Protocol Creator

  @KCTEST-904
  Scenario: Verify species count on the IACUC Protocol displays an error when value contains letters
    Given the IACUC Protocol Creator creates an IACUC Protocol
    When the IACUC Protocol Creator adds a Species with non-integers for the species count
    Then an error should appear warning that the field contents are not valid

  Scenario: Edit a Species on the IACUC Protocol
    Given the IACUC Protocol Creator creates an IACUC Protocol
    When the IACUC Protocol Creator adds a Species with all fields completed
    And saves the IACUC Protocol after modifying the required fields for the Species
    Then the group name, species, pain category, count type, species count should match the modified values

  Scenario: Delete a Species on the IACUC Protocol
    Given the IACUC Protocol Creator creates an IACUC Protocol
    And  adds a Species to the IACUC Protocol
    And  adds a second Species to the IACUC Protocol
    When the IACUC Protocol Creator deletes the first Species
    Then the second Species added should be the only Species on the IACUC Protocol

