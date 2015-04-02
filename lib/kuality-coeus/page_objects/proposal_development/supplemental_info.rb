class SupplementalInfo < BasePage
  
  document_buttons

  element(:asdf_link) { |b| b.link(id: /asdf_asdf_asdf_asdf/) }
  action(:asdf) { |b| b.asdf_link.click }
  action(:personnel_items_for_review) { |b| b.link(text: 'Personnel Items for Review').click }
  
  element(:billing_element) { |b| b.div(id: 'asdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdf_BillingElement').text_field }
  element(:graduate_student_count) { |b| b.div(id: 'PersonnelItemsforReview_GraduateStudentCount').text_field }

  element(:header_span) { |b| b.h2(class: 'uif-headerText').span(class: 'uif-headerText-span', text: 'Supplemental Info') }

end