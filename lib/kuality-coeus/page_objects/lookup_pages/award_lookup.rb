class AwardLookup < Lookups

  old_ui

  expected_element :award_id

  url_info 'Award','kra.award.home.Award'

  element(:award_id) { |b| b.frm.text_field(name: 'awardNumber') }

  value(:award_ids) { |b| b.results_table.trs.map { |row| row.tds[1].text.strip }.tap(&:shift) }

  value(:results_text) { |b| b.noko.div(id: 'lookup').parent.text }

end