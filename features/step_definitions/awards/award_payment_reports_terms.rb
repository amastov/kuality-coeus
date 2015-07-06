When /I? ?adds? a report to the Award$/ do
  @award.add_report
end

When /adds (\d+) reports to the Award$/ do |x|
  x.to_i.times{ @award.add_report }
end

And /adds a nonrandom report to the Award/ do
  @award.add_report class:  'Financial',
      type:                 'Final (Final Report)',
      frequency:            'Annual',
      frequency_base:       'As Required',
      osp_file_copy:        'Report'
end

When /I? ?adds? Terms to the Award$/ do
  @award.add_terms
end

When /I? ?adds? nonrandom Terms to the Award$/ do
  @award.add_terms     equipment_approval:  1,
                       invention:           3,
                       prior_approval:      4,
                       property:            6,
                       publication:         14,
                       referenced_document: 15,
                       rights_in_data:      29,
                       subaward_approval:   19,
                       travel_restrictions: 5
end

Given /I? ?add a Payment & Invoice item to the Award$/ do
  @award.add_payment_and_invoice
end

When /^I start adding a Payment & Invoice item to the Award$/ do
  @award.view :payment_reports__terms
  on PaymentReportsTerms do |page|
    r = '::random::'
    page.expand_all
    page.payment_basis.pick r
    page.payment_method.pick r
    page.payment_type.pick r
    page.frequency.pick r
    page.frequency_base.pick r
    page.osp_file_copy.pick r
    page.add_payment_type
  end
end

Given /add a nonrandom Payment & Invoice item to the Award$/ do
  @award.add_payment_and_invoice payment_basis: 'Fixed price',
    payment_method: 'Special Handling',
    payment_and_invoice_requirements: { payment_type: 'KFS Invoicing',
                                        frequency: 'Annual',
                                        frequency_base: 'As Required',
                                        osp_file_copy: 'Report' },
    invoice_instructions: 'This is a SMOKE TEST'
end


And /adds an item of approved equipment to the Award$/ do
  @award.add_approved_equipment
  on(PaymentReportsTerms).save
end

And /adds a duplicate item of approved equipment to the Award$/ do
  ae = @award.approved_equipment[0]
  @award.add_approved_equipment item: ae.item, vendor: ae.vendor, model: ae.model
end