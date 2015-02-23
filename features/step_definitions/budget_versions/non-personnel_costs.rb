And /adds a non\-personnel cost to the first Budget period$/ do
  @budget_version.period(1).assign_non_personnel_cost
end

And /adds a non\-personnel cost with an? '(.*)' category type to the first Budget period$/ do |type|
  @budget_version.period(1).assign_non_personnel_cost category_type: type
end

And /adds a non\-personnel cost to the first Budget period with these settings:$/ do |table|
  opts = {}
  table.raw.each{ |item| opts.store(damballa(item[0]), item[1]) }
  @budget_version.period(1).assign_non_personnel_cost opts
end