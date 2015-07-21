class ProposalLog < BasePage

  description_field
  document_header_elements
  global_buttons
  tab_buttons
  route_log
  error_messages

  undefine :save_button

  element(:save_button) { |b| b.frm.button(title: 'save') }

  value(:proposal_number) { |b| b.noko.span(id: 'document.newMaintainableObject.proposalNumber.div').text.gsub(/\W+$/,'') }
  element(:proposal_log_type) { |b| b.frm.select(id: 'document.newMaintainableObject.proposalLogTypeCode') }
  value(:proposal_log_status) { |b| b.noko.span(id: 'document.newMaintainableObject.logStatus.div').text.gsub(/\W+$/,'') }
  value(:proposal_merged_with) { |b| b.noko.span(id: 'document.newMaintainableObject.mergedWith.span').text }
  element(:proposal_type) { |b| b.frm.select(id: 'document.newMaintainableObject.proposalTypeCode') }
  element(:title) { |b| b.frm.text_field(id: 'document.newMaintainableObject.title') }
  element(:lead_unit) { |b| b.frm.text_field(id: 'document.newMaintainableObject.leadUnit') }
  element(:sponsor) { |b| b.frm.text_field(name: 'document.newMaintainableObject.sponsorCode') }
  action(:find_sponsor_code) { |b| b.frm.button(title: 'Search Sponsor').click }
  element(:principal_investigator_employee) { |b| b.frm.text_field(id: 'document.newMaintainableObject.person.userName') }
  action(:employee_lookup) { |b| b.frm.button(title: 'Search Principal Investigator (Employee)').click }
  element(:principal_investigator_non_employee) { |b| b.frm.text_field(id: 'document.newMaintainableObject.rolodexId') }
  value(:pi_full_name) { |b| b.noko.span(id: 'document.newMaintainableObject.person.fullName.div').text.gsub(/\W+$/,'').gsub('  ', ' ') }

  #Table for temporary proposal logs to be merged
  element(:temporary_proposal_log_table) { |b| b.merge_list.table }
  p_action(:proposal_number_row) { |number, b| b.temporary_proposal_log_table.row(text: /#{number}/) }
  p_action(:merge_proposal_log) { |number, b| b.frm.link(class: 'mergeLink', proposalnumber: number).click; b.loading }

  element(:merge_list) { |b| b.frm.div(id: 'proposalLogMergeList') }
  action(:cancel_merge) { |b| b.merge_list.link(class: 'cancel globalbuttons').click; b.loading }

end