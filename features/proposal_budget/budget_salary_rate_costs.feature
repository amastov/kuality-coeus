Feature: Employee Salary Rate Costs and Cost Share

  Description TBW

  Background:

  @test
  Scenario: Add Employee with a requested Salary
    * a User exists with the role: 'Proposal Creator'
    Given the Proposal Creator creates a 9.5-month 'Research' activity type Proposal
    And   creates a Budget Version for the Proposal
    And   adds an employee to the Budget personnel
    When  the Proposal Creator assigns a 'Research Assistant / Associate' Person to Period 1, where the charged percentage is lower than the effort
    Then  the Project Person's requested salary for the Budget period is as expected
    And   the Person's Rates show correct costs and cost sharing amounts

  Scenario: Unapplying the Research Rate for an employee
    Given the Proposal Creator creates a Proposal with a 'Research' activity type
    And   creates a Budget Version for the Proposal
    And   adds an employee to the Budget personnel
    And   a 'Research Assistant / Associate' person is assigned to Budget period 1
    And   notes the Budget Period's summary totals
    When  the 'Employee Benefits' 'Salaries - Classified: SalClass' rate for the 'Research Assistant / Associate' personnel is unapplied
    Then  the Period's Direct Cost is lowered by the expected amount

  Scenario: Unapplying the inflation rate for an employee
    Given the Proposal Creator creates a Proposal with a 'Research' activity type
    And   creates a Budget Version for the Proposal
    And   adds an employee to the Budget personnel
    And   a 'Research Assistant / Associate' person is assigned to Budget period 1
    And   notes the Budget Period's summary totals
    When  inflation is un-applied for the 'Research Assistant / Associate' personnel
    Then  the Period's Direct Cost is lower than before