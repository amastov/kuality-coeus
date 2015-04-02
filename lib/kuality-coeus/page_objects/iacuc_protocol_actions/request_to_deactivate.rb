class RequestToDeactivate < KCProtocol

  element(:reason) { |b| b.frm.textarea(name: 'actionHelper.iacucProtocolDeactivateRequestBean.reason') }


  action(:submit1_button) { |b| b.frm.button(name: 'methodToCall.requestAction.taskNameiacucProtocolRequestDeactivate.anchor:RequesttoDeactivate') }
  action(:submit1) { |b| b.submit1_button.click; b.loading}
  action(:submit2_button) { |b| b.frm.button(name: /^methodToCall.iacucDeactivate.anchor/) }
  action(:submit2) { |b| b.submit2_button.click; b.loading }

  action(:submit) do |b|
    #We have been blessed with 2 different submit buttons that can display.
    # Not sure the pattern maybe its depending on the doc type/status/user
    b.submit1 if b.submit1_button.exists?
    b.submit2 if b.submit2_button.exists?
  end

end