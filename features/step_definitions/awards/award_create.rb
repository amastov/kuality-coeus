#----------------------#
#Create and Save
#Note: Units are specified to match the initiator's unit.
#----------------------#
When /^the (.*) creates an Award$/ do |role_name|
  steps %{ * I log in with the #{role_name} user }
  # Implicit in this step is that the Award creator
  # is creating the Award in the unit they have
  # rights to. This is why this step specifies what the
  # Award's unit should be...
  lead_unit = $current_user.roles.name($current_user.role).qualifiers[0][:unit]
  raise 'Unable to determine a lead unit for the selected user. Please debug your scenario.' if lead_unit.nil?
  @award = create AwardObject, lead_unit_id: lead_unit
end

Given /^the Award Modifier creates? an Award with (.*) as the Lead Unit$/ do |lead_unit|
  steps '* I log in with the Award Modifier user'
  @award = create AwardObject, lead_unit_id: lead_unit
end

#----------------------#
#Award Validations Based on Errors During Creation
#----------------------#
When /^I ? ?creates? an Award with a missing required field$/ do
  required_field = ['Transaction Type', 'Award Status', 'Award Title',
                    'Activity Type', 'Award Type', 'Project End Date',
                    'Lead Unit ID'
  ].sample
  required_field=~/(Type|Status)/ ? value='select' : value=' '
  field = damballa(required_field)
  @award = create AwardObject, field=>value
  text = ' is a required field.'
  # FIXME
  @required_field_error = case(required_field)
                            when 'Lead Unit'
                              "#{required_field} ID (#{required_field} ID)#{text}"
                            when 'Award Title'
                              "#{required_field} (Title)#{text}"
                            when 'Transaction Type', 'Award Status', 'Activity Type', 'Award Type', 'Project End Date', 'Lead Unit ID'
                              "#{required_field} (#{required_field})#{text}"
                            end
end

When /^the Award Modifier creates an Award with more obligated than anticipated amounts$/ do
  steps '* I log in with the Award Modifier user'
  @award = create AwardObject, anticipated_direct: '9999.99', obligated_direct: '10000.00'
end

Given /^the Award Modifier creates an Award including an Account ID, Account Type, Prime Sponsor, and CFDA Number$/ do
  steps '* I log in with the Award Modifier user'
  @award = create AwardObject
end

Given /^the Award Modifier creates an Award with an obligated amount and blank project start date$/ do
  steps '* I log in with the Award Modifier user'
  @award = create AwardObject, project_start_date: '', obligated_direct: '1000.00', anticipated_direct: '499.00', press: 'save'
end

When /^the Award Modifier creates an Award with a project start date later than the obligation start date$/ do
  steps '* I log in with the Award Modifier user'
  @award = create AwardObject, project_start_date: next_week[:date_w_slashes], obligation_start_date: tomorrow[:date_w_slashes]
end