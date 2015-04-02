Then /^the Proposal status should be (.*)$/ do |status|
  # FIXME!
  # There's a problem in the system, where the status of the document
  # is not getting updated immediately, so the next line will not work.
  #
  #@proposal.status.should == status
  #
  # We need to use the following code until the system no longer
  # uses KRAD as the back-end framework...
  on(Header).researcher
  on(ResearcherMenu).search_proposals
  @proposal.view 'Proposal Details'
  on(NewDocumentHeader).document_status.should==status
end

When /^I? ?submit the Proposal to its sponsor$/ do
  @proposal.submit :to_sponsor
  @institutional_proposal = @proposal.make_institutional_proposal
end

And /^the (.*) submits the Proposal to its sponsor$/ do |role_name|
  steps %{ * I log in with the #{role_name} user }
  @proposal.submit :to_sponsor
  @institutional_proposal = @proposal.make_institutional_proposal


  DEBUG.inspects @proposal, @institutional_proposal


end

When /^I? ?submit the Proposal to S2S$/ do
  @proposal.submit :to_s2s
end

When /^(I? ?submits? the Proposal|the Proposal is submitted)$/ do |x|
  @proposal.submit
end

When /^I? ?blanket approve the Proposal$/ do
  @proposal.blanket_approve
end

And /^the principal investigator approves the Proposal$/ do
  @proposal.principal_investigator.log_in
  @proposal.approve_from_action_list(nil)
end

And /^the (.*) approves the Proposal (with|without) future approval requests$/ do |role_name, future_requests|
  if role_name=='principal investigator'
    @proposal.principal_investigator.log_in
  else
    steps %{* I log in with the #{role_name} user }
  end

  # Move to Transforms???
  conf = {'with' => :yes, 'without' => :no}
  #@proposal.approve(conf[future_requests])

  # Need this debug code because of the problem of the OSP Approver not being able
  # to find the proposal via search...
  DEBUG.do {
    @proposal.approve_from_action_list(conf[future_requests])
  }
end

Then /^I should only have the option to submit the proposal to its sponsor$/ do
  @proposal.view 'Summary/Submit'
  on ProposalSummary do |page|
    page.approve_element.should_not be_present
    page.submit_to_sponsor_element.should be_present
  end
end

Then /^I should see the option to approve the Proposal$/ do
  @proposal.view 'Summary/Submit'
  on ProposalSummary do |page|
    page.approve_element.should be_present
  end
end

Then /^I should not see the option to approve the Proposal$/ do
  @proposal.view 'Summary/Submit'
  on ProposalSummary do |page|
    page.approve_element.should_not be_present
  end
end

And(/^the (.*) approves the Proposal again$/) do |role_name|
  steps %{ * I log in with the #{role_name} user }
  @proposal.approve nil
end

When(/^the OSPApprover rejects the Proposal$/) do
  steps '* I log in with the OSPApprover user'
  @proposal.reject
end