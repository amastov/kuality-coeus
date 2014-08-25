class SponsorTerm < BasePage

  document_header_elements

  description_field
  tab_buttons
  global_buttons
  error_messages

  #FIXME!!!!!
  def search_results_table
    element(:results_table) { |b| b.frm.table(id: 'row') }

    action(:edit_item) { |match, p| p.results_table.row(text: /#{Regexp.escape(match)}/m).link(text: 'edit').click; p.use_new_tab; p.close_parents }
    alias_method :edit_person, :edit_item

    action(:edit_first_item) { |b| b.frm.link(text: 'edit').click; b.use_new_tab; b.close_parents }

    action(:item_row) { |match, b| b.results_table.row(text: /#{Regexp.escape(match)}/m) }
    # Note: Use this when you need to click the "open" link on the target row
    action(:open) { |match, p| p.results_table.row(text: /#{Regexp.escape(match)}/m).link(text: 'open').click; p.use_new_tab; p.close_parents }
    # Note: Use this when the link itself is the text you want to match
    p_action(:open_item) { |match, b| b.frm.link(text: /#{Regexp.escape(match)}/).click; b.use_new_tab; b.close_parents }
    p_action(:delete_item) { |match, p| p.item_row(match).link(text: 'delete').click; p.use_new_tab; p.close_parents }

    p_action(:return_value) { |match, p| p.item_row(match).link(text: 'return value').click }
    p_action(:select_item) { |match, p| p.item_row(match).link(text: 'select').click }
    action(:return_random) { |b| b.return_value_links[rand(b.return_value_links.length)].click }
    element(:return_value_links) { |b| b.results_table.links(text: 'return value') }

    p_value(:docs_w_status) { |status, b| array = []; (b.results_table.rows.find_all{|row| row[3].text==status}).each { |row| array << row[0].text }; array }

    # Used as the catch-all "document opening" method for conditional navigation,
    # when we can't know whether the current user will have edit permissions.
    # Note: The assumption is that there is only one item returned in the search,
    # so the method needs no identifying parameter. If more items are returned hopefully
    # you want the automation to click on the first item listed...
    action(:medusa) { |b| b.frm.link(text: /medusa|edit|view/).click; b.use_new_tab; b.close_parents }
  end


  element(:sponsor_term_id) { |b| b.frm.text_field(name: 'document.newMaintainableObject.sponsorTermId') }
  element(:sponsor_term_code) { |b| b.frm.text_field(name: 'document.newMaintainableObject.sponsorTermCode') }
  element(:sponsor_term_type_code) { |b| b.frm.select(name: 'document.newMaintainableObject.sponsorTermTypeCode') }
  element(:sponsor_term_description) { |b| b.frm.text_field(name: 'document.newMaintainableObject.description') }


end