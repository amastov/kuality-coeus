class Header < BasePage

  expected_element :doc_search_link

  # Header links
  action(:researcher) { |b|
    5.times {
      b.researcher_link.click
      sleep 1
      break if b.researcher_link.parent.div.visible?
    }
  }
  action(:kns_portal) { |b| b.link(text: 'KNS PORTAL').click }

  element(:researcher_link) { |b| b.link(text: 'RESEARCHER') }
  element(:doc_search_link) { |b| b.link(text: 'Doc Search') }

  action(:doc_search) { |b|
    if b.link(title: 'Document Search').present?
      b.link(title: 'Document Search').click
    else
      b.doc_search_link.click
    end
  }

end