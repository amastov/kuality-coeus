class WorkflowPreferences < BasePage

  element(:action_list_page_size) {|b| b.frm.text_field(name: 'preferences.pageSize') }

  element(:div_global) { |b| b.frm.div(class: 'globalbuttons') }
  action(:save) { |b| b.div_global.button(name: 'methodToCall.save').click; b.loading_old; b.loading }
  action(:cancel) { |b| b.div_global.link(href: 'ActionList.do').click; }
  action(:reset) { |b| b.div_global.link(href: 'javascript:document.forms[0].reset()').click }
end