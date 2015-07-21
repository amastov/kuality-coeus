class CommitteeLookup < Lookups

  expected_element :committee_id

  old_ui

  element(:committee_id) { |b| b.frm.text_field(name: 'committeeId') }
  element(:committee_name) { |b| b.frm.text_field(name: 'committeeName') }
  
end