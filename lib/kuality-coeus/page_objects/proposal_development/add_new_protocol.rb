class AddNewProtocol < BasePage

  expected_element :dialog_box
  new_error_messages

  element(:type) { |b| b.loading; b.select(name: "newCollectionLines['document.developmentProposal.propSpecialReviews'].specialReviewTypeCode") }
  element(:approval_status) { |b| b.loading; b.select(name: "newCollectionLines['document.developmentProposal.propSpecialReviews'].approvalTypeCode") }
  element(:protocol_number) { |b| b.loading; b.text_field(name: "newCollectionLines['document.developmentProposal.propSpecialReviews'].protocolNumber") }
  element(:application_date) { |b| b.loading; b.text_field(name: "newCollectionLines['document.developmentProposal.propSpecialReviews'].applicationDate") }
  element(:approval_date) { |b| b.loading; b.text_field(name: "newCollectionLines['document.developmentProposal.propSpecialReviews'].approvalDate") }
  element(:expiration_date) { |b| b.loading; b.text_field(name: "newCollectionLines['document.developmentProposal.propSpecialReviews'].expirationDate") }

  # TODO:
  # element(:exemption) { |b| ... }

  action(:add_entry) { |b| b.button(text:'Add Entry').click; b.dialog_box.wait_while_present(4); b.img(alt: 'Adding...').wait_while_present(10) }

  element(:dialog_box) { |b| b.section(id: 'PropDev-CompliancePage_AddDialog') }

end