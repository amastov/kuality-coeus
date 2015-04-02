When /^(the (.*) |)creates an? IACUC Protocol$/ do |text, role_name|
  steps %{ * I log in with the #{role_name} user } unless text == ''
  @iacuc_protocol = create IACUCProtocolObject
  @iacuc_protocol.theThreeRs(alternate_search_required: 'No')
end

Given /^(the (.*) |)submits an IACUC Protocol for admin review$/ do |text, role_name|
  steps %{ * I log in with the #{role_name} user } unless text == ''
  @iacuc_protocol = create IACUCProtocolObject
  @iacuc_protocol.theThreeRs(alternate_search_required: 'No')
  @iacuc_protocol.submit_for_review review_type: 'Administrative Review'
end

And /^the IACUC Administrator approves a submitted IACUC Protocol$/ do
  steps '* I log in with the IACUC Protocol Creator user'
  @iacuc_protocol = create IACUCProtocolObject
  @iacuc_protocol.theThreeRs(alternate_search_required: 'No')
  @iacuc_protocol.submit_for_review review_type: 'Administrative Review'

  steps '* log in with the IACUC Administrator user'
  @iacuc_protocol.admin_approve
end

When /^the IACUC Protocol Creator creates an IACUC Protocol but misses a required field$/ do
  steps %{ * I log in with the IACUC Protocol Creator user }
  # Pick a field at random for the test...
  required_field = ['Lay Statement 1', 'Lead Unit', 'Title'].sample
  field = damballa(required_field)
  @iacuc_protocol = create IACUCProtocolObject, field=>' '
  text = ' is a required field.'
  errors = {
      lay_statement_1: "Lay Statement 1 (Lay Statement 1)#{text}",
      lead_unit: "#{required_field} (#{required_field})#{text}",
      title: "Title (Title)#{text}"
  }
  @required_field_error = errors[field]
end

And /the IACUC Administrator creates an? IACUC Committee with an? area of research$/ do
  steps '* log in with the IACUC Administrator user'
  @committee = create CommitteeDocumentObject, committee_type: 'iacuc', review_type: 'Full Committee Member Review'
  @committee.add_area_of_research
end

And /^(the (.*) |)creates an? IACUC Protocol with one Species$/ do |text, role_name|
  steps %{ * I log in with the #{role_name} user } unless text == ''
  @iacuc_protocol = create IACUCProtocolObject
  @species = create SpeciesObject
end

When /adds a Species with all fields completed$/ do
  @species = create SpeciesObject, strain: random_alphanums_plus, usda_covered: :set, procedure_summary: random_alphanums_plus(20)
end

When /adds a (second |)Species to the IACUC Protocol$/ do |count|
  species_number = {'' => '', 'second ' => '2'}
  set("@species#{species_number[count]}", (create SpeciesObject))
end

When /^the Application Administrator creates a new Location type maintenance document$/ do
  @location_type = create IACUCLocationTypeMaintenanceObject
end

And /adds a location name to the location type maintenance document$/ do
  @location_name = create IACUCLocationNameMaintenanceObject, location_type_code: @location_type.location_type
end

When /^(the (.*) |)assigns the created location to a Procedure on the IACUC Protocol$/ do |text, role_name|
  steps %{ * I log in with the #{role_name} user } unless text == ''
  @iacuc_protocol = create IACUCProtocolObject
  @iacuc_protocol.theThreeRs(alternate_search_required: 'No')

  @species = create SpeciesObject
  @procedures = create IACUCProceduresObject
  @procedures.set_location(type: @location_type.location_type, name: @location_name.location_name, room: rand(100..999), species: @species.species)
end

Given /^(the (.*) |)creates an IACUC Protocol with the three principles, reduction, refinement, replacement$/ do |text, role_name|
  steps %{ * I log in with the #{role_name} user } unless text == ''
  @iacuc_protocol = create IACUCProtocolObject
  @iacuc_protocol.theThreeRs(alternate_search_required: 'No')

  @iacuc_protocol.theThreeRs(reduction: random_alphanums_plus(2000), refinement: random_alphanums_plus(2000), replacement: random_alphanums_plus(2000))

end

And /^(the (.*) |)submits an Amendment for review on the IACUC Protocol$/ do |text, role_name|
  steps %{ * I log in with the #{role_name} user } unless text == ''
  @iacuc_protocol.create_amendment
  @iacuc_protocol.submit_for_review review_type: 'Administrative Review', submission_type: 'Amendment'
end

And /^(the (.*) |)creates an IACUC Protcol with the edited location name for a Procedure$/ do |text, role_name|
  steps %{ * I log in with the #{role_name} user } unless text == ''
  @iacuc_protocol = create IACUCProtocolObject
  @iacuc_protocol.theThreeRs(alternate_search_required: 'No')

  @species = create SpeciesObject
  @procedures = create IACUCProceduresObject
  @procedures.set_location location_name: @location_name.location_name,  species: @species.species
end