class KimTypeLookup < Lookups

  old_ui

  expected_element :namespace_code

  element(:namespace_code) { |b| b.frm.select(name: 'namespaceCode') }
  element(:type_name) { |b| b.frm.text_field(name: 'name') }
  
end