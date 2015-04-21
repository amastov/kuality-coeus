# coding: UTF-8
class PaymentInvoiceObject < DataFactory

  include Navigation, DateFactory, StringFactory

  attr_reader :payment_basis, :payment_method, #:document_funding_id,
              :payment_and_invoice_requirements, :award_payment_schedule,
              :invoice_instructions

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        payment_basis:   '::random::',
        payment_method:  '::random::',
        payment_and_invoice_requirements:
            # Dangerously close to needing to be a Data Object proper...
            { payment_type: '::random::',
              frequency: '::random::',
              frequency_base: '::random::',
              osp_file_copy: '::random::' },
        invoice_instructions: random_multiline(50, 5, :string)
    }
    set_options(defaults.merge(opts))
  end

  def create
    on PaymentReportsTerms do |page|
      page.expand_all
      page.payment_basis.pick! @payment_basis
      page.payment_basis.fire_event('onchange')

      page.payment_method.wait_until_present

      page.payment_method.pick! @payment_method
      page.payment_type.pick! @payment_and_invoice_requirements[:payment_type]
      page.payment_type.fire_event('onchange')
      page.frequency.pick! @payment_and_invoice_requirements[:frequency]
      page.frequency.fire_event('onchange')
      if @payment_and_invoice_requirements[:frequency]=='None' && @payment_and_invoice_requirements[:frequency_base]=='::random::'
        @payment_and_invoice_requirements[:frequency_base]=nil
      else
        page.frequency_base.pick! @payment_and_invoice_requirements[:frequency_base]
        page.frequency_base.fire_event('onchange')
      end
      page.osp_file_copy.pick! @payment_and_invoice_requirements[:osp_file_copy]
      page.add_payment_type

     #removed looping as it was causing element to separate from the DOM

      fill_out page, :invoice_instructions
    page.save
    end
  end

  def add_payment_type(payment_type='::random::') # TODO: Add support for other payment fields...
    on PaymentReportsTerms do |page|
      page.expand_all
      page.payment_type.pick! payment_type
      page.add_payment_type
      page.save
    end
    @payment_and_invoice_requirements << {payment_type: payment_type}
  end

end