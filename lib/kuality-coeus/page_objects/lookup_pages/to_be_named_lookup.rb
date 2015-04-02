class ToBeNamedPersonsLookup < Lookups

  expected_element :person_name

  results_multi_select

  element(:person_name) { |b| b.frm.text_field(id: 'personName') }

  alias_method :select_person, :check_item

  value(:returned_person_names) { |b| b.target_column(3).map{ |td| td.text.strip } }

end