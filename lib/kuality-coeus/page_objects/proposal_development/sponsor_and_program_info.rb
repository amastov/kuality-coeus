class SponsorAndProgram < BasePage
  
  document_buttons
  new_error_messages

  element(:sponsor_deadline_date) { |b| b.text_field(name: 'document.developmentProposal.deadlineDate') }
  element(:sponsor_deadline_time) { |b| b.text_field(name: 'document.developmentProposal.deadlineTime') }
  element(:sponsor_deadline_type) { |b| b.select(name: 'document.developmentProposal.deadlineType') }
  element(:notice_of_opportunity) { |b| b.select(name: 'document.developmentProposal.noticeOfOpportunityCode') }
  element(:opportunity_id) { |b| b.text_field(name: 'document.developmentProposal.programAnnouncementNumber') }
  element(:cfda_number) { |b| b.text_field(name: 'document.developmentProposal.cfdaNumber') }
  element(:proposal_includes_subawards) { |b| b.checkbox(name: 'document.developmentProposal.subcontracts') }
  element(:sponsor_proposal_id) { |b| b.text_field(name: 'document.developmentProposal.sponsorProposalNumber') }
  element(:nsf_science_code) { |b| b.select(name: 'document.developmentProposal.nsfCode') }
  element(:anticipated_award_type) { |b| b.select(name: 'document.developmentProposal.anticipatedAwardTypeCode') }
  element(:opportunity_title) { |b| b.textarea(name: 'document.developmentProposal.programAnnouncementTitle') }

  # Because the NSF Science Code select list is long, we have this
  # Nokogiri code here, which returns the list much faster than Watir does.
  # This enables, for example, a faster randomized item selection from the list...
  value(:science_codes) { |b| b.no_frame_noko.select(name: 'document.developmentProposal.nsfCode').options.map {|opt| opt.text }[1..-1] }

end