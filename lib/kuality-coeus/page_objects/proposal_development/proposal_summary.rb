class ProposalSummary < BasePage

  links 'Proposal Summary', 'Personnel', 'Credit Allocation', 'Questionnaire', 'Supplemental Info',
        'View Route Log', 'More Actions', 'Compliance', 'Attachments', 'Keywords'
  buttons 'Submit for Review', 'Approve', 'Disapprove', 'Reject', 'Recall', 'Submit to Sponsor'

  value(:messages) { |b| b.no_frame_noko.lis(class: 'uif-infoMessageItem').map{|li| li.text} }

end