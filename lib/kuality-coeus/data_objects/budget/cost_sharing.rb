class CostSharingObject < DataFactory

  include StringFactory

  attr_reader :period, :percentage, :source_account, :amount

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        percentage:     '0.00',
        source_account: random_alphanums,
        amount:         '0.00'
    }
    set_options(defaults.merge(opts))
  end

  def create
    view
    on(CostSharing).add_cost_sharing
    on AddLine do |page|
      fill_out page, :period, :percentage, :source_account, :amount
      page.add
    end
  end

  def view
    # Note: Currently assumes we're already viewing
    # the budget document!
    on(BudgetSidebar).cost_sharing
  end

  def edit(opts)
    view
    on CostSharing do |page|
      page.period(@source_account, @amount).pick! opts[:period]
      page.percentage(@source_account, @amount).fit opts[:percentage]
      page.amount(@source_account, @amount).fit opts[:amount]
      # NOTE: This needs to be last so that the @source_account still matches for the
      # other three fields...
      page.source_account(@source_account, @amount).fit opts[:source_account]
      page.save
    end
    update_options(opts)
  end

end

class CostSharingCollection < CollectionsFactory

  contains CostSharingObject

  #TODO: Write code that will update indexes when items change their order in the list.

  def total_funds
    self.collect{ |cs| cs.amount.to_f}.inject(0, :+).round(2)
  end

end