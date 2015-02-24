When /^the Proposal is recalled$/ do
  @proposal.recall
end

When /^I? ?reject the Proposal$/ do
  @proposal.reject
end

When /^I? ?complete a valid simple Proposal for a '(.*)' organization$/ do |org|
  @proposal = create ProposalDevelopmentObject, sponsor_type_code: org
  @proposal.add_principal_investigator
  @proposal.set_valid_credit_splits
  @proposal.add_custom_data
end

Then /^The Proposal should immediately have a status of '(.*)'$/ do |status|
  @proposal.status.should==status
end

Then /^The proposal route log's 'Actions Taken' should include '(.*)'$/ do |value|
  @proposal.view :proposal_actions
  on ProposalActions do |page|
    page.expand_all
    page.actions_taken.should include value
  end
end

Then /^The proposal route log's 'Pending Action Requests' should include '(.*)'$/ do |action|
  @proposal.view :proposal_actions
  on ProposalActions do |page|
    page.expand_all
    page.action_requests.should include action
  end
end

Then /^The S2S opportunity search should become available$/ do
  @proposal.view 'S2S Opportunity Search'
  expect{on(S2S).find_opportunity_button}.to be_present
end

When /^The Proposal's 'Future Action Requests' should include 'PENDING APPROVE' for the principal investigator$/ do
  pi = @proposal.key_personnel.principal_investigator
  name = "#{pi.last_name}, #{pi.first_name}"
  @proposal.view :proposal_actions
  on ProposalActions do |page|
    page.expand_all
    page.show_future_action_requests
    page.requested_action_for(name).should=="PENDING\nAPPROVE"
  end
end

When /^I? ?push the Proposal's project start date ahead (\d+) years?$/ do |year|
  new_year=@proposal.project_start_date[/\d+$/].to_i+year.to_i
  new_date="#{@proposal.project_start_date[/^\d+\/\d+/]}/#{new_year}"
  @proposal.edit project_start_date: new_date
end

When /(the Proposal Creator |)pushes the Proposal end date (\d+) more years?$/ do |usr, year|
  steps %|* I log in with the Proposal Creator user| if usr=='the Proposal Creator '
  new_year=@proposal.project_end_date[/\d+$/].to_i+year.to_i
  new_date="#{@proposal.project_end_date[/^\d+\/\d+/]}/#{new_year}"
  @proposal.edit project_end_date: new_date
end

Then /^I can recall the Proposal$/ do
  @proposal.view 'Proposal'
  on(Proposal).recall_button.should exist
end

And /answers? the S2S questions$/ do
  @proposal.complete_s2s_questionnaire
end

Given /^I? ?set the proposal type to '(\w+)'$/ do |type|
  @proposal.edit proposal_type: type
end

When /^I go to the Proposal's (.*) page$/ do |page|
  @proposal.view page
end

When /^I? ?save the Proposal$/ do
  @proposal.save
end

Given /^I? ?set the proposal type to either 'Resubmission', 'Renewal', or 'Continuation'$/ do
  type = %w{Resubmission Renewal Continuation}.sample
  @proposal.edit proposal_type: type
end

When /^the AOR user submits the Proposal to S2S$/ do
  @aor.sign_in
  @proposal.submit :to_s2s
end

And /^the Proposal Creator copies the Proposal to a new one, as a continuation$/ do
  steps '* I log in with the Proposal Creator user'
  @new_proposal_version = @proposal.copy
  @new_proposal_version.edit proposal_type: 'Continuation', original_ip_id: @institutional_proposal.proposal_number

end

And /^certifies the PI and submits the copied Proposal$/ do
  @new_proposal_version.principal_investigator.certification
  @new_proposal_version.submit
end

And /^the OSPApprover and principal investigator approve the New Proposal$/ do
  steps '* I log in with the OSPApprover user'
  @new_proposal_version.approve_from_action_list
  @new_proposal_version.key_personnel.principal_investigator.log_in
  @new_proposal_version.approve_from_action_list nil
end

And /^the OSP Administrator resubmits the New Proposal$/ do
  steps '* I log in with the OSP Administrator user'
  @new_proposal_version.view :proposal_actions
  @new_proposal_version.resubmit
end

Then /^it is still possible to copy the Proposal$/ do
  expect{@proposal.copy_to_new_document '000001 - University'}.not_to raise_error
end

And /^the Proposal is copied to a different lead unit$/ do
  @copied_proposal = @proposal.copy 'BL-BL'
end

And /changes the Proposal's activity type$/ do
  current_activity = @proposal.activity_type
  @proposal.view 'Proposal Details'
  activities = on(ProposalDetails).activity_type.options.map{ |opt| opt.text }[1..-1]-[current_activity]
  @proposal.edit activity_type: activities.sample
end