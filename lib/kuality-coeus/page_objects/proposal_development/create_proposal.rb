class CreateProposal < BasePage

  buttons 'Cancel', 'Save and continue'
  #selects 'Unit Number', 'Activity Type'
  select(:proposal_type, :name, 'document.developmentProposal.proposalTypeCode')
  select(:unit_number, :name, 'document.developmentProposal.ownedByUnitNumber')
  select(:activity_type, :name, 'document.developmentProposal.activityTypeCode')


  element(:project_start_date) { |b| b.text_field(name: 'document.developmentProposal.requestedStartDateInitial') }
  element(:project_end_date) { |b| b.text_field(name: 'document.developmentProposal.requestedEndDateInitial') }
  element(:project_title) { |b| b.textarea(name: 'document.developmentProposal.title') }

  element(:sponsor_code) { |b| b.text_field(name: 'document.developmentProposal.sponsorCode') }
  action(:lookup_sponsor) { |b| b.button(data_onclick: %|showLookupDialog("uk9itv5_quickfinder_act",true,"Uif-DialogGroup-Lookup");|).click }

end