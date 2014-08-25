class OrganizationLookup < Lookups

  old_ui

  expected_element :organization_id

  element(:organization_id) { |b| b.frm.text_field(name: 'organizationId') }
  element(:organization_name) { |b| b.frm.text_field(name: 'organizationName') }

end