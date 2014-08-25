class SponsorLookup < Lookups

  element(:frm) { |b| b.frame(class: 'uif-iFrame uif-lookupDialog-iframe') }

  expected_element :sponsor_name

  new_ui

  element(:sponsor_name) { |b| b.frm.text_field(name: 'lookupCriteria[sponsorName]') }
  element(:sponsor_type_code) { |b| b.select(name: 'lookupCriteria[sponsorTypeCode]') }
  element(:page_links) { |b| b.frm.links(tabindex: '0') }

  p_value(:sponsor_code_of) { |name, b| b.item_row(name).link(title: /Sponsor Code=/).text }

end

class OLDSponsorLookup < Lookups

  old_ui

  element(:sponsor_name) { |b| b.frm.text_field(id: 'sponsorName') }
  element(:sponsor_type_code) { |b| b.frm.select(id: 'sponsorTypeCode') }
  element(:page_links) { |b| b.frm.span(class: 'pagelinks').links }

  action(:get_sponsor_code) { |name, b| b.item_row(name).link(title: /Sponsor Code=/).text }

end