And /adds a Species group to the IACUC Protocol$/ do
  @iacuc_protocol.add_species_group
end

And /assigns a (second |)location to the Procedure with a type of '(.*)' on the IACUC Protocol$/ do |count, type|
  @iacuc_protocol.procedures.view
  on(IACUCProcedures).select_procedure_tab 'location'
  unused_location_names = []
  on IACUCProceduresLocation do |page|
    page.type.select type
    unused_location_names = page.name_array - @iacuc_protocol.procedures.locations.names
  end
  @iacuc_protocol.procedures.add_location type: type, name: unused_location_names.sample
end

When /edits the location type, name, room, description on the IACUC Protocol$/ do
  @iacuc_protocol.procedures.locations[0].edit name: '::random::', room: rand(100..999).to_s, description: random_alphanums_plus
end

And /adds a Procedure to the IACUC Protocol$/ do
  @iacuc_protocol.add_procedure
end

And /deletes the (first |second )location from the Procedure$/ do |count|
  location = {'first ' => 0, 'second ' => 1}
  @iacuc_protocol.procedures.locations[location[count]].delete
end

When /deactivates the IACUC Protocol$/ do
   @iacuc_protocol.request_to_deactivate
end

And /places the IACUC Protocol on hold$/ do
  @iacuc_protocol.place_hold
end

When /lifts the hold placed on the IACUC Protocol$/ do
  @iacuc_protocol.lift_hold
end

When /^(the (.*) |)withdraws the IACUC Protocol$/ do |text, role_name|
    steps %{ * I log in with the #{role_name} user } unless text == ''
  @iacuc_protocol.withdraw
end

When /adds? an organization to the IACUC Protocol$/ do
  @iacuc_protocol.add_organization
end

When /^(the (.*) |)adds? an organization to the IACUC Protocol without the required fields$/ do |text, role_name|
  steps %{ * I log in with the #{role_name} user } unless text == ''
  @iacuc_protocol.add_organization organization_id: nil, organization_type: nil, press: nil
end

And /changes the contact information on the added Organization$/ do
  #clear contact based off of the org id
  @iacuc_protocol.organizations[0].clear_contact
  #select a new address from the search
  @iacuc_protocol.organizations[0].add_contact_info
end

When /reopens the IACUC Protocol without saving the changes$/ do
  on(IACUCProtocolOverview).close
  confirmation('No')
  visit(SystemAdmin).person
  @iacuc_protocol.view 'Protocol'
end

When /^(the (.*) |)adds? a Species with non\-integers for the species count$/ do |text, role_name|
  steps %{ * I log in with the #{role_name} user } unless text == ''
  #count error message only displays a max of 8 characters so we will use that as our max characters for the count
  @iacuc_protocol.add_species_groups count: random_alphanums(8)
  @errors = [ "#{@iacuc_protocol.species_groups[0].count} is not a valid integer."]
end

When /saves the IACUC Protocol after modifying the required fields for the Species$/ do
  @iacuc_protocol.species_groups[0].edit group: random_alphanums_plus(10, 'Species '),
                species:           '::random::',
                pain_category:     '::random::',
                count_type:        '::random::',
                count:             rand(1..21),
                strain:            random_alphanums_plus,
                usda_covered:      :set,
                procedure_summary: random_alphanums_plus(20)
end

When /^the IACUC Protocol Creator deletes the (.*) Species$/ do |line_item|
  index = {'first' => 0, 'second' => 1}
  @iacuc_protocol.species_groups.delete(index[line_item])
end

When /adds? (\d+|a) personnel members? to the IACUC Protocol$/ do |num|
  count = {'a'=> 1, '1' =>1, '2' => 2}
  count[num].times { @iacuc_protocol.add_personnel }
end

When /edits the three principles of the IACUC Protocol/ do
  @iacuc_protocol.update_the_three_rs reduction: random_alphanums_plus, refinement: random_alphanums_plus, replacement: random_alphanums_plus
end

When /adding a Special Review with incorrect data$/ do
  @iacuc_protocol.add_special_review type:             nil,
                            approval_status:  nil,
                            application_date: rand(130000..999999),
                            approval_date:    rand(130000..999999),
                            expiration_date:  rand(130000..999999),
                            press:            nil
end

When /adding a Special Review for human subjects, status approved, and an exemption$/ do
  @iacuc_protocol.add_special_review type: 'Human Subjects',
                            approval_status:  'Approved',
                            exemption_number: '::random::',
                            protocol_number:  nil,
                            press:            nil
end

When /adding a Special Review to generate error messages for incorrect date structures$/ do
  @iacuc_protocol.add_special_review application_date: tomorrow[:date_w_slashes],
                            approval_date:    right_now[:date_w_slashes],
                            expiration_date:  yesterday[:date_w_slashes],
                            exemption_number: '::random::',
                            press:            nil
end

When /^(the (.*) |)adds a Special Review to the IACUC Protocol$/ do |text, role_name|
  steps %{* I log in with the #{role_name} user } unless text ==''
  @iacuc_protocol.add_special_review
end

When /^(the (.*) |)edits the (first |second | )Special Review on the IACUC Protocol$/ do |text, role_name, line_item|
  steps %{* I log in with the #{role_name} user } unless text ==''
  index = {'first ' => 0, 'second ' => 1}
  @iacuc_protocol.special_review[index[line_item]].edit type: '::random::', approval_status: '::random::'
end

And /edits the location name on the maintenance document$/ do
  @location_name.edit location_name: random_alphanums
end

When /(the (.*) |)approves the amendment for the IACUC Protocol$/ do |text, role_name|
  steps %{ * log in with the #{role_name} user } unless text == ''
  # amendment needed a special approve method because document id changes without proper navigation
  @iacuc_protocol.admin_approve_amendment
end

When /(the (.*) |)suspends the amendment for the IACUC Protocol$/ do |text, role_name|
  steps %{ * log in with the #{role_name} user } unless text == ''
  @iacuc_protocol.suspend
end

When /(the (.*) |)(suspends?|terminates?|expires?) the IACUC Protocol$/ do |text, role_name, action|
  steps %{ * log in with the #{role_name} user } unless text == ''
  @iacuc_protocol.action(action.chomp('s'))
end

And /^a qualification and procedure are added to the procedure person$/ do
  @iacuc_protocol.procedures.personnel[0].add_procedure @iacuc_protocol.procedures.categories[0].name
  @iacuc_protocol.procedures.personnel[0].update_qualifications random_alphanums
end

Given /^(the (.*) |)assigns committee members to review the submission$/ do |text, role_name|
  steps %{* I log in with the #{role_name} user } unless text ==''
                                            #DEBUG:
  @iacuc_protocol.modify_submission_request schedule_date: nil # We have this in here because of a bug about selecting schedule items
end

And /^the (.*) modifies the IACUC Protocol's submission request so the non-employee is a reviewer$/ do |role_name|
  steps %{ * log in with the #{role_name} user }
  @iacuc_protocol.modify_submission_request primary_reviewers: ['Guest, David'], schedule_date: nil
end

Then /^(the (.*) |)approves the Protocol$/ do |text, role_name|
  steps %{* I log in with the #{role_name} user } unless text ==''
  @iacuc_protocol.approve
end