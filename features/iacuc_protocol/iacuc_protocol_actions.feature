@IACUC
Feature: Protocol actions for IACUC

  [KCIAC-256] IACUC Admin can suspend, terminate, expire and withdrawal IACUC protocols
  [KCTEST-881] expiration date should be later than the approval date on an approved IACUC Protocol
  [KC-TA-5417] IACUC Admin can deactiveate and remove holds placed on IACUC Protocols

  Background: Establish a Protocol Creator
    * Users exist with the following roles: IACUC Protocol Creator, IACUC Administrator

  @KCIAC-256
  Scenario: Suspend a IACUC Protocol with an amendment
    Given the IACUC Administrator approves a submitted IACUC Protocol
    And   the IACUC Protocol Creator submits an Amendment for review on the IACUC Protocol
    When  the IACUC Administrator approves the amendment for the IACUC Protocol
    And   suspends the IACUC Protocol
    Then  the IACUC Protocol submission status should be Suspended

  @KCIAC-256
  Scenario: Terminate an IACUC Protocol
    When the IACUC Administrator approves a submitted IACUC Protocol
    And  terminates the IACUC Protocol
    Then the IACUC Protocol submission status should be Terminated

  @KCIAC-256
  Scenario: Expire an IACUC Protocol
    When the IACUC Administrator approves a submitted IACUC Protocol
    And  expires the IACUC Protocol
    Then the IACUC Protocol status should be Expired

  @KCIAC-256
  Scenario: Withdraw a submitted IACUC Protocol
    Given the IACUC Protocol Creator submits an IACUC Protocol for admin review
    When  the IACUC Administrator withdrawals the IACUC Protocol
    Then  the IACUC Protocol submission status should be Withdrawn

  @KCTEST-881
  Scenario: Verify the expiration date is set after the IACUC Protocol is approved
    Given the IACUC Protocol Creator submits an IACUC Protocol for admin review
    When  the IACUC Administrator approves the IACUC Protocol
    Then  the expiration date is set for the Protocol

  @KC-TA-5417
  Scenario: IACUC Admin deactivates an IACUC Protocol
    Given the IACUC Administrator approves a submitted IACUC Protocol
    When  the IACUC Administrator deactivates the IACUC Protocol
    Then  the IACUC Protocol status should be Deactivated

  @KC-TA-5417
  Scenario: IACUC Admin lifts a hold on an IACUC Protocol that was placed on hold
    Given the IACUC Administrator approves a submitted IACUC Protocol
    And   places the IACUC Protocol on hold
    When  the IACUC Administrator lifts the hold placed on the IACUC Protocol
    Then  the IACUC Protocol submission status should be Lift Hold