class WorkflowPreferences < BasePage

  global_buttons

  element(:action_list_page_size) {|b| b.frm.text_field(name: 'preferences.pageSize') }

end