class SponsorAndProgram < BasePage
  
  document_buttons

  element(:sponsor_deadline_date) { |b| b.text_field(name: 'document.developmentProposal.deadlineDate') }
  element(:sponsor_deadline_time) { |b| b.text_field(name: 'document.developmentProposal.deadlineTime') }
  select(:sponsor_deadline_type, :name, 'document.developmentProposal.deadlineType')
  select(:notice_of_opportunity, :name, 'document.developmentProposal.noticeOfOpportunityCode')
  element(:opportunity_id) { |b| b.text_field(name: 'document.developmentProposal.programAnnouncementNumber') }
  element(:cfda_number) { |b| b.text_field(name: 'document.developmentProposal.cfdaNumber') }
  element(:proposal_includes_subawards) { |b| b.checkbox(name: 'document.developmentProposal.subcontracts') }
  element(:sponsor_proposal_id) { |b| b.text_field(name: 'document.developmentProposal.sponsorProposalNumber') }
  select(:nsf_science_code, :name, 'document.developmentProposal.nsfCode')
  select(:anticipated_award_type, :name, 'document.developmentProposal.anticipatedAwardTypeCode')
  element(:opportunity_title) { |b| b.textarea(name: 'document.developmentProposal.programAnnouncementTitle') }

end