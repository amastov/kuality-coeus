class Committee < CommitteeDocument

  document_header_elements
  committee_header_elements

  element(:description) { |b| b.text_field(id: "document.documentHeader.documentDescription") }
  element(:committee_id) { |b| b.text_field(id: "document.committeeList[0].committeeId") }
  element(:committee_name) { |b| b.text_field(id: "document.committeeList[0].committeeName") }
  element(:home_unit) { |b| b.text_field(id: "document.committeeList[0].homeUnitNumber") }
  element(:min_members_for_quorum) { |b| b.text_field(id: "document.committeeList[0].minimumMembersRequired") }
  element(:maximum_protocols) { |b| b.text_field(id: "document.committeeList[0].maxProtocols") }
  element(:adv_submission_days) { |b| b.text_field(id: "document.committeeList[0].advancedSubmissionDaysRequired") }
  element(:review_type) { |b| b.select(id: "document.committeeList[0].reviewTypeCode") }
  value(:last_updated) { |p| p.com_table.row(text: /Last Updated:/).cell(index: -1).text }
  value(:updated_user) { |p| p.com_table.row(text: /Updated User:/).cell(index: -1).text }

  private

  element(:com_table) { |b| b.div(id: "tab-Committee-div").table }

end