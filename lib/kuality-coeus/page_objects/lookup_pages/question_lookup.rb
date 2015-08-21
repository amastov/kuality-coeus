class QuestionLookup < Lookups

  old_ui
  results_multi_select
  undefine :return_selected

  action(:return_selected) { |b| b.frm.button(title: 'Return selected results').click; b.portal_window.use }

  element(:question_id) { |b| b.frm.text_field(id: 'questionSeqId') }
  element(:question) { |b| b.frm.text_field(id: 'question') }

  value(:target_question_id) { |b| b.noko.tds(class: 'infocell')[1].text }

end