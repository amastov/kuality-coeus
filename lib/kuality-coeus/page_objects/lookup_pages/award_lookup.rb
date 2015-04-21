class AwardLookup < Lookups

  old_ui

  expected_element :award_id

  url_info 'Award','kra.award.home.Award'

  element(:award_id) { |b| b.frm.text_field(name: 'awardNumber') }

  value(:award_ids) { |b|
    ids=[]
    b.results_table.trs.each { |row| ids << row.tds[1].text.strip }
    ids.delete_at(0)
    ids
  }

  value(:results_text) { |b| b.frm.div(id: 'lookup').parent.text }
end