Feature: Editing a Budget's Non-Personnel Costs

  As a researcher, I want to be able to quickly sync my period Equipment line items
  with the Period Direct Cost Limit, for every period of the Budget.

  Background:
    * Users exist with the following roles: Proposal Creator
    * the Proposal Creator creates a 5-year, 'Research' Proposal
    * creates a Budget Version for the Proposal

  Scenario: Syncing non-personnel line items in all periods with direct cost limits
    Given the Proposal Creator adds a direct cost limit to all of the Budget's periods
    And   adds a non-personnel cost with an 'Equipment' category type to all Budget Periods
    When  the non-personnel cost is synced with the direct cost limit for each period
    Then  the direct cost is equal to the direct cost limit in all periods

  Scenario: Syncing non-personnel line items in all periods with total cost limits
    Given the Proposal Creator adds a total cost limit to all of the Budget's periods
    And   adds a non-personnel cost with an 'Equipment' category type to all Budget Periods
    And   adds a non-personnel cost with a 'Travel' category type to all Budget Periods
    When  the Equipment cost is synced with the total cost limit for each period
  @failing
  Scenario: Removing F&A charges, applying to all Budget periods
    Given the Proposal Creator adds a non-personnel cost with a narrow date range and a 'Travel' category type to the first Budget period
    When  the MTDC rate for the non-personnel item is unapplied for all periods
    Then  the Budget's F&A costs are zero for all periods
    And   the Budget's unrecovered F&A amounts are as expected for all periods
  @test
  Scenario: Deleting line items from later periods
    *  adds an 'Equipment' item to the first period and copies it to the later ones
    *  edits the total cost and cost sharing amounts for the Equipment item in period 2
    *  deletes the equipment items in periods 3 through 5
