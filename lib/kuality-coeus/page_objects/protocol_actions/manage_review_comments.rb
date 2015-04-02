class ManageReviewComments < KCProtocol

  p_element(:review_comment) { |text, b| b.frm.textarea(value: text) }
  p_element(:private) { |text, b| b.review_comment(text).parent.parent.checkbox(title: 'Private') }
  p_element(:final) { |text, b| b.review_comment(text).parent.parent.checkbox(title: 'Final') }

  action(:submit) { |b| b.frm.button(name: /methodToCall.manageComments.anchor/).click; b.loading }

end