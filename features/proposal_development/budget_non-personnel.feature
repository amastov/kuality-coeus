Feature: Adding Budget Non-Personnel Costs

  As a researcher, I want to be able to add non-personnel expenses to a period of my budget.

  Background:
    * Users exist with the following roles: Proposal Creator
    * the Proposal Creator creates a 2-year project Proposal
    * creates a Budget Version for the Proposal

  Scenario: Add non-personnel to period 1 without cost-sharing or inflation
    Given the Proposal Creator adds a non-personnel cost to the first Budget period