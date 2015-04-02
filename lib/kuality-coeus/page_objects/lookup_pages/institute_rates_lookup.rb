class InstituteRatesLookup < Lookups

  expected_element :activity_type_code

  url_info 'Institute%20Rate','kra.bo.InstituteRate'

  element(:activity_type_code) { |b| b.frm.text_field(name: 'activityTypeCode') }
  element(:fiscal_year) { |b| b.frm.text_field(name: 'fiscalYear') }
  action(:on_off_campus) { |value, b| b.frm.radio(name: 'onOffCampusFlag', value: value).set }
  element(:rate_class_code) { |b| b.frm.text_field(name: 'rateClassCode') }
  element(:rate_type_code) { |b| b.frm.text_field(name: 'rateTypeCode') }
  element(:rate) { |b| b.frm.text_field(name: 'instituteRate') }
  element(:unit_number) { |b| b.frm.text_field(name: 'unitNumber') }

end