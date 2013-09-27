class ToBeNamedPersonsLookup < Lookups

  element(:person_name) { |b| b.frm.text_field(id: 'personName') }

  alias_method :select_person, :check_item

  value(:returned_full_names) { |b| names=[]; b.results_table.trs.each { |row| names << row.tds[2].text.strip! }; 2.times{names.delete_at(0)}; names }

end