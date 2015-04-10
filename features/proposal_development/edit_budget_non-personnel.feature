Feature: Editing a Budget's Non-Personnel Costs

  As a researcher, I want to be able to quickly sync my period Equipment line items
  with the Period Direct Cost Limit, for every period of the Budget.

  Background:
    * Users exist with the following roles: Proposal Creator
    * the Proposal Creator creates a 5-year, 'Research' Proposal
    * creates a Budget Version for the Proposal
  @test
  Scenario: Syncing line items in later periods with direct cost limits
    Given the Proposal Creator adds a direct cost limit to all of the Budget's periods
    And   adds a non-personnel cost with an 'Equipment' category type to all Budget Periods
    When  the non-personnel cost is synced with the direct cost limit for each period
    Then  the direct cost is equal to the direct cost limit in all periods
  @failing
  Scenario: Removing F&A charges, applying to all Budget periods
    Given the Proposal Creator adds a non-personnel cost with a narrow date range and a 'Travel' category type to the first Budget period
    When  the MTDC rate for the non-personnel item is unapplied for all periods
    Then  the Budget's F&A costs are zero for all periods
    And   the Budget's unrecovered F&A amounts are as expected for all periods