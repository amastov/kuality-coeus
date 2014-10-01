class Permissions < BasePage

  buttons 'Find User'

  element(:add_user_name) { |b| b.text_field(name: "newCollectionLines['permissionsHelper.workingUserRoles'].username") }
  select(:roles, :name, "newCollectionLines['permissionsHelper.workingUserRoles'].roleNames")
  action(:add) { |b| b.button(id: 'PropDev-PermissionsPage-UserTable_add').click }

end