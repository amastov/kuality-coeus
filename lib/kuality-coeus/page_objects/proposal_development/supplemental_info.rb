class SupplementalInfo < BasePage
  
  document_buttons
  
  action(:asdf) { |b| b.link(id: /asdf_asdf_asdf_asdf/).click }
  action(:personnel_items_for_review) { |b| b.link(text: 'Personnel Items for Review').click }
  
  element(:billing_element) { |b| b.text_field(name: 'document.customDataList[0].value') }
  element(:graduate_student_count) { |b| b.text_field(name: 'document.customDataList[3].value') }

  element(:header_span) { |b| b.h2(class: 'uif-headerText').span(class: 'uif-headerText-span', text: 'Supplemental Info') }

end