class DetailsAndRates < BasePage

  expected_element :tab_list

  buttons 'Close', 'Apply To Later Periods'

  action(:general) { |b| b.tab_list.li(text: 'General').link.click }
  action(:rates) { |b| b.tab_list.li(text: 'Rates').link.click }

  element(:save_changes) { |b| b.div(class: 'uif-footer clearfix', data_parent: 'PropBudget-AssignPersonnelToPeriodsPage-DetailsAndRates').button(data_dismissdialogid: 'PropBudget-AssignPersonnelToPeriodsPage-DetailsAndRates', text: 'Save Changes').click; b.loading }

  # General
  element(:apply_inflation) { |b| b.checkbox(name: 'addProjectPersonnelHelper.budgetLineItem.applyInRateFlag') }
  element(:submit_cost_sharing) { |b| b.checkbox(name: 'addProjectPersonnelHelper.budgetLineItem.submitCostSharingFlag') }
  element(:on_campus) { |b| b.checkbox(name: 'addProjectPersonnelHelper.budgetLineItem.onOffCampusFlag') }

  # Inflation Rates
  element(:inflation_rates_table) { |b| b.table(id: 'InflationRateTable') }
  value(:inflation_rates) { |b|
    b.inflation_rates_table.tbody.trs.map { |tr|
      {
          description: tr[0].text,
          start_date: Utilities.datify(tr[1].text),
          institution_rate: tr[2].text.groom,
          applicable_rate: tr[3].text.groom
      }
    }
  }

  # Rates
  value(:rate_amounts) { |b|
    b.noko_rates_table.trs.map do |tr|
      {
                 class: tr[0].text,
                  type: tr[1].text,
             rate_cost: tr[2].text.groom,
     rate_cost_sharing: tr[3].text.groom
           }
    end
  }

  p_element(:apply) { |type, b| b.rates_table.trs.find{ |tr| tr[1].text==type }.checkbox }

  private

  element(:tab_list) { |b| b.ul(id: 'PropBudget-AssignPersonnelToPeriodsPage-DetailsAndRates-TabSection_tabList') }

  element(:rates_table) { |b| b.div(id: 'PropBudget-AssignPersonnelToPeriodsPage-DetailsAndRates-TabSection').table(class: /dataTable/).tbody }
  value(:noko_rates_table) { |b| b.no_frame_noko.div(id: 'PropBudget-AssignPersonnelToPeriodsPage-DetailsAndRates-TabSection').table(class: /dataTable/).tbody }

end