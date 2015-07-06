class ProtocolActions < KCProtocol

  expected_element :review_comments_table

  # For the "Request an Action" subpanel methods,
  # please see the respective page classes.

  # Summary & History
  value(:review_comments) { |b|
    begin
      b.review_comments_table.hiddens.map{ |hid| hid.value }
    rescue Selenium::WebDriver::Error::StaleElementReferenceError
      []
    end
  }

  value(:summary_initial_approval_date) { |b| b.frm.div(id: 'tab-:Summary-div').th(text: 'Expiration Date:').parent.td(index: 0).text }
  value(:summary_expiration_date) { |b| b.frm.div(id: 'tab-:Summary-div').th(text: 'Expiration Date:').parent.td(index: 1).text }

  element(:save_correspondence) { |b| b.save_correspondence_button.click }
  element(:save_correspondence_button) { |b| b.frm.button(name: 'methodToCall.saveCorrespondence') }

  private

  element(:review_comments_table) { |b| b.frm.div(id: 'tab-:ReviewComments-div').table }

end