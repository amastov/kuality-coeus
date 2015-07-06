When /^the Create Proposal Log user creates a Proposal Log but misses a required field$/ do
  steps %{ * I log in with the Create Proposal Log user }
  # Pick a field at random for the test...
  required_field = ['Title', 'Proposal Type', 'Lead Unit'
          ].sample
  # Properly set the nil value depending on the field type...
  required_field=~/Type/ ? value='select' : value=''
  # Transform the field name to the appropriate symbol...
  field = damballa(required_field)
  @proposal_log = create ProposalLogObject, field=>value, save_type: :save,
                         # Note: These are included simply to make the test
                         # run a bit faster. They are unimportant...
                         principal_investigator: 'lvbarger', sponsor_id: '000126'
  @required_field_error = "#{required_field} (#{required_field}) is a required field."
end

When /^the Create Proposal Log user creates a Proposal Log$/ do
  steps %{ * I log in with the Create Proposal Log user }
  @proposal_log = create ProposalLogObject, save_type: :save
end

When /^the Create Proposal Log user has submitted a new Proposal Log$/ do
  steps %{ * I log in with the Create Proposal Log user }
  @proposal_log = create ProposalLogObject
end

Then(/^the Proposal Log type should be (.*)$/) do |status|
  # TODO: Ensure this step and the previous one in the scenario are written properly
  # Note: This step def will not work if the previous step
  # def is not written to ensure the data object's @proposal_log_type
  # value gets updated properly.
  expect(@proposal_log.proposal_log_type).to eq status
end

Then /^the status of the Proposal Log should be (.*)$/ do |status|
  expect(@proposal_log.status).to eq status
end

When /^the Proposal Log status should be (.*)$/ do |prop_log_status|
  expect(@proposal_log.log_status).to eq prop_log_status
end

When /^the Create Proposal Log user submits a new permanent Proposal Log with the same PI into routing$/ do
  steps %{ * I log in with the Create Proposal Log user }
  @proposal_log = create ProposalLogObject,
                          principal_investigator: @temp_proposal_log.principal_investigator
end

When /^the Create Proposal Log creates a permanent Proposal Log$/ do
  steps %{ * I log in with the Create Proposal Log user }
  @proposal_log = create ProposalLogObject, save_type: :save
end

When /^the Create Proposal Log user submits a new temporary Proposal Log with a particular PI$/ do
  steps %{ * I log in with the Create Proposal Log user }
  visit PersonLookup do |page|
    page.search

    # TODO: This is really really slow. The HTML on the page needs improving. There is currently
    # no reliable way to improve how we parse the HTML.
    @pi = page.returned_principal_names.sample

  end
  @temp_proposal_log = create ProposalLogObject,
                         log_type: 'Temporary',
                         principal_investigator: @pi
end

Then /^merges the new proposal log with the previous temporary proposal log$/ do
  on(ProposalLog).merge_proposal_log @temp_proposal_log.number
end

When /^the Create Proposal Log user submits a new Temporary Proposal Log$/ do
  steps %{ * I log in with the Create Proposal Log user }
  @temp_proposal_log = create ProposalLogObject,
                              log_type: 'Temporary'
end

Then /^the Proposal Log's status should reflect it has been (.*)$/ do |status|
  on(Header).researcher
  on(ResearcherMenu).search_proposal_log
  on ProposalLogLookup do |page|
    page.proposal_number.set @temp_proposal_log.number
    page.search
    expect(page.prop_log_status(@temp_proposal_log.number)).to eq status
  end
end

Then /^the Create Proposal Log user submits the Proposal Log$/ do
  on ProposalLog do |page|
    if page.merge_list.present?
      page.cancel_merge
    end
  end
  steps %{ * I log in with the Create Proposal Log user }
  @proposal_log.submit
end

Then /^the permanent Proposal Log should show it has merged with the temporary one$/ do
  expect(on(ProposalLog).proposal_merged_with).to eq @temp_proposal_log.number
end