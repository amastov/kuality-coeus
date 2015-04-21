class KCPerson < BasePage

  tab_buttons

  value(:last_name) { |b| b.span(id: 'lastName.div').text.strip }
  value(:first_name) { |b| b.span(id: 'firstName.div').text.strip }
  value(:full_name) { |b| b.span(id: 'fullName.div').text.strip }

  action(:close_window) { |b| b.windows.last.close }

end