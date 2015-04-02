class SubawardLookup < Lookups

  expected_element :subaward_id

  url_info 'Subawards', 'kra.subaward.bo.SubAward'

  element(:subaward_id) { |b| b.frm.text_field(name: 'subAwardCode') }
  
end
