class ResearchAreasLookup < Lookups

  old_ui

  expected_element :research_area_code

  results_multi_select

  element(:research_area_code) { |b| b.frm.text_field(name: 'researchAreaCode') }
  element(:parent_research_area_code) { |b| b.frm.text_field(name: 'parentResearchAreaCode') }
  element(:code_description) { |b| b.frm.text_field(name: 'description') }

  value(:research_descriptions) { |b| b.results_table.rows.map{ |row| row[4].text.strip }[2..-1] }
end
