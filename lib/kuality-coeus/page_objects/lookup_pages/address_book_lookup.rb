class AddressBookLookup < Lookups

  expected_element :address_book_id

  url_info 'Address%20Book','kra.bo.Rolodex'

  old_ui

  element(:address_book_id) { |b| b.frm.text_field(name: 'rolodexId') }

end