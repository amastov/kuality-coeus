class Questions < BasePage

  document_buttons

  p_action(:inventor) { |answer, b| b.radio(value: answer, name: 'questionnaireHelper.answerHeaders[1].questions[0].answers[0].answer').set }
  p_action(:rights) { |answer, b| b.radio(value: answer, name: 'questionnaireHelper.answerHeaders[1].questions[1].answers[0].answer').when_present(5).set }
  p_action(:non_university_investigators) { |answer, b| b.radio(value: answer, name: 'questionnaireHelper.answerHeaders[1].questions[2].answers[0].answer').set }

  0.upto(6) do |x|
    element("position_#{x}".to_sym) { |b| b.text_field(name: "questionnaireHelper.answerHeaders[1].questions[3].answers[#{x}].answer") }
  end

  element(:header_span) { |b| b.h3.span(class: 'uif-headerText-span', text: 'Questionnaire') }
  
end