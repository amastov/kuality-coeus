class OrganizationLookup < Lookups

  old_ui

  expected_element :organization_id

  element(:organization_id) { |b| b.frm.text_field(name: 'organizationId') }
  element(:organization_name) { |b| b.frm.text_field(name: 'organizationName') }

end

class OrganizationInquiry < Lookups
  # Page for uneditable info for an Organization
  value(:organization_id) { |b| b.span(id: 'organizationId.div').text.strip }
  value(:organization_name) { |b| b.span(id: 'organizationName.div').text.strip }
  value(:address) { |b| b.span(id: 'address.div').text.strip }
  value(:vendor_code) { |b| b.span(id: 'vendorCode.div').text.strip }

  action(:close_direct_inquiry) { |b| b.link(id: 'closeDirectInquiry').click }

end