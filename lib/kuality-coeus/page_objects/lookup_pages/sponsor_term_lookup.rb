class SponsorTermLookup < Lookups

  expected_element :sponsor_term_id

  old_ui
  #needed in Sponsor Template Term lookup
  results_multi_select

  action(:return_random_term) {|b| b.random_term_result.set; b.return_selected }
  value(:random_term_result) { |b| b.results_table.checkboxes.to_a.sample }

  element(:last_button) { |b| b.frm.link(text: 'Last') }
  action(:last) { |b| b.last_button.click }
  element(:sponsor_term_id) { |b| b.frm.text_field(name: 'sponsorTermId') }
  element(:sponsor_term_id_column) { |b| b.frm.link(text: 'Sponsor Term Id')}
  action(:sort_sponsor_term_id) { |b| b.sponsor_term_id_column.click }

end