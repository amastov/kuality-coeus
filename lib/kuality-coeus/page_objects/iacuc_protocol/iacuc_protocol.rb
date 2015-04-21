class IACUCProtocolOverview < KCProtocol

  description_field
  tiny_buttons

  protocol_common

  # Required Fields
  element(:protocol_project_type) { |b| b.frm.select(name: 'document.protocolList[0].protocolProjectTypeCode') }
  element(:lay_statement_1) { |b| b.frm.textarea(name: 'document.protocolList[0].layStatement1') }
  element(:lay_statement_2) { |b| b.frm.textarea(name: 'document.protocolList[0].layStatement2') }
end
