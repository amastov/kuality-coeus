class AwardStatusLookup < Lookups

  expected_element :status_code

  url_info 'Award%20Status','kra.award.home.AwardStatus'

  element(:status_code) { |b| b.frm.text_field(name: 'statusCode') }

end