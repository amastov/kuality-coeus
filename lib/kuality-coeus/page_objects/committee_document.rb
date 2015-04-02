class CommitteeDocument < BasePage

  global_buttons
  tab_buttons
  error_messages
  buttons 'Actions'

  action(:committee) { |b| b.frm.button(alt: 'Committee').click; b.loading_old  }
  action(:members) { |b| b.frm.button(alt: 'Members').click; b.loading_old}
  action(:schedule) { |b| b.frm.button(alt: 'Schedule').click; b.loading_old  }

end