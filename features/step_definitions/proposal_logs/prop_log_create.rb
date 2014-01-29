When /^I? ?creates? a Proposal Log but I miss a required field$/ do
  # Pick a field at random for the test...
  @required_field = ['Title', 'Proposal Type', 'Lead Unit'
          ].sample
  # Properly set the nil value depending on the field type...
  @required_field=~/Type/ ? value='select' : value=''
  # Transform the field name to the appropriate symbol...
  field =snake_case(@required_field)
  @proposal_log = create ProposalLogObject, field=>value
end

When /^I? ?creates? a Proposal Log$/ do
  @proposal_log = create ProposalLogObject
end

Then(/^the Proposal Log type should be (.*)$/) do |status|
  # TODO: Ensure this step and the previous one in the scenario are written properly
  # Note: This step def will not work if the previous step
  # def is not written to ensure the data object's @proposal_log_type
  # value gets updated properly.
  @proposal_log.proposal_log_type.should == status
end

Then /^the status of the Proposal Log should be (.*)$/ do |status|
  @proposal_log.status.should == status
end

When /^the Proposal Log status should be (.*)$/ do |prop_log_status|
  @proposal_log.log_status.should == prop_log_status
end

When /^I submit a new permanent Proposal Log with the same PI into routing$/ do
  @proposal_log = create ProposalLogObject,
                          principal_investigator: @temp_proposal_log.principal_investigator
  @proposal_log.submit
end

When /^I? ?creates? a permanent Proposal Log$/ do
  @proposal_log = create ProposalLogObject
end

When /^I? ?submit a new temporary Proposal Log with a particular PI$/ do
  visit PersonLookup do |page|
    page.search
    @pi = page.returned_principal_names[rand(page.returned_principal_names.size)]
  end
  @temp_proposal_log = create ProposalLogObject,
                         log_type: 'Temporary',
                         principal_investigator: @pi
  @temp_proposal_log.submit
end

Then /^I merge my new proposal log with my previous temporary proposal log$/ do
  raise "This step needs to be done!!!"
end

When /^I submit a new Proposal Log$/ do
  @proposal_log = create ProposalLogObject
  @proposal_log.submit
end

When /^I submit a new Temporary Proposal Log$/ do
  @temp_proposal_log = create ProposalLogObject,
                              log_type: 'Temporary'
  @temp_proposal_log.submit
end

Then /^the Proposal Log's status should reflect it has been merged$/ do
  on(Researcher).search_proposal_log
  raise "This step ain't done!!!"
end

Then /^upon submission of the Proposal Log, an error should appear saying the field is required$/ do
  on(ProposalLog).submit
  text="#{@required_field} (#{@required_field}) is a required field."
  @required_field=='Description' ? error='Document '+text : error=text
  on(ProposalLog).errors.should include error
end