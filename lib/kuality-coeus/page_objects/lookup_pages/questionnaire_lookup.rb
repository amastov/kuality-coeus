class QuestionnaireLookup < Lookups

  old_ui

  element(:questionnaire_id) { |b| b.frm.text_field(name: 'questionnaireSeqId') }

end