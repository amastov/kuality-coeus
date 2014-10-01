class DevelopmentProposalLookup < Lookups

  expected_element :proposal_number

  buttons 'Search'

  element(:proposal_number) { |b| b.text_field(name: 'lookupCriteria[proposalNumber]') }

  element(:results_table) { |b| b.table(id: 'uLookupResults_layout') }
  p_action(:edit_proposal) { |match, b| b.results_table.row(text: /#{match}/).link(text: 'edit').click }

end