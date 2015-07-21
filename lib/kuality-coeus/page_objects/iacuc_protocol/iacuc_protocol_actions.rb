class IACUCProtocolActions < KCProtocol

  # Uses Protocol Page Object Classes
  # Admin Determination - Withdraw, Approve, Incomplete
  # Make admin correction
  # Manage Review Comments
  # Manage ReviewAttachments
  # Return to PI
  # Withdraw Protocol

  value(:unavailable_actions) { |b| b.noko.div(id: 'tab-RequestanAction-div').divs(class: 'tab-container')[1].divs(class: 'innerTab-head').map { |div| div.text.gsub(/^\W+/, '') } }

end