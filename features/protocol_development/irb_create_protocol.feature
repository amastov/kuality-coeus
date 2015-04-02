@IRB @Smoke
Feature: Creating IRB Protocols

  As a researcher I want the ability to create a protocol for human subjects

  Background: Establish a Protocol Creator
    * a User exists with the role: 'Protocol Creator'

  Scenario: Attempt to save a proposal with an invalid lead unit
    Given the Protocol Creator user creates a Protocol with an invalid lead unit code
    Then  an error is shown that indicates the lead unit code is invalid

  Scenario: IRB Protocol missing required field
    When  the Protocol Creator creates an IRB Protocol but misses a required field
    Then  an error should appear saying the field is required

  Scenario: Committee Adv Submission Days and IRB Protocol Review
    Given a User exists with the role: 'IRB Administrator'
    And   the IRB Admin submits a Committee with events scheduled before and after its adv submission days setting
    And   the Protocol Creator creates an IRB Protocol in the Committee's home unit
    When the Protocol is being submitted to that Committee for review
    Then  the earliest available schedule date is based on the Committee's Adv Submission Days value

  Scenario: Exceeding Maximum Protocols
    Given a User exists with the role: 'IRB Administrator'
    And   the IRB Admin submits a Committee that allows a maximum of 1 protocol
    And   the Protocol Creator creates an IRB Protocol in the Committee's home unit
    And   submits the Protocol to the Committee for review
    And   the Protocol Creator creates another IRB Protocol in the Committee's home unit
    When  the second Protocol is submitted to the Committee for review on the same date
    Then  the system warns that the number of protocols exceeds the allowed maximum