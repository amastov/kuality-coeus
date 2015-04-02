class Header < BasePage

  # Header links
  action(:researcher) { |b|
    5.times {
      b.researcher_link.click
      sleep 1 unless b.researcher_link.parent.div.visible?
      break if b.researcher_link.parent.div.visible?
    }
  }
  action(:kns_portal) { |b| b.link(text: 'SYSTEM ADMIN PORTAL').click }
  alias_method :system_admin_portal, :kns_portal

  element(:researcher_link) { |b| b.link(text: 'RESEARCHER') }
  element(:doc_search_link) { |b| b.link(text: 'Doc Search') }

  action(:doc_search) { |b|
    if b.doc_search_element.present?
      b.doc_search_element.click
    else
      b.doc_search_link.click
    end
  }

  element(:doc_search_element) { |b| b.link(title: 'Document Search') }

  action(:log_out) { |b|
    if b.link(text: /User:/).present?
      b.link(text: /User:/).click
    elsif  b.link(text: 'Logout').present?
      b.link(text: 'Logout').click
    else
      b.button(title: 'Click to logout.').when_present.click
    end
    }

  action(:action_list) { |b| b.link(text: 'Action List').click }

  # Has same visible problems as researcher
  action(:central_admin) { |b|
    5.times {
      b.central_admin_link.click
      sleep 1 unless b.central_admin_link.parent.div.visible?
      break if b.central_admin_link.parent.div.visible?
      b.refresh
      sleep 1
    }
  }
  element(:central_admin_link) { |b| b.link(text: 'CENTRAL ADMIN') }

end