class ParameterLookup < Lookups

  expected_element :parameter_name
  old_ui

  element(:parameter_name) { |b| b.frm.text_field(id: 'name') }

end