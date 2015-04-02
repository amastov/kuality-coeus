class SponsorTemplateObject < DataFactory

  include StringFactory, DateFactory, Navigation, DocumentUtilities

  attr_reader :document_id, :status, :description, :template_description, :template_status, :payment_basis,
              :payment_method, :find_sponsor_term

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        description:          random_alphanums,
        template_description: random_alphanums,
        template_status:      '::random::',
        payment_basis:        'Cost reimbursement',
        payment_method:       'Advanced payment invoice',

    }
    set_options(defaults.merge(opts))
  end

  def create
    visit(Maintenance).sponsor_template
    on(SponsorTemplateLookup).create
    on SponsorTemplate do |add|
      @document_id=add.document_id
      @status=add.document_status
      add.expand_all
      fill_out add, :description, :template_description, :template_status, :payment_basis, :payment_method
    end

    set_sponsor_terms
    on SponsorTemplate do |add|
    end
    #This currently is only used to create the error messages will need to be improved when tests require valid sponsor templates
    set_sponsor_terms
    on SponsorTemplate do |add|
      add.submit
    end
  end

  # =========
  private
  # =========

  def set_sponsor_terms
    on(SponsorTemplate).find_sponsor_term
    # This SponsorTermLookup shows results with checkboxes and
    # is not the same as the lookup on the Maintence => Sponsor Terms link
    on SponsorTermLookup do |look|
      look.search
      look.return_random_checkbox if :sponsor_term == '::random::'
      look.return_selected
    end
  end

end #SponsorTemplateObject
