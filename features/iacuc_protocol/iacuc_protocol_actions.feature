@iacuc
Feature: Protocol actions for IACUC

  [KCIAC-256] IACUC Admin can suspend, terminate, expire and withdraw IACUC protocols
  [KCTEST-881] expiration date should be later than the approval date on an approved IACUC Protocol
  [KC-TA-5417] IACUC Admin can deactivate and remove holds placed on IACUC Protocols

  Background:
    * Users exist with the following roles: IACUC Protocol Creator, Modify IACUC Protocols, IACUC Administrator
    * the IACUC Protocol Creator submits an IACUC Protocol for admin review
    * the IACUC Administrator approves the IACUC Protocol

  Scenario: Terminate an IACUC Protocol
    When  the IACUC Administrator terminates the IACUC Protocol
    Then  the IACUC Protocol submission status should be Terminated

  Scenario: Expire an IACUC Protocol
    When  the IACUC Administrator expires the IACUC Protocol
    Then  the IACUC Protocol status should be Expired

  Scenario: Verify the expiration date is set after the IACUC Protocol is approved
    Then  the expiration date is set for the Protocol

  Scenario: IACUC Admin deactivates an IACUC Protocol
    When  the IACUC Administrator deactivates the IACUC Protocol
    Then  the IACUC Protocol status should be Deactivated

  Scenario: IACUC Admin lifts a hold on an IACUC Protocol that was placed on hold
    Given the IACUC Administrator places the IACUC Protocol on hold
    When  the IACUC Administrator lifts the hold placed on the IACUC Protocol
    Then  the IACUC Protocol submission status should be Lift Hold