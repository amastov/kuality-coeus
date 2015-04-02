@IRB
Feature: Submitting an IRB Protocol for Review

  This feature summary needs to be written

  Scenario: Submitting a Protocol to a Committee
    Given Users exist with the following roles: IRB Administrator, Protocol Creator
    And   the IRB Admin creates a Committee
    And   schedules at least one event for the Committee
    And   adds four or more paid, voting members to the Committee
    And   submits the Committee
    And   the Protocol Creator creates an IRB Protocol in the Committee's home unit
    And   submits the Protocol to the Committee for review
    When  the IRB Administrator assigns reviewers to the Protocol
    Then  the assigned reviewers get a Protocol Review