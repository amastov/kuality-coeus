class QuestionLookup < Lookups

  old_ui

  element(:question_id) { |b| b.frm.text_field(id: 'questionSeqId') }

end