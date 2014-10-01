class OpportunitySearch < BasePage

  # TODO: Elements in this class are going to require modification due to
  # a containing iframe...

  select(:search_domanin, :name, 'lookupCriteria[providerCode]')
  element(:opportunity_id) { |b| b.iframe.text_field(name: 'lookupCriteria[opportunityId]') }
  
end