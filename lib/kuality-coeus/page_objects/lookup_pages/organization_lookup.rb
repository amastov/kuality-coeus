class OrganizationLookup < Lookups

  old_ui

  expected_element :organization_id

  element(:organization_id) { |b| b.frm.text_field(name: 'organizationId') }
  element(:organization_name) { |b| b.frm.text_field(name: 'organizationName') }

end

class OrganizationInquiry < Lookups
  # Page for uneditable info for an Organization
  value(:organization_id) { |b| b.no_frame_noko.span(id: 'organizationId.div').text.gsub(/\W+$/, '') }
  value(:organization_name) { |b| b.no_frame_noko.span(id: 'organizationName.div').text.gsub(/\W+$/, '') }
  value(:address) { |b| b.no_frame_noko.span(id: 'address.div').text.gsub(/\W+$/, '') }
  value(:vendor_code) { |b| b.no_frame_noko.span(id: 'vendorCode.div').text.gsub(/\W+$/, '') }

  action(:close_direct_inquiry) { |b| b.link(id: 'closeDirectInquiry').click; b.windows[0].use }

end