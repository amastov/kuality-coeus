class ProposalSidebar < BasePage
                                                      # FIXME!
  action(:basics) { |b| b.span(text: 'Basics').click; sleep 1 }
  element(:proposal_details_link) { |b| b.link(name: 'PropDev-DetailsPage') }
  action(:proposal_details) { |b| b.basics unless b.proposal_details_link.present?; b.proposal_details_link.click; b.loading }
  action(:s2s_opportunity_search) { |b| b.link(name: 'PropDev-OpportunityPage').click; b.loading }
  action(:delivery_info) { |b| b.link(name: 'PropDev-DeliveryInfoPage').click; b.loading }
  action(:sponsor_and_program_info) { |b| b.link(name: 'PropDev-SponsorProgramInfoPage').click; b.loading }
  action(:organization_and_location) { |b| b.link(name: 'PropDev-OrganizationLocationsPage').click; b.loading }
                                                                    # FIXME!
  action(:key_personnel) { |b| b.span(text: 'Key Personnel').click; sleep 1 }
  action(:personnel) { |b| b.key_personnel unless b.credit_allocation_link.present?; b.link(name: 'PropDev-PersonnelPage').click; b.loading }
  element(:credit_allocation_link) { |b| b.link(name: 'PropDev-CreditAllocationPage') }
  action(:credit_allocation) { |b| b.key_personnel unless b.credit_allocation_link.present?; b.credit_allocation_link.click; b.loading }
  action(:compliance) { |b| b.span(text: 'Compliance').click; b.loading }
  action(:attachments) { |b| b.span(text: 'Attachments').click; b.loading }
  action(:questionnaire) { |b| b.span(text: 'Questionnaire').click; b.loading }
  action(:budget) { |b| b.link(name: 'PropDev-BudgetPage').click; b.loading }
  action(:access) { |b| b.span(text: 'Access').click; b.loading }
  action(:supplemental_information) { |b| b.span(text: 'Supplemental Information').click; b.loading }
  action(:summary_submit) { |b| b.span(text: 'Summary/Submit').click; b.loading }

end