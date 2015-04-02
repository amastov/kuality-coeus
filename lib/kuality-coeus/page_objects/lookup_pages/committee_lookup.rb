class CommitteeLookup < Lookups

  expected_element :committee_id

  url_info 'Committee%20Lookup','kra.committee.bo.Committee'

  element(:committee_id) { |b| b.frm.text_field(name: 'committeeId') }
  element(:committee_name) { |b| b.frm.text_field(name: 'committeeName') }
  
end