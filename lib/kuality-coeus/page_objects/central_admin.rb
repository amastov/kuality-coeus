class CentralAdmin < BasePage

  page_url "#{$base_url+$context}portal.do?selectedTab=portalCentralAdminBody"

  #TODO:: Remove this as it is old ui
  green_buttons create_award: 'Award', create_proposal_log: 'Proposal Log',
                create_institutional_proposal: 'Institutional Proposal', create_subaward: 'Subawards'

  element(:central_admin_modal) { |b| b.link(text: 'CENTRAL ADMIN').parent.div }

  element(:create_icon_for) { |text, b| b.central_admin_modal.p(text: text).parent.link(class: 'uif-actionLink uif-boxLayoutHorizontalItem icon-plus icon-plus') }

  action(:create_irb_committee) { |b| b.create_icon_for('IRB Committee').click }
  action(:create_iacuc_committee) { |b| b.create_icon_for('IACUC Committee').click }

end