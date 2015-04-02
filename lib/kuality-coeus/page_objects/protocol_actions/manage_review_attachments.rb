class ManageReviewAttachments < KCProtocol

  element(:description) { |b| b.frm.textarea(name: 'actionHelper.protocolManageReviewCommentsBean.reviewAttachmentsBean.newReviewAttachment.description') }
  element(:file_name) { |b| b.frm.fiile_field(name: 'actionHelper.protocolManageReviewCommentsBean.reviewAttachmentsBean.newReviewAttachment.newFile') }
  element(:can_view) { |b| b.frm.checkbox(name: 'actionHelper.protocolManageReviewCommentsBean.reviewAttachmentsBean.newReviewAttachment.protocolPersonCanView') }
  action(:add_attachment) { |b| b.frm.button(name: /^methodToCall.addReviewAttachment.taskNameprotocolManageReviewComments.anchor/).click; b.loading }
  action(:submit) { |b| b.frm.button(name: /^methodToCall.manageAttachments.anchor/).click; b.loading }

end
