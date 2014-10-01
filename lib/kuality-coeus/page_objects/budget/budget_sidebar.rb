class BudgetSidebar < BasePage

  action(:return_to_proposal) { |b| b.button(data_submit_data: '{"methodToCall":"openProposal"}').click }
  action(:periods_and_totals) { |b| b.link(data_submit_data: '{"methodToCall":"navigate","actionParameters[navigateToPageId]":"PropBudget-PeriodsPage"}').click; b.loading }
  action(:rates) { |b| b.link(data_submit_data: '{"methodToCall":"navigate","actionParameters[navigateToPageId]":"PropBudget-RatesPage"}').click; b.loading }
  action(:personnel_costs) { |b| b.link(text: /Personnel Costs/).click }
  action(:project_personnel) { |b| b.link(data_submit_data: '{"methodToCall":"navigate","actionParameters[navigateToPageId]":"PropBudget-ProjectPersonnelPage"}').click; b.loading }
  action(:assign_personnel) { |b| b.link(data_submit_data: '{"methodToCall":"navigate","actionParameters[navigateToPageId]":"PropBudget-PersonnelPeriodsPage"}').click; b.loading }
  action(:non_personnel_costs) { |b| b.link(data_submit_data: '{"methodToCall":"navigate","actionParameters[navigateToPageId]":"PropBudget-NonPersonnelPage"}').click; b.loading }
  action(:subawards) { |b| b.link(data_submit_data: '{"methodToCall":"navigate","actionParameters[navigateToPageId]":"PropBudget-SubawardsPage"}').click; b.loading }
  action(:institutional_commitments) { |b| b.link(text: /Institutional Commitments/).click }
  action(:cost_sharing) { |b| b.link(data_submit_data: '{"methodToCall":"navigate","actionParameters[navigateToPageId]":"PropBudget-CostSharingPage"}').click; b.loading }
  action(:unrecovered_fna) { |b| b.link(data_submit_data: '{"methodToCall":"navigate","actionParameters[navigateToPageId]":"PropBudget-UnrecoveredFandAPage"}').click; b.loading }
  action(:project_income) { |b| b.link(data_submit_data: '{"methodToCall":"navigate","actionParameters[navigateToPageId]":"PropBudget-ProjectIncomePage"}').click; b.loading }
  action(:modular) { |b| b.link(data_submit_data: '{"methodToCall":"navigate","actionParameters[navigateToPageId]":"PropBudget-ModularPage"}').click; b.loading }
  action(:budget_notes) { |b| b.link(data_submit_data: '{"methodToCall":"navigate","actionParameters[navigateToPageId]":"PropBudget-NotesPage"}').click; b.loading }
  action(:budget_summary) { |b| b.link(data_submit_data: '{"methodToCall":"navigate","actionParameters[navigateToPageId]":"PropBudget-SummaryPage"}').click; b.loading }

end