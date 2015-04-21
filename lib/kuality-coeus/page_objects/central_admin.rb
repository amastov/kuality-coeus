class CentralAdmin < BasePage

  page_url "#{$base_url+$context}portal.do?selectedTab=portalCentralAdminBody"

  #black buttons gives you the search ':search_award' and the create ':create_award'
  black_buttons proposal_development: 'Proposal Development', proposal_log: 'Proposal Log',
                institutional_proposal: 'Institutional Proposal',
                negotiations: 'Negotiations', award: 'Award', subaward: 'Subawards',
                animals: 'Animals', human_participants: 'Human Participants',
                irb_committee: 'IRB Committee', iacuc_committee: 'IACUC Committee'

  links 'IRB Schedules', 'IACUC Schedules'

  element(:central_admin_modal) { |b| b.link(text: 'CENTRAL ADMIN').parent.div }
  element(:create_icon_for) { |text, b| b.central_admin_modal.p(text: text).parent.link(class: 'uif-actionLink uif-boxLayoutHorizontalItem icon-plus icon-plus') }

end