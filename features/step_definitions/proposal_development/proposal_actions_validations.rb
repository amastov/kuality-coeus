And /(activates? data validation|data validation is activated)$/ do |x|
  on(NewDocumentHeader).data_validation
  on(DataValidation).turn_on
end

When /^the Proposal has no principal investigator$/ do
  #nothing needed for this step
end

When /^I? ?do not answer my proposal questions$/ do
  #nothing necessary for this step
end

When /^(the (.*) |)creates a Proposal with an un-certified (.*)$/ do |text, role_name, role|
  steps %{ * I log in with the #{role_name} user } unless text == ''
  @role = role
  @proposal = create ProposalDevelopmentObject
  @proposal.add_key_person role: @role
end