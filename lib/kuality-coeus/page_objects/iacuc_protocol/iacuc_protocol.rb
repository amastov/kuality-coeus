class IACUCProtocolOverview < KCProtocol

  expected_element :application

  description_field
  tiny_buttons
  protocol_common

  alias :status :document_status

  # Required Fields
  element(:protocol_project_type) { |b| b.frm.select(name: 'document.protocolList[0].protocolProjectTypeCode') }
  value(:protocol_project_type_options) { |b| b.noko.select(name: 'document.protocolList[0].protocolProjectTypeCode').options.map {|opt| opt.text }[1..-1] }
  element(:lay_statement_1) { |b| b.frm.textarea(name: 'document.protocolList[0].layStatement1') }
  element(:lay_statement_2) { |b| b.frm.textarea(name: 'document.protocolList[0].layStatement2') }
end
