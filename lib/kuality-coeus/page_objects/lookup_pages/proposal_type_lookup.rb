class ProposalTypeLookup < Lookups

  expected_element :proposal_type_code

  element(:proposal_type_code) { |b| b.frm.text_field(name: 'proposalTypeCode') }

end