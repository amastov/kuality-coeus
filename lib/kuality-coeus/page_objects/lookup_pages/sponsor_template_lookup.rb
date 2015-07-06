class SponsorTemplateLookup < Lookups

  old_ui

  element(:sponsor_template_code) { |b| b.frm.text_field(name: 'templateCode') }

  element(:description) { |b| b.frm.text_field(name: 'description') }
  element(:sponsor_template_status) { |b| b.frm.select(name: 'statusCode') }
  element(:prime_sponsor_code) { |b| b.frm.text_field(name: 'primeSponsorCode') }
  element(:payment_basis) { |b| b.frm.select(name: 'basisOfPaymentCode') }
  element(:payment_method) { |b| b.frm.select(name: 'methodOfPaymentCode') }

end