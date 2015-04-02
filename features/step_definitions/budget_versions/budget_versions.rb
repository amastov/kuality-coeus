When /^(the (.*) user |)creates a Budget Version for the Proposal$/ do |text, role_name|
  steps %{ * I log in with the #{role_name} user } unless text==''
  @proposal.add_budget_version
  @budget_version = @proposal.budget_versions[0]
end

When /a Budget Version is created for the Proposal$/ do
  @proposal.add_budget_version
  @budget_version = @proposal.budget_versions[0]
end

When /^I add a subaward budget to the Budget Version$/ do
  @budget_version.add_subaward_budget
end

Then /^opening the Budget Version will display a warning about the date change$/ do
  @budget_version.view 'Periods And Totals'
  on(PeriodsAndTotals).warnings.should include 'The Project Start and/or End Dates have changed from the previous version of this budget. Please update the Project Start and/or End Dates.'
end

When /^correcting the Budget Version date will remove the warning$/ do
  @budget_version.default_periods
  on(Parameters).warnings.size.should be 0
end

Given /^(the (.*) user |)creates a final and complete Budget Version for the Proposal$/ do |text, role_name|
  steps %{ * I log in with the #{role_name} user } unless text ==''
  @proposal.add_budget_version status: 'Complete', final: :set
end

When /^I? ?copy the Budget Version \(all periods\)$/ do
  @copied_budget_version = @budget_version.copy_all_periods random_alphanums
end

When /^I? ?enter dollar amounts for all the budget periods$/ do
  @budget_version.budget_periods.each do |p|
    randomized_values = {}
    p.dollar_fields[1..-1].each { |f| randomized_values.store(f, random_dollar_value(500000)) }
    p.edit randomized_values
  end
end

Then /^the copied budget's values are all as expected$/ do
  @copied_budget_version.view 'Periods And Totals'
  @copied_budget_version.budget_periods.each do |period|
    n = period.number
    on PeriodsAndTotals do |page|
      page.edit_period(n)
      page.start_date_of(n).value.should==period.start_date
      page.end_date_of(n).value.should==period.end_date
      page.total_sponsor_cost_of(n).value.to_f.round(2).should==(period.direct_cost.to_f+period.f_and_a_cost.to_f).round(2)
      page.direct_cost_of(n).value.should==period.direct_cost
      page.f_and_a_cost_of(n).value.should==period.f_and_a_cost
      page.unrecovered_f_and_a_of(n).value.should==period.unrecovered_f_and_a
      page.cost_sharing_of(n).value.should==period.cost_sharing
      page.cost_limit_of(n).value.should==period.cost_limit
      page.direct_cost_limit_of(n).value.should==period.direct_cost_limit
    end
  end
end

When /deletes? one of the budget periods$/ do
  @budget_version.delete_period(rand(@budget_version.budget_periods.size)+1)
end

When /^I? ?changes? the date range for one of the periods$/ do
  period = @budget_version.budget_periods.sample
  new_start_date = '03'+period.start_date[/\/\d+\/\d+$/]
  new_end_date = '10'+period.end_date[/\/\d+\/\d+$/]
  period.edit start_date: new_start_date, end_date: new_end_date
end

When /the Budget Version's periods are reset to defaults$/ do
  @original_period_count = @budget_version.budget_periods.count
  @budget_version.reset_to_period_defaults
end

Then /^all budget periods get recreated, zeroed, and given default date ranges$/ do
  default_start_dates={1=>@proposal.project_start_date}
  default_end_dates={@years=>@proposal.project_end_date}
  1.upto(@years-1) do |i|
    default_start_dates.store(i+1, "01/01/#{@proposal.project_start_date[/\d+$/].to_i+i}")
    default_end_dates.store(@years-i, "12/31/#{@proposal.project_end_date[/\d+$/].to_i-i}")
  end
  on PeriodsAndTotals do |page|
    page.period_count.should==@years
    1.upto(@years) do |x|
      # Note: This 'edit' and subsequent 'save', below, are an artifact
      # of the page design. They are here
      # simply because we need to expose the text fields to view. No
      # actual editing or saving is taking place.
      page.edit_period(x)
      page.start_date_of(x).value.should==default_start_dates[x]
      page.end_date_of(x).value.should==default_end_dates[x]
      page.total_sponsor_cost_of(x).value.should=='0.00'
      page.direct_cost_of(x).value.should=='0.00'
      page.f_and_a_cost_of(x).value.should=='0.00'
      page.unrecovered_f_and_a_of(x).value.should=='0.00'
      page.cost_sharing_of(x).value.should=='0.00'
      page.cost_limit_of(x).value.should=='0.00'
      page.direct_cost_limit_of(x).value.should=='0.00'
      page.save_period(x)
    end
  end
end

When /includes the Budget Version for submission$/ do
  @budget_version.include_for_submission
end

When /marks? the Budget Version complete$/ do
  @budget_version.complete
end

When /^(the (.*) user |)creates a Budget Version with cost sharing for the Proposal$/ do |text, role_name|
  steps %{ * I log in with the #{role_name} user } unless text==''
  @proposal.add_budget_version
  @budget_version = @proposal.budget_versions[0]
  @budget_version.edit_period(1, cost_sharing: random_dollar_value(1000000))
  @budget_version.period(1).cost_sharing_distribution_list.each do |cs|
    cs.edit source_account: random_alphanums
  end
end

And /^(the (.*) user |)creates a Budget Version with unrecovered F&A for the Proposal$/ do |text, role_name|
  steps %{ * I log in with the #{role_name} user } unless text==''
  @proposal.add_budget_version
  @budget_version = @proposal.budget_versions[0]
  steps %q{ * add unrecovered F&A to the first period of the Budget Version }
end

And /adds? unrecovered F&A to the first period of the Budget Version$/ do
  total_allocated = random_dollar_value(1000000).to_f
  first_amount = (total_allocated/4).round(2)
  amounts = [ first_amount.to_s, (total_allocated - first_amount).round(2).to_s ]
  @budget_version.edit_period(1, unrecovered_f_and_a: total_allocated)
  @budget_version.period(1).unrecovered_fa_dist_list.each_with_index do |ufna, index|
    ufna.edit source_account: random_alphanums, amount: amounts[index]
  end
end

And /^adds another item to the budget period's cost sharing distribution list$/ do
  @budget_version.budget_periods.period(1).add_item_to_cost_sharing_dl
end

And /^adds (\d+) more items to the budget period's cost sharing distribution list$/ do |count|
  count.to_i.times do
    steps %{ * adds another item to the budget period's cost sharing distribution list }
  end
end

And /^adjusts the budget period's cost sharing amount so all funds are allocated$/ do
  @budget_version.period(1).edit cost_sharing: @budget_version.budget_periods.period(1).cost_sharing_distribution_list.total_funds.to_s
end

Then /^the Budget Version is no longer editable$/ do
  on(Header).researcher
  on(ResearcherMenu).search_proposals
  @budget_version.view 'Periods And Totals'
  on PeriodsAndTotals do |page|
    page.add_budget_period_element.should_not be_present
  end
  # TODO: Add more validations here
end

Then /the Budget Version should have two more budget periods/ do
  @budget_version.budget_periods.count.should==@original_period_count+2
end

Then /^the copied budget is not marked 'for submission'$/ do
  on(PeriodsAndTotals).budget_versions
  on(BudgetsDialog).submission_message(@copied_budget_version.name).should_not be_visible
end

And /^notes the Budget Period's summary totals$/ do
  @budget_version.period(1).get_dollar_field_values
end

And /^the Budget Version is opened$/ do
  @proposal.view 'Budget'
  on(Budgets).open @budget_version.name
end

And /adds a direct cost limit to all of the Budget's periods$/ do
  @budget_version.budget_periods.each do |period|
    period.edit direct_cost_limit: random_dollar_value(50000)
  end
end