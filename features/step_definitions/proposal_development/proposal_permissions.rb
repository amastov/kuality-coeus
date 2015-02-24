When /^the (.*) visits the Proposal's (.*) page$/ do |user, page|
  get(user).sign_in
  @proposal.view page
end

Then /^the (.*) user is listed as an? (.*) in the proposal permissions$/ do |user, role|
  on(Permissions).role_of(get(user).user_name).should==role
end

When /^I? ?assign the (.*) user as an? (.*) in the proposal permissions$/ do |system_role, role|
  make_user role: system_role
  @proposal.permissions.send(damballa(role+'s')) << get(system_role).user_name
  @proposal.permissions.assign
end

Then /^the (.*) user can access the Proposal$/ do |role|
  get(role).sign_in
  @proposal.view
  #TODO: Add a validation here
end

Then /^their proposal permissions do not allow them to edit budget details$/ do
  raise 'This ain\'t done!'
end

And /^their proposal permissions allow them to edit all parts of the Proposal$/ do
  raise 'This ain\'t done!'
end

And /^their proposal permissions allow them to update the Budget, not the narrative$/ do
  raise 'This ain\'t done!'

end

And /^their proposal permissions allow them to only read the Proposal$/ do
  raise 'This ain\'t done!'
end

And /^their proposal permissions allow them to delete the Proposal$/ do
  raise 'This ain\'t done!'
end

When /^I? ?add an additional proposal role to the (.*) user$/ do |system_role|
  if system_role=='Proposal Creator'
    role='aggregator'
  else
    role=system_role
  end
  role_to_add = ([:viewer, :budget_creator, :narrative_writer, :aggregator]-[StringFactory.damballa(role)]).sample
  on(Permissions).edit_role(get(system_role).user_name)
  on Roles do |page|
    page.use_new_tab
    page.send(role_to_add).set
    page.save
    # Note: This step def does not go beyond clicking the Save button here
    # because the expectation is that the Roles window will not close,
    # but will instead display an error message.
  end
end

Then /^the (.*) user should not be listed as an? (.*) in the second Proposal$/ do |system_role, role|
  user = get(system_role)
  @proposal2.view :permissions
  on Permissions do |page|
    page.assigned_to_role(role).should_not include "#{user.first_name} #{user.last_name}"
  end
end

Then /^the User should be able to create a proposal$/ do
  # Note that since this stepdef doesn't specify WHICH user, it's
  # assuming that the one to use is the last one that was
  # created/defined.
  $users[-1].sign_in
  expect{create ProposalDevelopmentObject}.not_to raise_error
end

Then /^the OSP Administrator can override the cost sharing amount$/ do
  steps '* I log in with the OSP Administrator user'
  @proposal.view
  # TODO
end