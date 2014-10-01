class DocumentHeader < BasePage

  expected_element(:header_table, 10)

  document_header_elements

  element(:header_table) { |b| b.frm.table(class: 'headerinfo') }

end

class NewDocumentHeader < BasePage

  new_doc_header

  action(:data_validation) { |b| b.link(text: 'Data Validation').when_present.click; b.loading }

end