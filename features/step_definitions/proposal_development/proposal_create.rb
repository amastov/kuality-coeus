Given /^(the (.*) |)creates a Proposal$/ do |text, role_name|
  steps %{ * I log in with the #{role_name} user } unless text == ''
  @proposal = create ProposalDevelopmentObject
end

Given /^(the (.*) |)creates a second Proposal$/ do |text, role_name|
  steps %{ * I log in with the #{role_name} user } unless text == ''
  @proposal2 = create ProposalDevelopmentObject
end

Given /^(the (.*) |)creates a (\d+)-year project Proposal$/ do |text, role_name, year_count|
  steps %{ * I log in with the #{role_name} user } unless text == ''
  @years=year_count.to_i
  @proposal =create ProposalDevelopmentObject,
                    project_start_date: "01/01/#{next_year[:year]}",
                    project_end_date: "12/31/#{next_year[:year].to_i+(@years-1)}"
end

And /creates a Proposal that doesn't span the fiscal year cutoff$/ do
  @proposal =create ProposalDevelopmentObject,
                    project_start_date: "01/01/#{next_year[:year]}",
                    project_end_date: "0#{rand(6)+1}/#{rand(15)+10}/#{next_year[:year]}"
end

Given /^(the (.*) |)creates a (\d+)-year, '(.*)' Proposal$/ do |text, role_name, year_count, activity_type|
  steps %{ * I log in with the #{role_name} user } unless text == ''
  @years=year_count.to_i
  @proposal =create ProposalDevelopmentObject,
                    project_start_date: "01/01/#{next_year[:year]}",
                    project_end_date: "12/31/#{next_year[:year].to_i+(@years-1)}",
                    activity_type: activity_type
end

Given /^(the (.*) |)creates a Proposal with a '(.*)' activity type$/ do |text, role_name, activity_type|
  steps %{ * I log in with the #{role_name} user } unless text == ''
  @proposal = create ProposalDevelopmentObject, activity_type: activity_type
end

When /^(the (.*) |)creates a Proposal while missing a required field$/ do |text, role_name|
  steps %{ * I log in with the #{role_name} user } unless text==''
  # Pick a field at random for the test...
  required_field = [ 'Proposal Type', 'Activity Type',
           'Project Title', 'Project Start Date', 'Project End Date'
          ].sample
  # Properly set the nil value depending on the field type...
  required_field=~/Type/ ? value='select' : value=''
  # Transform the field name to the appropriate symbol...
  field = damballa(required_field.gsub('Code','id'))
  @proposal = create ProposalDevelopmentObject, field=>value
  @required_field_error = "#{required_field}: Required"
end

When /^(the (.*) |)creates a Proposal with an? '(.*)' sponsor type$/ do |text, role_name, type|
  steps %{ * I log in with the #{role_name} user } unless text == ''
  @proposal = create ProposalDevelopmentObject, sponsor_type_code: type
end

Given /^(the (.*) |)creates a Proposal with (.*) as the sponsor$/ do |text, role_name, sponsor_code|
  steps %{ * I log in with the #{role_name} user } unless text == ''
  @proposal = create ProposalDevelopmentObject, sponsor_id: sponsor_code
end

Given /^(the (.*) |)creates a '(.*)' Proposal with (.*) as the sponsor$/ do |text, role_name, type, sponsor_code|
  steps %{ * I log in with the #{role_name} user } unless text == ''
  @proposal = create ProposalDevelopmentObject, sponsor_id: sponsor_code, proposal_type: type
end

Given /^(the (.*) |)creates a 9.5-month '(.*)' activity type Proposal$/ do |text, role_name, type|
  steps %{ * I log in with the #{role_name} user } unless text == ''
  x = rand(3)+1
  @proposal = create ProposalDevelopmentObject, activity_type: type,
                     project_start_date: "0#{x}/05/#{next_year[:year]}",
                     project_end_date: "#{x+9}/20/#{next_year[:year]}"
end

Given /^(the (.*) |)creates a Proposal with a type of '(.*)'$/ do |text, role_name, type|
  steps %{ * I log in with the #{role_name} user } unless text == ''
  @proposal = create ProposalDevelopmentObject, proposal_type: type
end

When /^(the (.*) |)creates a Proposal with an invalid sponsor code$/ do |text, role_name|
  steps %{ * I log in with the #{role_name} user } unless text == ''
  @proposal = create ProposalDevelopmentObject, :sponsor_id=>'000000'
end

Given /^(the (.*) |)creates a Proposal without a sponsor deadline date$/ do |text, role_name|
  steps %{ * I log in with the #{role_name} user } unless text == ''
  @proposal = create ProposalDevelopmentObject, sponsor_deadline_date: ''
end

Given /(the (.*) |)creates a Proposal with a sponsor deadline in the past$/ do |text, role_name|
  steps %{ * I log in with the #{role_name} user } unless text == ''
  @proposal = create ProposalDevelopmentObject, sponsor_deadline_date: last_year[:date_w_slashes]
end

Given /(the (.*) |)creates a Proposal with an invalid sponsor deadline time/ do  |text, role_name|
  steps %{ * I log in with the #{role_name} user } unless text == ''
  @proposal = create ProposalDevelopmentObject, sponsor_deadline_time: '99:99'
end

Given /(the (.*) |)creates a Proposal with an invalid project date$/ do |text, role_name|
  steps %{ * I log in with the #{role_name} user } unless text == ''
  date = ['Start', 'End'].sample
  @date_error = "Project #{date} Date: Must be a date in the following format(s): MM/dd/yy, MM/dd/yyyy, MM-dd-yy, MM-dd-yyyy, yyyy-MM-dd"
  @proposal = create ProposalDevelopmentObject, damballa("Project #{date} Date") => in_a_year[:short_date]
end

Given /(the (.*) |)creates a Proposal with an end date prior to the start date$/ do |text, role_name|
  steps %{ * I log in with the #{role_name} user } unless text == ''
  @proposal = create ProposalDevelopmentObject, project_start_date: right_now[:date_w_slashes], project_end_date: a_year_ago[:date_w_slashes]
end

Given /(the (.*) |)creates a Proposal with a project title containing extended characters$/ do |text, role_name|
  steps %{ * I log in with the #{role_name} user } unless text == ''
  @proposal = create ProposalDevelopmentObject, project_title: random_high_ascii(200)
end

Given /(the (.*) |)creates a non-'New' Proposal with a non-alphanumeric IP ID/ do |text, role_name|
  steps %{ * I log in with the #{role_name} user } unless text == ''
  type = %w{Renewal Continuation Resubmission Revision}.sample
  @proposal = create ProposalDevelopmentObject, proposal_type: type, original_ip_id: '!@#$%^'
end

Given /(the (.*) |)creates a non-'New' Proposal with an invalid Award ID/ do |text, role_name|
  steps %{ * I log in with the #{role_name} user } unless text == ''
  type = %w{Renewal Continuation Resubmission Revision}.sample
  @proposal = create ProposalDevelopmentObject, proposal_type: type, award_id: 'abcd1234'
end

Given /(the (.*) |)creates a non-'New' Proposal with an IP ID that doesn't exist/ do |text, role_name|
  steps %{ * I log in with the #{role_name} user } unless text == ''
  type = %w{Renewal Continuation Resubmission Revision}.sample
  @proposal = create ProposalDevelopmentObject, proposal_type: type, original_ip_id: '98765432'
end

When /^(the (.*) |)submits the Proposal into routing$/ do |text, role_name|
  steps %{ * I log in with the #{role_name} user } unless text==''
  @proposal.submit
end

When /^I? ?completes? the Proposal$/ do
  @proposal.add_principal_investigator
  @proposal.key_personnel.set_valid_credit_splits
end

When /completes? the required supplemental info on the Proposal$/ do
  @proposal.add_supplemental_info
end

When /^I? ?add (.*) as an? (.*) to the proposal permissions$/ do |username, role|
  @proposal.permissions.send("#{damballa(role)}s") << username
  @proposal.permissions.assign
end

And /answers the Proposal's questionnaire$/ do
  @proposal.fill_out_questionnaire
end

When /^I? ?save and close the Proposal document$/ do
  @proposal.close
  on(Confirmation).yes
end

And /^the (.*) submits a new Proposal into routing$/ do |role_name|
  steps %{ * the #{role_name} creates a Proposal }
  steps %q{ * adds a principal investigator to the Proposal
            * certifies the Proposal's principal investigator
            * sets valid credit splits for the Proposal }
  steps %q{ * creates a Budget Version for the Proposal
            * includes the Budget Version for submission
            * marks the Budget Version complete }
  steps %q{ * submits the Proposal into routing }
end

And /^(the (.*) |)completes the remaining required actions for an S2S submission$/ do |text, role_name|
  steps %{ * I log in with the #{role_name} user } unless text==''
  steps %q{
    * sets valid credit splits for the Proposal
    * add and mark complete all the required S2S attachments
    * creates a final and complete Budget Version for the Proposal
    * answer the S2S questions
        }
end

And /^I? ?adds? the (Grants.Gov|Research.Gov) opportunity id of (.*) to the Proposal$/ do |type, op_id|
  @proposal.edit opportunity_id: op_id
  on(Proposal).s2s
  on S2S do |page|
    page.expand_all
    page.s2s_lookup
  end
  on OpportunityLookup do |look|
    look.s2s_provider.select type
    look.search
    look.return_value op_id
  end
  on(S2S).save
end

And /^I? ?adds? and marks? complete all the required attachments for an NSF Proposal$/ do
  %w{Equipment Bibliography BudgetJustification ProjectSummary Narrative}.shuffle.each do |type|
    @proposal.add_proposal_attachment type: type, file_name: 'test.pdf', status: 'Complete'
  end
  @proposal.add_proposal_attachment type: 'Other', file_name: 'NSF_DATA_MANAGEMENT_PLAN.pdf', status: 'Complete', description: random_alphanums
  @proposal.key_personnel.each do |person|
    %w{Biosketch Currentpending}.each do |type|
      @proposal.add_personnel_attachment person: person.full_name, type: type, file_name: 'test.pdf'
    end
  end
end

Given /^(the (.*) user |)creates a Proposal with these Performance Site Locations: (.*)$/ do |text, role_name, psl|
  steps %{ * I log in with the #{role_name} user } unless text==''
  locations = psl.split(',')
  @proposal = create ProposalDevelopmentObject, performance_site_locations: locations
end

When /^mresearcher creates a non\-random Proposal$/ do
  steps %{ * I'm logged in with mresearcher }
  @proposal = create ProposalDevelopmentObject, :sponsor_id=> '000127',
                     :lead_unit=>'BIO - Dept of Biology',
                     :activity_type=>'Instruction',
                     :project_title=>'SMOKE TEST',
                     :project_start_date=>next_week[:date_w_slashes],
                     :project_end_date=>next_year[:date_w_slashes],
                     :sponsor_deadline_date=>next_year[:date_w_slashes],
                     :sponsor_deadline_time=>'23:59'
end