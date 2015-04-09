class DetailsAndRates < BasePage

  buttons 'Close', 'Apply To Later Periods'

  action(:general) { |b| b.tab_list.li(text: 'General').link.click }
  action(:rates) { |b| b.tab_list.li(text: 'Rates').link.click }

  element(:save_changes) { |b| b.div(class: 'uif-footer clearfix', data_parent: 'PropBudget-AssignPersonnelToPeriodsPage-DetailsAndRates').button(data_dismissdialogid: 'PropBudget-AssignPersonnelToPeriodsPage-DetailsAndRates', text: 'Save Changes').click; b.loading }

  # General
  element(:apply_inflation) { |b| b.checkbox(name: 'addProjectPersonnelHelper.budgetLineItem.applyInRateFlag') }

  # Rates
  value(:rate_amounts) { |b|
    array = []
    b.noko_rates_table.trs.each do |tr|
      array << {
                 class: tr[0].text,
                  type: tr[1].text,
             rate_cost: tr[2].text,
     rate_cost_sharing: tr[3].text
           }
    end
    array
  }

  p_element(:apply) { |rate_class, type, b| b.rates_table.trs.find{ |tr| tr[0].text==rate_class && tr[1].text==type }.checkbox }

  private

  element(:tab_list) { |b| b.ul(id: 'PropBudget-AssignPersonnelToPeriodsPage-DetailsAndRates-TabSection_tabList') }

  element(:rates_table) { |b| b.div(id: 'PropBudget-AssignPersonnelToPeriodsPage-DetailsAndRates-TabSection').table(class: /dataTable/).tbody }
  value(:noko_rates_table) { |b| b.no_frame_noko.div(id: 'PropBudget-AssignPersonnelToPeriodsPage-DetailsAndRates-TabSection').table(class: /dataTable/).tbody }

end