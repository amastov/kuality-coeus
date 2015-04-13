Feature: Adding Budget Non-Personnel Costs

  As a researcher, I want to be able to add non-personnel expenses to a period of my budget.

  Background:
    * Users exist with the following roles: Proposal Creator
    * the Proposal Creator creates a 2-year, 'Research' Proposal
    * creates a Budget Version for the Proposal

  Scenario: Add a non-personnel line item with cost share to period 1
    Given the Proposal Creator adds a non-personnel cost with a 'Travel' category type and some cost sharing to the first Budget period
    Then  the Budget's institutional commitments shows the expected cost sharing value for Period 1

  Scenario: Adding participant support to a Budget
    When the Proposal Creator adds a non-personnel cost with a narrow date range and a 'Participant Support' category type to the first Budget period
    Then the number of participants for the category in period 1 can be specified