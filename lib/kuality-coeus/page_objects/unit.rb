class Unit < BasePage

  page_url "#{$base_url}selectedTab=portalUnitBody"

  action(:add_proposal_development) { |b| b.link(title: "Proposal Development", index: 0).click }

end