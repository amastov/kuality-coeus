class ProposalStatusLookup < Lookups

  expected_element :proposal_status_code

  element(:proposal_status_code) { |b| b.frm.text_field(name: 'proposalStatusCode') }

end