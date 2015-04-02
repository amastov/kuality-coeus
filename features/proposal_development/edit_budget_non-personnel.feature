Feature: Editing a Budget's Non-Personnel Costs

  As a researcher, I want to be able to quickly sync my period Equipment line items
  with the Period Direct Cost Limit, for every period of the Budget.

  Background:
    * Users exist with the following roles: Proposal Creator
    * the Proposal Creator creates a 5-year, 'Research' Proposal
    * creates a Budget Version for the Proposal
  # Can't be completed until https://jira.kuali.org/browse/KRAFDBCK-12469 is fixed...
  Scenario: TBW
    Given the Proposal Creator adds a direct cost limit to all of the Budget's periods
    And   adds a non-personnel cost with an 'Equipment' category type to all Budget Periods
  @test
  Scenario: Removing F&A charges, applying to all Budget periods
    Given the Proposal Creator adds a non-personnel cost with a 'Travel' category type to the first Budget period
    When  the MTDC rate for the non-personnel item is unapplied for all periods
    Then  the Budget's F&A costs are zero for all periods
    And   the Budget's unrecovered F&A amounts are as expected for all periods