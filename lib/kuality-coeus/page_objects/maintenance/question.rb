class Question < BasePage

  description_field
  tab_buttons
  global_buttons

  element(:question) { |b| b.frm.textarea(name: 'document.newMaintainableObject.businessObject.question') }
  element(:status) { |b| b.frm.select(name: 'document.newMaintainableObject.businessObject.status') }
  element(:category) { |b| b.frm.select(name: 'document.newMaintainableObject.businessObject.categoryTypeCode') }
  element(:response_type) { |b| b.frm.select(name: 'document.newMaintainableObject.businessObject.questionTypeId') }

  element(:answer_count) { |b| b.frm.text_field(name: 'document.newMaintainableObject.businessObject.displayedAnswers') }
  element(:possible_answers) { |b| b.frm.text_field(name: 'document.newMaintainableObject.businessObject.maxAnswers') }
  element(:lookup_class) { |b| b.frm.select(name: 'document.newMaintainableObject.businessObject.lookupClass') }
  value(:lookup_class_list) { |b| b.noko.select(name: 'document.newMaintainableObject.businessObject.lookupClass').options.map{ |i| i.text } }
  element(:lookup_field) { |b| b.frm.select(name: 'document.newMaintainableObject.businessObject.lookupReturn') }
  element(:max_characters) { |b| b.frm.text_field(name: 'document.newMaintainableObject.businessObject.answerMaxLength') }

end