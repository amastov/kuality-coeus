class OnlineReview < KCProtocol

  p_element(:requested_date) { |name, b| b.reviewer_panel(name).text_field(title: 'Requested Date') }
  p_element(:due_date) { |name, b| b.reviewer_panel(name).text_field(title: 'Due Date') }
  p_element(:reviewer_type) { |name, b| b.reviewer_panel(name).select(title: 'Reviewer Type') }
  p_element(:determination_recommendation) { |name, b| b.reviewer_panel(name).select(title: 'Determination Recommendation') }

  # Review Comments
  p_element(:new_review_comment) { |name, b| b.reviewer_panel(name).textarea(name: /newReviewComment/) }
  p_element(:new_comment_private) { |name, b| b.reviewer_panel(name).checkbox(title: 'Private') }
  p_element(:new_comment_final) { |name, b| b.reviewer_panel(name).checkbox(title: 'Final') }
  p_action(:add_comment) { |name, b| b.reviewer_panel(name).button(name: /methodToCall.addOnlineReviewComment.\d+.anchor:ReviewComments/).click; b.loading }

  # Review Attachment
  p_element(:new_attachment_description) { |name, b| b.reviewer_panel(name).textarea(name: /newReviewAttachment.description/) }
  p_element(:new_attachment_filename) { |name, b| b.reviewer_panel(name).file_field(name: /newReviewAttachment.newFile/) }
  p_element(:can_view_new_attachment) { |name, b| b.reviewer_panel(name).checkbox(title: 'Protocol personnel can view') }
  p_action(:add_attachment) { |name, b| b.reviewer_panel(name).button(name: /methodToCall.addOnlineReviewAttachment.\d+.anchor:ReviewAttachment/).click; b.loading }

  # Review Global Buttons
  p_action(:save_review_of) { |name, b| b.reviewer_panel(name).button(name: /methodToCall.saveOnlineReview/).click; b.loading }
  p_action(:approve_review_of) { |name, b| b.reviewer_panel(name).button(name: /methodToCall.saveOnlineReview/).click; b.loading }
  p_action(:delete_review_of) { |name, b| b.reviewer_panel(name).button(name: /methodToCall.saveOnlineReview/).click; b.loading }

  private

  p_element(:reviewer_panel) { |name, b| b.frm.div(id: "tab-OnlineReview#{nospace(name)}-div") }

end