class DocumentHeader < BasePage

  expected_element(:header_table, 10)

  document_header_elements

  element(:header_table) { |b| b.frm.table(class: 'headerinfo') }

end

class NewDocumentHeader < BasePage

  new_doc_header

  action(:data_validation) { |b| b.link(text: 'Data Validation').when_present.click; b.loading }
  action(:budget_settings) { |b| b.link(text: 'Budget Settings').when_present.click; b.loading }
  action(:summary) { |b| b.link(text: 'Summary').when_present.click; b.loading }
  action(:copy) { |b| b.link(text: 'Copy').click; b.loading }
  action(:budget_versions) { |b| b.link(text: 'Budget Versions').when_present.click; b.loading }
  action(:autocalculate_periods) { |b| b.link(text: 'Autocalculate Periods').when_present.click; b.loading }
  action(:data_override) { |b| b.link(text: 'Data Override').when_present.click; b.loading }

end