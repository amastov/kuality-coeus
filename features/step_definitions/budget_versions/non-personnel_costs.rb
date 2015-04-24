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

And /^adds a non\-personnel cost to each Budget Period$/ do
  @budget_version.budget_periods.each do |period|
    period.assign_non_personnel_cost
  end
end

And /^adds a non\-personnel cost to each Budget Period that exceeds the direct cost limit$/ do
  @budget_version.budget_periods.each do |period|
    period.assign_non_personnel_cost total_base_cost: (random_dollar_value(1000).to_f
                                                       +period.direct_cost_limit.to_f+1.0).round(2).to_s
  end
end

And /^adds a non\-personnel cost to each Budget Period that exceeds the cost limit$/ do
  @budget_version.budget_periods.each do |period|
    period.assign_non_personnel_cost total_base_cost: (random_dollar_value(1000000).to_f
                                     +period.cost_limit.to_f+1.0).round(2).to_s
  end
end

And /^adds a non\-personnel cost with an? '(.*)' category type to each Budget Period$/ do |type|
  @budget_version.budget_periods.each do |period|
    period.assign_non_personnel_cost category_type: type
  end
end

And /^the F & A rates for the non-personnel item are unapplied for all periods$/ do
  @budget_version.view :non_personnel_costs
  #FIXME - This shouldn't be hard-coded. The stepdef is a bit vague about which non-personnel item we are talking about
  on(NonPersonnelCosts).view_period 1
  @budget_version.period(1).non_personnel_costs.last.edit save_type: :save_and_apply_to_other_periods, apply_indirect_rates: 'No'
  on(NonPersonnelCosts).save_and_continue
  @budget_version.budget_periods[1..-1].each_with_index do |period, index|
    period.copy_non_personnel_item @budget_version.period(index+1).non_personnel_costs.last
  end
end

And /^the Budget's F&A costs are zero for all periods$/ do
  @budget_version.view :periods_and_totals
  on PeriodsAndTotals do |page|
    @budget_version.budget_periods.each { |p| expect(page.f_and_a_cost_of(p.number)).to eq '0.00' }
  end
end

And /^(syncs )?the (first )?non-personnel cost( is synced)? with the (direct|total) cost limit for each period$/ do |x, npc, y, cost|
  cost_limit = { 'direct' => :sync_to_period_dc_limit, 'total' => :sync_to_period_c_limit }
  @budget_version.budget_periods.each do |period|
    on(NonPersonnelCosts).view_period period.number
    period.non_personnel_costs[0].send(cost_limit[cost])
  end
end

And /^edits the total cost and cost sharing amounts for the Non\-Personnel Cost in period (\d+)$/ do |period_number|
  @budget_version.period(period_number).view :non_personnel_costs
  on(NonPersonnelCosts).view_period period_number
  tbc = random_dollar_value(30000)
  @budget_version.period(period_number).non_personnel_costs.last.edit total_base_cost: tbc, cost_sharing: random_dollar_value(15000)
end

And /^the Non-Personnel Cost item in periods (\d+) through (\d+) are deleted$/ do |n, x|
  @budget_version.budget_periods[n.to_i-1, x.to_i-1].each do |period|
    ocn = period.non_personnel_costs.last.object_code_name
    on(NonPersonnelCosts).view_period period.number
    # FIXME: This will fail in the rare case there are multiple NPCs with the same object code,
    # because this delete will grab the FIRST one added, instead of the last one...
    period.non_personnel_costs.delete(ocn)
  end
end

And /^adds a(nother)? Non-Personnel item to the first period and copies it to the later ones$/ do |x|
  @budget_version.period(1).assign_non_personnel_cost
  @budget_version.period(1).non_personnel_costs.last.edit
  @budget_version.save_npc_and_apply_to_later(@budget_version.period(1), @budget_version.period(1).non_personnel_costs.last)
end

And /^adds an NPC with a base cost lower than the lowest cost limit to the 1st period and copies it to the others$/ do
  lowest_cost_limit = @budget_version.budget_periods.collect{ |p| p.cost_limit }.sort[0]
  @budget_version.period(1).assign_non_personnel_cost total_base_cost: (lowest_cost_limit.to_f/5).round(2)
  @budget_version.save_npc_and_apply_to_later(@budget_version.period(1), @budget_version.period(1).non_personnel_costs.last)
end

And /adds some Non-Personnel Costs to the first period$/ do
  category_types = ['Equipment','Travel','Participant Support','Other Direct'].shuffle
  (rand(3)+1).times do |x|
    @budget_version.period(1).assign_non_personnel_cost category_type: category_types[x]
    @budget_version.period(1).non_personnel_costs.last.edit
  end
end