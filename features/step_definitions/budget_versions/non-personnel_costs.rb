And /adds a non\-personnel cost to the first Budget period$/ do
  @budget_version.period(1).assign_non_personnel_cost
end

And /adds a non\-personnel cost with an? '(.*)' category type to the first Budget period$/ do |type|
  @budget_version.period(1).assign_non_personnel_cost category_type: type
  DEBUG.do {
    puts @proposal.proposal_number
    DEBUG.inspect $current_user.user_name
    @budget_version.period(1).non_personnel_costs[0].edit start_date: in_a_year[:date_w_slashes], end_date: in_a_year[:date_w_slashes]
  }
end

And /adds a non\-personnel cost with an? '(.*)' category type and some cost sharing to the first Budget period$/ do |type|
  @budget_version.period(1).assign_non_personnel_cost category_type: type
  @budget_version.period(1).non_personnel_costs[0].edit cost_sharing: random_dollar_value(500000)
end

And /adds a non\-personnel cost to the first Budget period with these settings:$/ do |table|
  @add_opts = {}
  @edit_opts = {}
  @field_opts = { 'Category Type'=> :add_opts, 'Total Base Cost' => :add_opts,
                     'Apply Inflation'=>:edit_opts, 'Submit Cost Sharing'=>:edit_opts, 'Cost Sharing'=>:edit_opts }
  table.raw.each{ |item|
    get(@field_opts[item[0]]).store(damballa(item[0]), item[1]) }
  @budget_version.period(1).assign_non_personnel_cost @add_opts
  @budget_version.period(1).non_personnel_costs[0].edit @edit_opts
end

Then /^the Budget's institutional commitments shows the expected cost sharing value for Period (\d+)$/ do |period|
  # FIXME: This step only works when there are two (or less) applicable rates in the period.
  cost_sharing = @budget_version.period(1).non_personnel_costs[0].cost_sharing.to_f
  dcs = @budget_version.period(1).non_personnel_costs[0].daily_cost_share
  first_range = (@end_fiscal_year_rate[:start_date]-@budget_version.period(1).non_personnel_costs[0].start_date_datified).to_i
  second_range = (@budget_version.period(1).non_personnel_costs[0].end_date_datified-@end_fiscal_year_rate[:start_date]).to_i+1
  start_fy_rate = @start_fiscal_year_rate[:applicable_rate]/100
  end_fy_rate = @end_fiscal_year_rate[:applicable_rate]/100
  cost_share = cost_sharing + start_fy_rate*dcs*first_range + end_fy_rate*dcs*second_range
  @budget_version.view 'Cost Sharing'
  on CostSharing do |page|
    page.row_amount(period).to_f.should be_within(0.03).of cost_share
  end
end

And /^the applicable rate is the (.*)\-campus '(.*)' '(.*)' '(.*)' for the period's fiscal year\(s\)$/ do |campus, rate, rate_class_code, description|
  on_off = { 'on'=>'Yes', 'off'=>'No' }
  # Get rates...
  rates = @budget_version.institute_rates[rate].find_all { |rate|
    rate[:rate_class_code]==rate_class_code && rate[:description]==description && rate[:on_campus]==on_off[campus]
  }
  # Now gotta figure out what fiscal years are applicable and get those rates...
  @start_fiscal_year_rate = rates.find_all{ |rate|
    rate[:start_date] <= @budget_version.period(1).non_personnel_costs[0].start_date_datified
  }[-1]
  @end_fiscal_year_rate = rates.find_all { |rate|
    rate[:start_date] <= @budget_version.period(1).non_personnel_costs[0].end_date_datified
  }[-1]
end

And /the number of participants for the category in period 1 can be specified$/ do
  @budget_version.period(1).non_personnel_costs[0].add_participants
end

And /^adds a non\-personnel cost with an '(.*)' category type to all Budget Periods$/ do |type|
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