class NonOrgAddressBookLookup < Lookups

  old_ui
  results_multi_select

  alias_method :select_person, :check_item

  value(:returned_full_names) { |b| b.results_table.trs.map { |row| "#{row.tds[13].text.strip} #{row.tds[14].text.strip}" }.tap(&:shift).tap(&:shift) }

end