class ProposalQuestionnaire < BasePage

  document_buttons

  element(:header_span) { |b| b.h3.span(class: 'uif-headerText-span', text: 'Questionnaire') }
  
end