class NonPersonnelCost < DataFactory

  include StringFactory

  attr_reader :category_type, :category_code, :object_code_name, :total_base_cost,
              :cost_sharing, :start_date, :end_date, :rates, :apply_inflation, :submit_cost_sharing,
              :on_campus, :ird,
              #TODO someday:
              :quantity, :description # These don't seem to do anything, really
  attr_accessor :participants

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
      category_type:    '::random::',
      object_code_name: '::random::',
      total_base_cost:  random_dollar_value(1000000),
      ird:              []
    }

    set_options(defaults.merge(opts))
    requires :period_rates
  end

  def create
    # Navigation is handled by the Budget Period object
    on(NonPersonnelCosts).assign_non_personnel
    if @browser.header(id: 'PropBudget-ConfirmPeriodChangesDialog_headerWrapper').present?
      on(ConfirmPeriodChanges).yes
    end
    on AddAssignedNonPersonnel do |page|
      page.category.pick! @category_type
      page.loading
      fill_out page, :object_code_name, :total_base_cost
      page.add_non_personnel_item
    end
    add_participants if @participants
  end

  def edit opts={}
    # Method assumes we're already in the right place
    on(NonPersonnelCosts).details_of @object_code_name
    on EditAssignedNonPersonnel do |page|
      @start_date ||= page.start_date.value
      @end_date ||= page.end_date.value

      edit_fields opts, page, :apply_inflation, :submit_cost_sharing,
                  :start_date, :end_date, :on_campus
      opts[:on_campus] |= page.on_campus.set?
      opts[:apply_inflation] |= page.apply_inflation.set?
      opts[:submit_cost_sharing] |= page.submit_cost_sharing.set?
      page.cost_sharing_tab
      edit_fields opts, page, :cost_sharing
      # Note: code order is a little unusual, here, but necessary in order
      # to get the right collection of rates for the item...
      page.details_tab
      # Grab the inflation rate descriptions for reference (they're used in #get_rates)...
      @ird = page.inflation_rates.map { |r| r[:description] }.uniq
      update_options opts
      get_rates
      page.save_changes
    end
  end

  # Used when the category type is 'Participant Support'
  def add_participants
    @participants ||= rand(9)+1
    on(NonPersonnelCosts).edit_participant_count
    on Participants do |page|
      page.number_of_participants.set @participants
      page.save_changes
    end
  end

  def sync_to_period_dc_limit
    # Method assumes we're already in the right place
    on(NonPersonnelCosts).details_of @object_code_name
    on EditAssignedNonPersonnel do |page|
      page.sync_to_period_direct_cost_limit
      on(SyncDirectCostLimit).yes
      page.save_changes
    end
  end

  def daily_total_base_cost
    @total_base_cost.to_f/total_days
  end

  def daily_cost_share
    @cost_sharing.to_f/total_days
  end

  def start_date_datified
    Utilities.datify @start_date
  end

  def end_date_datified
    Utilities.datify @end_date
  end

  def total_days
    (end_date_datified-start_date_datified).to_i+1
  end

  def rate_cost_sharing
    rate_cost_shares = []
    @rates.find_all { |r| r.rate_class_type=='F & A'}.each { |rate|
      rate_cost_shares << rate_days(rate)*daily_cost_share*(rate.applicable_rate/100)
    }
    rate_cost_shares.inject(:+)
  end

  def rate_days(rate)
    # We know the rate applies, at least partially, because it hasn't been eliminated, so no need to
    # check date range again...
    # Determine which start date is later...
    strt = rate.start_date > start_date_datified ? rate.start_date : start_date_datified
    # Determine which end date is earlier...
    end_d = rate.end_date > end_date_datified ? end_date_datified : rate.end_date
    # Now count the days between them...
    (end_d - strt).to_i+1
  end

  def inflation_amount
     if Transforms::TRUE_FALSE[@apply_inflation]
       subtotals = [0.0]
       @rates.inflation.each do |inflation_rate|
         subtotals << daily_total_base_cost*(inflation_rate.applicable_rate/100)*rate_days(inflation_rate)
       end
       subtotals.inject(:+)
     else
       0.0
     end
  end

  def get_rates
    @rates = @period_rates.non_personnel.in_range(start_date_datified, end_date_datified)
    if @on_campus != nil
      @rates.delete_if { |r| r.on_campus != Transforms::YES_NO[@on_campus] }
    end
    @rates.delete_if { |r| r.rate_class_type=='Inflation' && !@ird.include?(r.description) }
  end

  def copy_mutatis_mutandis opts={}
    self.instance_variables.each do |var|
      key = var.to_s.gsub('@','').to_sym
      if opts[key].nil?
        orig_val = instance_variable_get var
        opts[key] = case
                    when orig_val.instance_of?(BudgetRatesCollection)
                      nil
                    when orig_val.instance_of?(Array) || orig_val.instance_of?(Hash)
                      Marshal::load(Marshal.dump(orig_val))
                    else
                      orig_val
                    end
      end
    end
    self.class.new(@browser, opts)
  end

end

class NonPersonnelCostsCollection < CollectionFactory

  contains NonPersonnelCost

  # NOTE: This method is written assuming that there's only one item
  # with this category type in the collection...
  def category_type(category_type)
    self.find { |np_item| np_item.category_type==category_type }
  end

end