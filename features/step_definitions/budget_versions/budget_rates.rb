And /sets the inflation rate of the Budget's on-campus non-student salaries to (\d+) percent/ do |percentage|
  @budget_version.view 'Rates'
  # FIXME: All this should not be hard-coded. Need to come up with better way to do this.
  # Probably, all this belongs encapsulated in a Data Object class for Budget Rates.
  on Rates do |page|
    page.inflation
    page.applicable_rate('Salaries-Non Student', 'Yes', '2016').set percentage
  end
  @inflation = percentage
end

Then /^the Person's Rates show correct costs and cost sharing amounts$/ do
  @budget_version.view :assign_personnel
  @project_person.monthly_base_salary = @budget_version.personnel.person(@project_person.person).monthly_base_salary
  applicable_rates = @budget_version.institute_rates.values.flatten
  on(AssignPersonnelToPeriods).details_and_rates_of @project_person.object_code
  on DetailsAndRates do |page|
    page.rate_amounts.each do |rate_line|
      # The "on LA" items are unusual rates that we can skip for this test.
      # The MTDC calculation is not yet understood, so it's left off, for now.
      next if rate_line[:type]=~/(MTDC|on LA)$/
      ar = applicable_rates.find{ |r| r[:on_campus]=='Yes' && r[:rate_class_code]==rate_line[:class] && r[:description]==rate_line[:type] }[:applicable_rate]
      rate_line[:rate_cost].groom.should be_within(0.02).of @project_person.rate_cost(ar)
      rate_line[:rate_cost_sharing].groom.should be_within(0.02).of @project_person.rate_cost_sharing(ar)
    end
  end
end

And /^un\-applies the '(.*)' '(.*)' for the '(.*)' personnel$/ do |rate_class, type, object_code|
  @budget_version.view :assign_personnel
  on(AssignPersonnelToPeriods).details_and_rates_of object_code
  on DetailsAndRates do |page|
    page.rates
    @rate_cost = page.rate_amounts.find{ |rate| rate[:class]==rate_class && rate[:type]==type }[:rate_cost]
    page.apply(rate_class, type).clear
    page.save_changes
  end
end

When /the '(.*)' '(.*)' rate for the '(.*)' personnel is unapplied$/ do |rate_class, type, object_code|
  steps "* un-applies the '#{rate_class}' '#{type}' for the '#{object_code}' personnel"
end

When /inflation is un\-applied for the '(.*)' personnel$/ do |object_code|
  @budget_version.view :assign_personnel
  on(AssignPersonnelToPeriods).details_and_rates_of object_code
  on DetailsAndRates do |page|
    page.apply_inflation.clear
    page.save_changes
  end
end

And /^the Period's Direct Cost is lowered by the expected amount$/ do
  @budget_version.view 'Periods And Totals'
  on PeriodsAndTotals do |page|
    page.direct_cost_of(1).to_f.should==(@budget_version.period(1).direct_cost.to_f-@rate_cost.to_f).round(2)
  end
end

And /^the Period's Direct Cost is lower than before$/ do
  @budget_version.view 'Periods And Totals'
  on PeriodsAndTotals do |page|
    page.direct_cost_of(1).to_f.should < @budget_version.period(1).direct_cost.to_f
  end
end

And /^the Budget is synced to the new rates$/ do
  on(SyncBudgetRates).yes
end

And /^the Budget's rates are updated$/ do
  @budget_version.view 'Rates'
  expect{@budget_version.institute_rates}.not_to eq(on(Rates).rates)
end