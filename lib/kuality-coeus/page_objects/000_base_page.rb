class BasePage < PageFactory

  action(:use_new_tab) { |b| b.windows.last.use }
  action(:return_to_portal) { |b| b.portal_window.use }
  action(:close_children) { |b| b.windows[1..-1].each{ |w| w.close} }
  action(:close_parents) { |b| b.windows[0..-2].each{ |w| w.close} }
  action(:loading) { |b| b.frm.image(alt: 'working...').wait_while_present }
  element(:logout_button) { |b| b.button(title: 'Click to logout.') }
  action(:logout) { |b| b.logout_button.click }

  element(:portal_window) { |b| b.windows(title: 'Kuali Portal Index')[0] }

  class << self

    def glbl(*titles)
      titles.each do |title|
        action(damballa(title)) { |b| b.frm.button(class: 'globalbuttons', title: title).click; b.loading }
      end
    end

    def document_header_elements
      element(:headerinfo_table) { |b| b.frm.div(id: 'headerarea').table(class: 'headerinfo') }

      value(:document_id) { |p| p.headerinfo_table[0][1].text }
      alias_method :doc_nbr, :document_id
      value(:document_status) { |p| p.headerinfo_table[0][3].text }
      value(:initiator) { |p| p.headerinfo_table[1][1].text }
      value(:last_updated) {|p| p.headerinfo_table[1][3].text }
      alias_method :created, :last_updated
      value(:committee_id) { |p| p.headerinfo_table[2][1].text }
      alias_method :sponsor_name, :committee_id
      alias_method :budget_name, :committee_id
      value(:committee_name) { |p| p.headerinfo_table[2][3].text }
      alias_method :pi, :committee_name
    end

    def global_buttons
      glbl 'save', 'Reject', 'blanket approve', 'close', 'cancel', 'reload',
           'Submit To Sponsor', 'Send Notification', 'Delete Proposal',
           'Generate All Periods', 'Calculate All Periods', 'Default Periods',
           'Calculate Current Period', 'submit', 'approve', 'disapprove'
      # Explicitly defining the "recall" button to keep the method name at "recall" instead of "recall_current_document"...
      element(:recall_button) { |b| b.frm.button(class: 'globalbuttons', title: 'Recall current document') }
      action(:recall) { |b| b.recall_button.click; b.loading }
      action(:delete_selected) { |b| b.frm.button(class: 'globalbuttons', name: 'methodToCall.deletePerson').click; b.loading }
    end

    def tab_buttons
      action(:expand_all) { |b| b.frm.button(name: 'methodToCall.showAllTabs').click; b.loading }
    end

    def tiny_buttons
      action(:search) { |b| b.frm.button(title: 'search', value: 'search').click; b.loading }
      action(:clear) { |b| b.frm.button(name: 'methodToCall.clearValues').click; b.loading }
      action(:cancel_button) { |b| b.frm.link(title: 'cancel').click; b.loading }
      action(:yes) { |b| b.frm.button(name: 'methodToCall.rejectYes').click; b.loading }
      action(:no) {|b| b.frm.button(name: 'methodToCall.rejectNo').click; b.loading }
    end

    def search_results_table
      element(:results_table) { |b| b.frm.table(id: 'row') }

      action(:edit_item) { |match, p| p.results_table.row(text: /#{match}/m).link(text: 'edit').click; b.use_new_tab; b.close_parents }
      alias_method :edit_person, :edit_item

      action(:item_row) { |match, b| b.results_table.row(text: /#{match}/) }
      action(:open_item) { |match, b| b.results_table.row(text: /#{match}/m).link(text: /#{match}/).click; b.use_new_tab; b.close_parents }
      action(:delete_item) { |match, p| p.results_table.row(text: /#{match}/m).link(text: 'delete').click; b.use_new_tab; b.close_parents }

      action(:return_value) { |match, p| p.results_table.row(text: /#{match}/m).link(text: 'return value').click }
      action(:return_random) { |b| b.return_value_links[rand(b.return_value_links.length)].click }
      element(:return_value_links) { |b| b.results_table.links(text: 'return value') }
    end

    def budget_header_elements
      action(:return_to_proposal) { |b| b.frm.button(name: 'methodToCall.returnToProposal').click }
      buttons 'Budget Version', 'Parameters', 'Rates', 'Summary', 'Personnel', 'Non-Personnel',
              'Distribution & Income', 'Budget Actions'
      # Need the _tab suffix because of method collisions
      action(:modular_budget_tab) { |b| b.frm.button(value: 'Modular Budget').click }
    end

    # Gathers all errors on the page and puts them in an array called "errors"
    def error_messages
      element(:errors) do |b|
        errs = []
        b.left_errmsg_tabs.each do |div|
          if div.div.div.exist?
            errs << div.div.divs.collect{ |div| div.text }
          elsif div.li.exist?
            errs << div.lis.collect{ |li| li.text }
          end
        end
        b.left_errmsg.each do |div|
          if div.div.div.exist?
            errs << div.div.divs.collect{ |div| div.text }
          elsif div.li.exist?
            errs << div.lis.collect{ |li| li.text }
          end
        end
        errs.flatten
      end
      element(:left_errmsg_tabs) { |b| b.frm.divs(class: 'left-errmsg-tab') }
      element(:left_errmsg) { |b| b.frm.divs(class: 'left-errmsg') }
      element(:error_messages_div) { |b| b.frm.div(class: 'error') }
    end

    def links(*links_text)
      links_text.each { |link| elementate(:link, link) }
    end

    def buttons(*buttons_text)
     buttons_text.each { |button| elementate(:button, button) }
    end

    private
    # A helper method that converts the passed string into snake case. See the StringFactory
    # module for more info.
    #
    def damballa(text)
      StringFactory::damballa(text)
    end

    def elementate(type, text)
      identifiers={:link=>:text, :button=>:value}
      el_name=damballa("#{text}_#{type}")
      act_name=damballa(text)
      element(el_name) { |b| b.frm.send(type, identifiers[type]=>text) }
      action(act_name) { |b| b.frm.send(type, identifiers[type]=>text).click }
    end

  end # self

end # BasePage