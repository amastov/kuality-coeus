class RoleLookup < Lookups

  old_ui

  expected_element :id

  url_info 'Role','rice.kim.impl.role.RoleBo'

  element(:id) { |b| b.frm.text_field(name: 'id') }
  element(:name) { |b| b.frm.text_field(name: 'name') }

end