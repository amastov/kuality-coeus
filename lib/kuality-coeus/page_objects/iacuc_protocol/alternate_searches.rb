class AlternateSearches < KCProtocol
  #Date cannot be in the future
  element(:date) {|b| b.frm.text_field(name: 'iacucAlternateSearchHelper.newAlternateSearch.searchDate') }

  element(:database_available) { |b| b.frm.select(name: 'iacucAlternateSearchHelper.newAlternateSearch.databases') }
  element(:database_selected) { |b| b.frm.select(name: 'iacucAlternateSearchHelper.newDatabases') }
  action(:move_right) { |b| b.frm.button(name: 'move_right').click }
  action(:move_left) { |b| b.frm.button(name: 'move_left').click }
  element(:years) { |b| b.frm.textarea(name: 'iacucAlternateSearchHelper.newAlternateSearch.yearsSearched') }
  element(:keywords) { |b| b.frm.textarea(name: 'iacucAlternateSearchHelper.newAlternateSearch.keywords') }
  action(:add_alternate_search) { |b| b.frm.button(name: 'methodToCall.addAlternateSearchDatabase.anchorAlternateSearch').click; b.loading}

end