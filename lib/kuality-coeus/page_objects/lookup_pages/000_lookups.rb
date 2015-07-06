class Lookups < BasePage

  p_action(:active) { |yes_no_both, b| b.frm.radio(id: "active#{yes_no_both.capitalize}").set }

  class << self

    def old_ui
      element(:results_table) { |b| b.frm.table(id: 'row') }

      action(:edit_item) { |match, p| p.results_table.row(text: /#{Regexp.escape(match)}/m).link(text: 'edit').click; p.use_new_tab; p.close_parents }
      alias_method :edit_person, :edit_item

      action(:edit_first_item) { |b| b.frm.link(text: 'edit').when_present.click; b.use_new_tab; b.close_parents }
      action(:view_first_item) { |b| b.frm.link(text: 'view').when_present.click; b.use_new_tab; b.close_parents }

      action(:item_row) { |match, b| b.results_table.row(text: /#{Regexp.escape(match)}/m) }
      # Note: Use this when you need to click the "open" link on the target row
      action(:open) { |match, p| p.results_table.row(text: /#{Regexp.escape(match)}/m).link(text: 'open').click; p.use_new_tab; p.close_parents }
      # Note: Use this when the link itself is the text you want to match
      p_action(:open_item) { |match, b| b.frm.link(text: /#{Regexp.escape(match)}/).click; b.use_new_tab; b.close_parents }
      p_action(:delete_item) { |match, p| p.item_row(match).link(text: 'delete').click; p.use_new_tab; p.close_parents }

      p_action(:return_value) { |match, p| p.item_row(match).link(text: 'return value').click }
      p_action(:select_item) { |match, p| p.item_row(match).link(text: 'select').click }
      action(:return_random) { |b| b.return_value_links.to_a.sample.click }
      element(:return_value_links) { |b| b.results_table.links(text: 'return value') }
      #used by Award for adding a key person wher user name is important
      action(:select_random_with_name) { |b| b.results_table.tbody.trs.to_a.sample.link(title: /^with KC Person KcPerson/).click; b.use_new_tab }

      p_value(:docs_w_status) { |status, b| (b.results_table.rows.find_all{|row| row[3].text==status}).map { |row| row[0].text } }

      # Used as the catch-all "document opening" method for conditional navigation,
      # when we can't know whether the current user will have edit permissions.
      # Note: The assumption is that there is only one item returned in the search,
      # so the method needs no identifying parameter. If more items are returned hopefully
      # you want the automation to click on the first item listed...
      action(:medusa) { |b| b.frm.link(text: /medusa|edit|view/).click; b.use_new_tab; b.close_parents }
      element(:last_name) { |b| b.frm.text_field(id: 'lastName') }
      element(:first_name) { |b| b.frm.text_field(id: 'firstName') }
      element(:full_name) { |b| b.frm.text_field(id: 'fullName') }
      element(:user_name) { |b| b.frm.text_field(id: 'userName') }
      element(:state) { |b| b.frm.select(id: 'state') }                                 #DEBUG
      action(:search) { |b| b.frm.button(title: 'search', value: 'search').when_present(180).click; b.loading }
      element(:create_button) { |b| b.frm.link(title: 'Create a new record') }
      action(:create_new) { |b| b.create_button.click; b.loading }
      alias_method :create, :create_new
    end

    def dialog_ui
      action(:search) { |b| b.frm.button(id: 'ufuknop').click; b.results_table.wait_until_present }
      element(:results_table) { |b| b.frm.table(id: 'uLookupResults_layout') }
      action(:select_random) { |b| b.select_links.to_a.sample.click; b.loading }
      element(:select_links) { |b| b.results_table.links(text: 'select') }
    end

    def url_info(title, class_name)
      url = %|#{$base_url+$context
                    }portal.do?channelTitle=#{
                  title
                    }&channelUrl=#{
                  $base_url[/.*(?=\/$)/]+':'+$port+'/'+$context
                    }kr/lookup.do?methodToCall=start&businessObjectClassName=org.kuali.#{
                  class_name
                    }&docFormKey=88888888&includeCustomActionUrls=true&returnLocation=#{
                  $base_url[/.*(?=\/$)/]+':'+$port+'/'+$context
                    }portal.do&hideReturnLink=true|
      page_url url
    end

  end #self
end #Lookups