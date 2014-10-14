And /^I? ?add the (.*) user as an? (.*) to the key personnel proposal roles$/ do |user_role, proposal_role|
  user = get(user_role)
  @proposal.add_key_person first_name: user.first_name, last_name: user.last_name, role: proposal_role
end

And /adds? a key person to the Proposal$/ do
  @proposal.add_key_person role: 'Key Person', key_person_role: random_alphanums
end

When /^I? ?add (.*) as a key person with a role of (.*)$/ do |user_name, kp_role|
  user = get(user_name)
  @proposal.add_key_person first_name: user.first_name,
                           last_name: user.last_name,
                           role: 'Key Person',
                           key_person_role: kp_role
end

And /^I? ?add a (.*) with a (.*) credit split of (.*)$/ do |role, cs_type, amount|
  @proposal.add_key_person cs_type.downcase.to_sym=>amount, role: role
end

When /^I? ?try to add two principal investigators$/ do
  2.times { @proposal.add_principal_investigator }
end

When /^I? ?adds? a key person without a key person role$/ do
  @proposal.add_key_person role: 'Key Person', key_person_role:''
end

And /adds? a co-investigator to the Proposal$/ do
  @proposal.add_key_person role: 'Co-Investigator'
end

When /^I? ?adds? a principal investigator to the Proposal$/ do
  @proposal.add_principal_investigator
end

Given /^I? ?adds? the Grants.Gov user as the Proposal's PI$/ do
  @proposal.add_principal_investigator last_name: $users.grants_gov_pi.last_name, first_name: $users.grants_gov_pi.first_name
end

When /^I? ?sets? valid credit splits for the Proposal$/ do
  @proposal.set_valid_credit_splits
end

And /^the approval buttons appear on the Proposal Summary and Proposal Action pages$/ do
  [:approve_button, :disapprove_button, :reject_button].each do |button|
    @proposal.view :proposal_summary
    on(ProposalSummary).send(button).should exist
    @proposal.view :proposal_actions
    on(ProposalActions).send(button).should exist
  end
end

When /^the (.*) user approves the Proposal$/ do |role|
  get(role).sign_in
  @proposal.view :proposal_summary
  on(ProposalSummary).approve
  on(Confirmation).yes
end

When /add the (.*) user as a (.*) to the key personnel Proposal roles$/ do |user_role, proposal_role|
  user = get(user_role)
  @proposal.add_key_person first_name: user.first_name, last_name: user.last_name, role: proposal_role
end

Then /^the same person cannot be added to the Proposal personnel again$/ do
  @last_name = @proposal.principal_investigator.last_name
  @first_name = @proposal.principal_investigator.first_name
  expect{@proposal.add_key_person role: 'Co-Investigator', last_name: @last_name, first_name: @first_name}.to raise_error
end