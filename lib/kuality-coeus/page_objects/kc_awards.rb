class KCAwards < BasePage

  document_header_elements
  tab_buttons
  global_buttons

  class << self

    def award_header_elements
      buttons 'Award', 'Contacts', 'Commitments', 'Budget Versions',
              'Payment, Reports & Terms', 'Special Review', 'Custom Data',
              'Comments, Notes & Attachments', 'Award Actions', 'Medusa'
    end

  end

end