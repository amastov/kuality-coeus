And /adds a non\-personnel cost to the first Budget period$/ do
  @budget_version.period(1).assign_non_personnel_cost
end

And /adds a non\-personnel cost with a narrow date range and an? '(.*)' category type to the first Budget period$/ do |type|
  @budget_version.period(1).assign_non_personnel_cost category_type: type
  @budget_version.period(1).non_personnel_costs[0].edit start_date: in_a_year[:date_w_slashes], end_date: date_factory(Time.now + (3600*24*371))[:date_w_slashes]
end

And /adds a non\-personnel cost with an? '(.*)' category type and some cost sharing to the first Budget period$/ do |type|
  @budget_version.period(1).assign_non_personnel_cost
  @budget_version.period(1).non_personnel_costs[0].edit cost_sharing: random_dollar_value(500000)
end

And /adds a non\-personnel cost to the first Budget period with these settings:$/ do |table|
  @add_opts = {}
  @edit_opts = {}
  @field_opts = { 'Category Type'=> :add_opts, 'Total Base Cost' => :add_opts,
                     'Apply Inflation'=>:edit_opts, 'Submit Cost Sharing'=>:edit_opts, 'Cost Sharing'=>:edit_opts }
  table.raw.each{ |item|
    get(@field_opts[item[0]]).store(damballa(item[0]), item[1])
  }
  @budget_version.period(1).assign_non_personnel_cost @add_opts
  @budget_version.period(1).non_personnel_costs[0].edit @edit_opts
end

Then /^the Budget's institutional commitments shows the expected cost sharing value for Period (\d+)$/ do |period|
  cost_share = @budget_version.period(1).non_personnel_costs[0].cost_sharing.to_f + @budget_version.period(1).non_personnel_costs[0].rate_cost_sharing.round(2)
  @budget_version.view 'Cost Sharing'
  on CostSharing do |page|
    expect(page.row_amount(period).to_f).to be_within(0.03).of cost_share
  end
end

And /the number of participants for the category in period 1 can be specified$/ do
  @budget_version.period(1).non_personnel_costs[0].add_participants
end

And /^adds a non\-personnel cost with an? '(.*)' category type to all Budget Periods$/ do |type|
  @budget_version.budget_periods.each do |period|
    period.assign_non_personnel_cost category_type: type
  end
end

And /^the MTDC rate for the non-personnel item is unapplied for all periods$/ do
  @budget_version.view :non_personnel_costs
  on(NonPersonnelCosts).details_of @budget_version.period(1).non_personnel_costs[0].object_code_name
  on EditAssignedNonPersonnel do |page|
    page.rates_tab
    page.apply('MTDC', 'MTDC').clear
    page.save_and_apply_to_other_periods
  end
  on(NonPersonnelCosts).save_and_continue

  @budget_version.budget_periods[1..-1].each_with_index do |period, index|
    period.copy_non_personnel_item @budget_version.period(index+1).non_personnel_costs[0]

    DEBUG.inspect period.non_personnel_costs[0].total_base_cost

  end

  DEBUG.message
  DEBUG.pause 1000

  exit

end

And /^the Budget's F&A costs are zero for all periods$/ do
  @budget_version.view :periods_and_totals
  on PeriodsAndTotals do |page|
    @budget_version.budget_periods.each { |p| page.f_and_a_cost_of(p.number).should=='0.00' }
  end
end

And /^the Budget's unrecovered F&A amounts are as expected for all periods$/ do

  rates = @budget_version.institute_rates['F & A'].find_all { |rate|
    rate[:rate_class_code]=='MTDC' && rate[:description]=='MTDC' && rate[:on_campus]=='Yes'
  }

  @budget_version.view :periods_and_totals
  @budget_version.budget_periods.each { |period| DEBUG.inspect period }
  period.non_personnel_costs[0].get_fna_rates(rates)
  DEBUG.inspect period.non_personnel_costs[0].fna_rates
  DEBUG.inspect period.non_personnel_costs[0].daily_total_base_cost
end

And /^(syncs )?the (.*) cost( is synced)? with the (direct|total) cost limit for each period$/ do |x, npc, y, cost|
  cost_limit = { 'direct' => :sync_to_period_dc_limit, 'total' => :sync_to_period_tc_limit }
  @budget_version.budget_periods.each do |period|
    on(NonPersonnelCosts).view_period period.number
    period.non_personnel_costs[0].send(cost_limit[cost])
  end
end

And /^edits the total cost and cost sharing amounts for the Equipment item in period (\d+)$/ do |x|
  pending
end

And /^deletes the equipment items in periods (\d+) through (\d+)$/ do |arg, arg1|
  pending
end

And /^adds an? '(.*)' item to the first period and copies it to the later ones$/ do |category_type|
  @budget_version.period(5).assign_non_personnel_cost category_type: category_type

  DEBUG.pause 1000

end