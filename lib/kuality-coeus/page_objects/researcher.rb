class ResearcherMenu < BasePage

  links 'Create Proposal', 'All My Proposals', 'All My Schedules', 'Search Proposals', 'Create IRB Protocol', 'Search Proposal Log',
        'Search Institutional Proposals', 'Create IACUC Protocol'

  action(:iacuc_search_protocols) { |b| b.h3(text: 'IACUC Protocols').parent.link(text: 'Search Protocols').click }
end