class Header < BasePage

  expected_element :doc_search_link

  # Header elements
  links 'RESEARCHER', 'UNIT', 'CENTRAL ADMIN', 'MAINTENANCE', 'SYSTEM ADMIN', 'KNS PORTAL'#, 'Doc Search', 'Action List'

  element(:doc_search_link) { |b| b.link(text: 'Doc Search') }

  action(:doc_search) { |b|
    if b.link(title: 'Document Search').present?
      b.link(title: 'Document Search').click
    else
      b.doc_search_link.click
    end
  }

end