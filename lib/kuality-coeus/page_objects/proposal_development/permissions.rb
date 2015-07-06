class Permissions < BasePage

  buttons 'Find User'

  element(:add_user_name) { |b| b.text_field(name: "newCollectionLines['permissionsHelper.workingUserRoles'].username") }
  element(:roles) { |b| b.select(name: "newCollectionLines['permissionsHelper.workingUserRoles'].roleNames") }
  action(:add) { |b| b.button(id: 'PropDev-PermissionsPage-UserTable_add').click }

  p_value(:role_of) { |name, b| b.added_users[name] }

  value(:added_users) { |b| hash={}; b.users_table.tbody.rows.each{ |row| hash.store(row[0].text, row[1].text) }; hash }

  private
  
  element(:users_table) { |b| b.no_frame_noko.div(id: 'PropDev-PermissionsPage-UserTable').table }
  
end