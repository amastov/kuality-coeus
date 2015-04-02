class OnlineReview < KCProtocol

  # Document Overview
  p_value(:review_doc_nbr) { |name, b| b.reviewer_panel(name).table(title: 'view/edit document overview information').tr.td.text }

  # Online Review
  p_element(:requested_date) { |name, b| b.reviewer_panel(name).text_field(title: 'Requested Date') }
  p_element(:due_date) { |name, b| b.reviewer_panel(name).text_field(title: 'Due Date') }
  p_element(:reviewer_type) { |name, b| b.reviewer_panel(name).select(title: 'Reviewer Type') }
  p_element(:determination_recommendation) { |name, b| b.reviewer_panel(name).select(title: 'Determination Recommendation') }

  # Review Comments
  p_element(:new_review_comment) { |name, b| b.reviewer_panel(name).textarea(name: /newReviewComment/) }
  p_element(:new_comment_private) { |name, b| b.reviewer_panel(name).checkbox(title: 'Private') }
  p_element(:new_comment_final) { |name, b| b.reviewer_panel(name).checkbox(title: 'Final') }
  p_action(:add_comment) { |name, b| b.reviewer_panel(name).button(name: /methodToCall.addOnlineReviewComment.\d+.anchor:ReviewComments/).click; b.loading }

  p_element(:review_comment) { |text, b| b.frm.textarea(value: text) }
  p_element(:comment_private) { |text, b| b.review_comment(text).parent.parent.checkbox(title: 'Private') }
  p_element(:comment_final) { |text, b| b.review_comment(text).parent.parent.checkbox(title: 'Final') }

  # Review Attachment
  p_element(:new_attachment_description) { |name, b| b.reviewer_panel(name).textarea(name: /newReviewAttachment.description/) }
  p_element(:new_attachment_filename) { |name, b| b.reviewer_panel(name).file_field(name: /newReviewAttachment.newFile/) }
  p_element(:can_view_new_attachment) { |name, b| b.reviewer_panel(name).checkbox(title: 'Protocol personnel can view') }
  p_action(:add_attachment) { |name, b| b.reviewer_panel(name).button(name: /methodToCall.addOnlineReviewAttachment.\d+.anchor:ReviewAttachment/).click; b.loading }

  # Review Global Buttons
  p_action(:save_review_of) { |name, b| b.reviewer_panel(name).button(name: /methodToCall.saveOnlineReview/).click; b.loading }
  p_action(:approve_review_of) { |name, b| b.reviewer_panel(name).button(name: /methodToCall.approveOnlineReview/).click; b.loading; b.awaiting_doc }
  alias :accept_review_comments_of :approve_review_of
  p_action(:delete_review_of) { |name, b| b.reviewer_panel(name).button(name: /methodToCall.deleteOnlineReview/).click; b.loading }

  private

  p_element(:reviewer_panel) { |name, b| b.frm.div(id: "tab-OnlineReview#{nospace(name)}-div") }

end