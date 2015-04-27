@IP @wip
Feature: Basic Error Validations for Institutional Proposals

  As one who maintains Institutional Proposal docs,
  I expect to see error notifications throughout the IP workflow
  in situations where I miss a required field, enter invalid characters, etc.

  Background:
    * a User exists with the roles: Create Proposal Log, Institutional Proposal Maintainer in the 000001 unit

  Scenario: Attempt to create a Funding Proposal document w/o a required field
    Given the Create Proposal Log user creates an institutional proposal with a missing required field
    Then  an error should appear saying the field is required

  Scenario: Attempt to add a cost sharing element w/o a required field
    Given 1 Approved Institutional Proposal exists
    When  the Institutional Proposal Maintainer adds a cost sharing element with a missing required field
    Then  an error should appear saying the field is required

  Scenario: Filling out cost share amount fields with invalid entries
    Given 1 Approved Institutional Proposal exists
    When  the Institutional Proposal Maintainer enters letters in the numeric cost share fields
    Then  errors should appear warning that the field contents are not valid

  Scenario: Attempt to add an unrecovered f&a element w/o required field
    Given 1 Approved Institutional Proposal exists
    When  the Institutional Proposal Maintainer adds an unrecovered f&a element with a missing required field
    Then  an error should appear saying the field is required

  Scenario: Filling out cost unrecovered f&a fields with invalid entries
    Given 1 Approved Institutional Proposal exists
    When  the Institutional Proposal Maintainer enters letters in the numeric unrecovered F&A fields
    Then  errors should appear warning that the field contents are not valid

  Scenario: Filling out fiscal year with an invalid year
    Given 1 Approved Institutional Proposal exists
    When  the Institutional Maintainer enters an invalid year for the fiscal year field
    Then  an error should appear that says the allowable range for fiscal years