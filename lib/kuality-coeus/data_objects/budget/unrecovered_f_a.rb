class UnrecoveredFAObject < DataFactory

  include StringFactory, DateFactory

  attr_reader :fiscal_year, :applicable_rate, :campus, :source_account, :amount,
              # Note: Numbering is based on the number in the table!
              :number

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
      fiscal_year: right_now[:year]
    }
    set_options(defaults.merge(opts))
  end

  def create
    view
    on UnrecoveredFandA do |page|
      page.expand_all
      # TODO (obviously)
    end
  end

  def view
    # Note: Currently assumes we're already viewing
    # the budget document!
    on(BudgetSidebar).unrecovered_fna
  end

  def edit(opts)
    view
    on UnrecoveredFandA do |page|
      edit_item_fields opts, @number, page, :fiscal_year, :applicable_rate, :campus
      page.fa_source_account(@number).fit opts[:source_account]
      page.fa_amount(@number).fit opts[:amount]
      page.save
    end
    update_options(opts)
  end

  def update_from_parent(period_number)
    @period_number=period_number
  end

end

class UnrecoveredFACollection < CollectionsFactory

  contains UnrecoveredFAObject

  #TODO: Write code that will update indexes when items change their order in the list.

  def total_allocated
    self.collect{ |fa| fa.amount.to_f}.inject(0, :+)
  end

end