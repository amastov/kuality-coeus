When /^the Award Modifier submits the Award$/ do
  steps %q{ * I log in with the Award Modifier user }
  @award.submit
end