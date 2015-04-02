class TheThreeRs < KCProtocol

  element(:reduction) { |b| b.frm.textarea(name: 'document.protocolList[0].iacucPrinciples[0].reduction') }
  element(:refinement) { |b| b.frm.textarea(name: 'document.protocolList[0].iacucPrinciples[0].refinement') }
  element(:replacement) { |b| b.frm.textarea(name: 'document.protocolList[0].iacucPrinciples[0].replacement') }

  element(:alternate_search_required) { |b| b.frm.select(name: 'document.protocolList[0].iacucPrinciples[0].searchRequired') }

  action(:reduction_expand) { |b| b.frm.button(alt: 'Expand Text Area', title: 'Principles of Reduction').click; b.use_new_tab }
  action(:refinement_expand) { |b| b.frm.button(alt: 'Expand Text Area', title: 'Principles of Refinement').click; b.use_new_tab }
  action(:replacement_expand) { |b| b.frm.button(alt: 'Expand Text Area', title: 'Principles of Replacement').click; b.use_new_tab }

  action(:continue) { |b| b.continue_button.click; b.close_children }
  element(:continue_button) { |b| b.frm.button(name: 'methodToCall.postTextAreaToParent.anchor') }
end
