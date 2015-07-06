class LocationNameMaintenance < BasePage

  document_header_elements
  description_field
  tab_buttons
  global_buttons
  error_messages

  element(:location_name_code) { |b| b.frm.text_field(name: 'document.newMaintainableObject.locationId') }
  element(:location_name) { |b| b.frm.text_field(name: 'document.newMaintainableObject.locationName') }
  element(:location_type_code) { |b| b.frm.select(name: 'document.newMaintainableObject.locationTypeCode') }
  value(:location_type_code_list) { |b| b.noko.select(name: 'document.newMaintainableObject.locationTypeCode').options.map {|opt| opt.text }.tap(&:shift) }

end
