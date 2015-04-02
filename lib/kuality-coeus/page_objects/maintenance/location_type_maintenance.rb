class LocationTypeMaintenance < BasePage

  document_header_elements
  description_field
  tab_buttons
  global_buttons
  error_messages

  element(:location_type_code) { |b| b.frm.text_field(name: 'document.newMaintainableObject.locationTypeCode') }
  element(:location_type) { |b| b.frm.text_field(name: 'document.newMaintainableObject.location') }
end
