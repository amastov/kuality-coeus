class LocationNameLookup < Lookups

  old_ui

  expected_element :location_name_code

  element(:location_name_code) { |b| b.frm.text_field(name: 'locationId') }
  element(:location_name) { |b| b.frm.text_field(name: 'locationName') }

end