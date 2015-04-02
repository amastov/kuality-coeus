class BudgetSidebar < BasePage

  action(:return_to_proposal) { |b| b.button(data_submit_data: '{"methodToCall":"openProposal"}').click }
  action(:periods_and_totals) { |b| b.link(name: 'PropBudget-PeriodsPage').click; b.loading }
  alias_method :periods__totals, :periods_and_totals
  action(:rates) { |b| b.link(name: 'PropBudget-RatesPage').click; b.loading }
  action(:personnel_costs) { |b| b.link(text: /Personnel Costs/).click }
  element(:assign_personnel_link) { |b| b.link(name: 'PropBudget-AssignPersonnelToPeriodsPage') }
  element(:project_personnel_link) { |b| b.link(name: 'PropBudget-ProjectPersonnelPage') }
  action(:project_personnel) { |b| b.personnel_costs unless b.project_personnel_link.present?; b.project_personnel_link.click;  b.loading }
  action(:assign_personnel) { |b| b.personnel_costs unless b.assign_personnel_link.present?; b.assign_personnel_link.when_present.click; b.loading }
  action(:non_personnel_costs) { |b| b.link(name: 'PropBudget-NonPersonnelCostsPage').click; b.loading }
  action(:subawards) { |b| b.link(name: 'PropBudget-SubawardsPage').click; b.loading }
  action(:institutional_commitments) { |b| b.link(text: /Institutional Commitments/).click; b.link(name: 'PropBudget-UnrecoveredFandAPage').wait_until_present }
  element(:cost_sharing_link) { |b| b.link(name: 'PropBudget-CostSharingPage') }
  action(:cost_sharing) { |b| b.institutional_commitments unless b.cost_sharing_link.present?; b.cost_sharing_link.click; b.loading }
  action(:unrecovered_fna) { |b| b.institutional_commitments unless b.cost_sharing_link.present?; b.link(name: 'PropBudget-UnrecoveredFandAPage').click; b.loading }
  action(:project_income) { |b| b.link(name: 'PropBudget-ProjectIncomePage').click; b.loading }
  action(:modular) { |b| b.link(name: 'PropBudget-ModularPage').click; b.loading }

  # Not technically "sidebar" stuff, but added here for the #view method...
  action(:budget_settings) { |b| b.link(text: 'Budget Settings').click; b.loading }

end