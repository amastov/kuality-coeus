And /adds a Species group to the IACUC Protocol$/ do
  @species = create SpeciesObject
end

And /assigns a (second |)location to the Procedure with a type of '(.*)' on the IACUC Protocol$/ do |count, type|
  proced = { '' => '', 'second ' => 2 }
  # if the procedure object has not been created we will make it here.
  set("@procedures#{proced[count]}", (make IACUCProceduresObject)) if get("@procedures#{proced[count]}").nil?
  get("@procedures#{proced[count]}").set_location(type: type, room: rand(100..999), description: random_alphanums_plus, species: @species.species)
end

When /edits the location type, name, room, description on the IACUC Protocol$/ do
  @procedures_edit = make IACUCProceduresObject
  @procedures_edit.edit_location(index: '0', name: '::random::', room: rand(100..999), description: random_alphanums_plus)
end

And /adds a Procedure to the IACUC Protocol$/ do
  @procedures = create IACUCProceduresObject
end

And /deletes the (first |second )location from the Procedure$/ do |count|
  procedure = {'first ' => ['', 0], 'second ' => ['2', 1]}
  item = procedure[count]
  get("@procedures#{item[0]}").delete_location(item[1])
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

When /withdrawals the IACUC Protocol$/ do
  @iacuc_protocol.withdraw
end

When /^the IACUC Administrator approves the IACUC Protocol$/ do
  steps '* log in with the IACUC Administrator user'
  @iacuc_protocol.admin_approve
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
  @iacuc_protocol.organization.clear_contact(@iacuc_protocol.organization.organization_id)
  #select a new address from the search
  @iacuc_protocol.organization.add_contact_info(@iacuc_protocol.organization.organization_id)
end

When /reopens the IACUC Protocol without saving the changes$/ do
  on(IACUCProtocolOverview).close
  on(Confirmation).no if on(Confirmation).no_button.exists?
  @iacuc_protocol.view_document
end

When /^(the (.*) |)adds? a Species with non\-integers for the species count$/ do |text, role_name|
  steps %{ * I log in with the #{role_name} user } unless text == ''
  #count error message only displays a max of 8 characters so we will use that as our max characters for the count
  @species = create SpeciesObject, count: random_alphanums(8)
  @errors = [ "#{@species.count} is not a valid integer."]
end

When /saves the IACUC Protocol after modifying the required fields for the Species$/ do
  @species.edit press:             'save',
                index:             0,
                group:             random_alphanums_plus(10, 'Species '),
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
  on SpeciesGroups do |page|
    page.delete(index[line_item])
  end
  on(Confirmation).yes
end

When /adds? (\d+|a) personnel members? to the IACUC Protocol$/ do |num|
  count = {1 => '', 2 => '2'}
  num =='a' ? members = 1 : members = num.to_i
  while members > 0
    set("@personnel#{count[members]}", (create IACUCPersonnel))
    members -= 1
  end
end

When /edits the Principles of (.*)/ do |principle|
  on TheThreeRs do |page|
    page.send(principle.downcase).set @iacuc_protocol.principles[principle.downcase.to_sym]
    page.save
  end
end

When /adds a Special Review with incorrect data$/ do
  @special_review = create  SpecialReviewObject,
                            type:             nil,
                            approval_status:  nil,
                            application_date: rand(130000..999999),
                            approval_date:    rand(130000..999999),
                            expiration_date:  rand(130000..999999),
                            press:            nil
end

When /adds a Special Review for human subjects, status approved, and an exemption$/ do
  @special_review = create  SpecialReviewObject,
                            type:             'Human Subjects',
                            approval_status:  'Approved',
                            exemption_number: '::random::',
                            protocol_number:  nil,
                            press:            nil
end

When /adds a Special Review to generate error messages for incorrect date structures$/ do
  @special_review = create  SpecialReviewObject,
                            application_date: tomorrow[:date_w_slashes],
                            approval_date:    right_now[:date_w_slashes],
                            expiration_date:  yesterday[:date_w_slashes],
                            exemption_number: '::random::',
                            press:            nil
end

When /^(the (.*) |)adds a Special Review to the IACUC Protocol$/ do |text, role_name|
  steps %{* I log in with the #{role_name} user } unless text ==''
  @special_review = create SpecialReviewObject
end

When /^(the (.*) |)edits the (first |second | )Special Review on the IACUC Protocol$/ do |text, role_name, line_item|
  steps %{* I log in with the #{role_name} user } unless text ==''
  index = {'first ' => 0, 'second ' => 1}
  @special_review_edit = make SpecialReviewObject

  @special_review_edit.edit index:           "#{index[line_item]}",
                            edit_type: true, edit_approval_status: true,
                            press:           'save'
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

And /^adds a person to the procedure for the species with qualifications$/ do
  @procedures.assign_personnel(@personnel.full_name, @procedures.procedure_name)

end