@iacuc
Feature: Protocol actions for IACUC Designated Member Review

  TBD

  Background:
    * Users exist with the following roles: IACUC Protocol Creator, IACUC Administrator
    * the IACUC Admin verifies that the KC IACUC 1 committee has future scheduled events
    * the IACUC Protocol Creator submits an IACUC Protocol for designated member review

  Scenario: IACUC Protocol with non-employee reviewer
    When the IACUC Administrator modifies the IACUC Protocol's submission request so the non-employee is a reviewer
    Then the non-employee's review comments can be added to the online review document
  @smoke
  Scenario: Withdraw an IACUC Protocol
    When  the IACUC Administrator withdraws the IACUC Protocol
    Then  the IACUC Protocol status should be Withdrawn

  Scenario: Submitted IACUC Protocols cannot be deleted
    Then  the IACUC Administrator cannot delete the Protocol

  Scenario: Create an IACUC Protocol Amendment
    Given the IACUC Administrator assigns committee members to review the submission
    When  the IACUC Administrator approves the Protocol
    Then  the IACUC Protocol status should be Active
    And   the IACUC Protocol submission status should be Approved
  @wip
  Scenario: Verify the expiration date is set after the IACUC Protocol is approved
    Then  the expiration date is set for the Protocol
  @wip
  Scenario: IACUC Admin deactivates an IACUC Protocol
    When  the IACUC Administrator deactivates the IACUC Protocol
    Then  the IACUC Protocol status should be Deactivated
  @wip
  Scenario: IACUC Admin lifts a hold on an IACUC Protocol that was placed on hold
    Given the IACUC Administrator places the IACUC Protocol on hold
    When  the IACUC Administrator lifts the hold placed on the IACUC Protocol
    Then  the IACUC Protocol submission status should be Lift Hold