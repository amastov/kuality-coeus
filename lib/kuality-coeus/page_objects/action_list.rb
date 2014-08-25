class ActionList < BasePage

  expected_element :filter_button

  # FIXME
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

  p_value(:action_requested) { |item_id, b| b.item_row(item_id).tds[b.action_requested_column].text }
  p_value(:route_status) { |item_id, b| b.item_row(item_id).tds[b.route_status_column].text }
  element(:filter_button) { |b| b.frm.button(name: 'methodToCall.viewFilter') }
  action(:filter) { |b| b.filter_button.click; b.loading }
  action(:take_actions) { |b| b.frm.link(id: 'takeMassActions').click; b.loading }
  p_element(:action) { |item_id, b| b.item_row(item_id).select(name: /actionTakenCd/) }
  action(:outbox) { |b| b.frm.link(href: /viewOutbox/).click }
  element(:last_button) { |b| b.frm.link(text: 'Last') }
  action(:last) { |b| b.last_button.click }
  action(:refresh) { |b| b.frm.button(name: 'methodToCall.refresh').click; b.loading }

  #Default action select list for FYIs
  action(:default_action) { |b| b.frm.select(name: 'defaultActionToTake') }
  action(:apply_default_action) { |b| b.frm.link(align: 'absmiddle').click }

  # Protocol Review
  p_action(:open_review) { |match, b| b.item_row(match).link.click }

  private

  value(:action_requested_column) { |b| b.results_table.tr(index: 0).ths.find_index{|th| th.text=='Action Requested'} }
  value(:route_status_column) { |b| b.results_table.tr(index: 0).ths.find_index{|th| th.text=='Route Status'} }

end