class DocumentSearch < Lookups

  old_ui

  expected_element :document_id

  element(:document_id) { |b| b.frm.text_field(id: 'documentId') }
  element(:date_created_from) { |b| b.frm.text_field(name: 'rangeLowerBoundKeyPrefix_dateCreated') }

  action(:open_doc) { |document_id, b| b.frm.link(text: document_id).click; b.use_new_tab }
  value(:doc_status) { |document_id, b| b.results_table.row(text: /#{document_id}/)[3].text }

  action(:open_result) { |document_id, b| b.frm.link(text: document_id).click }
end