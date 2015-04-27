class NonPersonnelCost < DataFactory

  include StringFactory

  attr_reader :category_type, :category_code, :object_code_name, :total_base_cost,
              :cost_sharing, :start_date, :end_date, :rates, :apply_inflation, :submit_cost_sharing,
              :on_campus, :ird, :apply_indirect_rates,
              #TODO someday:
              :quantity, :description # These don't seem to do anything, really
  attr_accessor :participants

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
      category_type:        '::random::',
      object_code_name:     '::random::',
      total_base_cost:      random_dollar_value(1000000).to_f,
      cost_sharing:         0.0,
      ird:                  [],
      on_campus:            'Yes',
      apply_inflation:      'Yes',
      submit_cost_sharing:  'Yes',
      apply_indirect_rates: 'Yes'
    }

    set_options(defaults.merge(opts))
    # Requiring the start and end dates is an artifact of the
    # system UI, which does not include the dates on the Add screen.
    # This means that if you simply add an item then when you try to
    # copy it later the data object will not have "seen" the dates for the item.
    # If in the future this unusual UI configuration is changed, this code can be
    # improved...
    requires :period_rates, :start_date, :end_date
    get_rates
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
      #FIXME!
      sleep 1
      # This is needed here because the object code name select list can be very large.
      # When a select list is too large then Watir is very slow parsing its contents.
      # This line bypasses Watir in favor of using nokogiri to parse the HTML and get
      # the list of options.
      if @object_code_name=='::random::'
        @object_code_name=page.object_code_list.shuffle.sample
      end
      fill_out page, :object_code_name, :total_base_cost
      page.add_non_personnel_item
    end
    add_participants if @participants
  end

  def edit opts={}
    # Method assumes we're already in the right place
    on(NonPersonnelCosts).details_of @object_code_name
    on EditAssignedNonPersonnel do |page|
      edit_fields opts, page, :apply_inflation, :submit_cost_sharing,
                  :start_date, :end_date, :on_campus, :total_base_cost
      page.cost_sharing_tab
      edit_fields opts, page, :cost_sharing
      # Note: code order is a little unusual, here, but necessary in order
      # to get the right collection of rates for the item...
      page.details_tab
      # Grab the inflation rate descriptions for reference (they're used in #get_rates)...
      @ird = page.inflation_rates.map { |r| r[:description] }.uniq
      @overhead = page.rates_table.exist?
      if @overhead && !opts[:apply_indirect_rates].nil?
        page.rates_tab
        page.apply(@rates.f_and_a[0].rate_class_code, @rates.f_and_a[0].description).fit opts[:apply_indirect_rates]
      end
      update_options opts
      get_rates
      if opts[:save_type].nil?
        page.save_changes
      else
        page.send(opts[:save_type])
      end
    end
  end

  def delete
    # Method assumes we're already in the right place
    on(NonPersonnelCosts) do |page|
      page.trash @object_code_name
      page.save
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
  
  def sync_to_period_c_limit
    # Method assumes we're already in the right place
    on(NonPersonnelCosts).details_of @object_code_name
    on EditAssignedNonPersonnel do |page|
      page.sync_to_period_cost_limit
      on(SyncPeriodCostLimit).yes
      page.save_changes
    end
  end

  def save_and_apply_to_later
    on(NonPersonnelCosts).details_of @object_code_name
    on EditAssignedNonPersonnel do |page|
      page.save_and_apply_to_other_periods
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

  def f_and_a
    calc_cost(daily_total_base_cost)
  end

  def f_and_a_cost_sharing
    calc_cost(daily_cost_share)
  end

  def inflation_amount
     if Transforms::TRUE_FALSE[@apply_inflation]
       @total_base_cost.to_f*inflation_rate
     else
       0.0
     end
  end

  def inflation_rate
    @rates.inflation.empty? ? 0.0 : @rates.inflation[0].applicable_rate/100
  end

  def calc_tbc
    @total_base_cost = @total_base_cost.to_f
    @total_base_cost+=inflation_amount
  end

  def get_rates
    @rates = @period_rates.non_personnel.in_range(start_date_datified, end_date_datified)
    @rates.delete_if { |r| r.on_campus != Transforms::YES_NO[@on_campus] }
    @rates.delete_if { |r| r.rate_class_type=='Inflation' && !@ird.include?(r.description) }
    @rates.delete_if { |r| r.rate_class_type=='Inflation' && start_date_datified < r.start_date }
    @rates.delete_if { |r| r.rate_class_type == 'F & A' && @overhead==false }
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
    npc = self.class.new(@browser, opts)
    npc.get_rates
    npc.calc_tbc
    npc
  end

  private

  def calc_cost(cost_type)
    amounts = []
    fna = @rates.f_and_a
    if fna.count==1
      amounts << @total_base_cost*(fna[0].applicable_rate/100)
    else
      fna.each { |rate|
        amounts << rate_days(rate)*cost_type*(rate.applicable_rate/100)
      } unless fna.empty?
    end
    amounts.inject(0, :+)
  end

end

class NonPersonnelCostsCollection < CollectionFactory

  contains NonPersonnelCost

  def direct
    self.collect{ |npc| npc.total_base_cost.to_f }.inject(0, :+)
  end

  def f_and_a
    self.find_all{ |npc|
      Transforms::YES_NO[npc.apply_indirect_rates]=='Yes' }.
        collect{ |npc|
          npc.f_and_a }.
        inject(0, :+)
  end

  def unrecovered_f_and_a
    self.find_all{ |npc|
      Transforms::YES_NO[npc.apply_indirect_rates]=='No' }.
        collect{ |npc|
          npc.f_and_a }.
        inject(0, :+)
  end

  # NOTE: This method is written assuming that there's only one item
  # with this category type in the collection. If there's more than one then
  # this will return the first one...
  def category_type(category_type)
    self.find { |np_item| np_item.category_type==category_type }
  end

  # NOTE: This method is written assuming that there's only one item
  # with this object code in the collection...
  def object_code_name(obcdnm)
    self.find { |np_item| np_item.object_code_name==obcdnm }
  end

  # NOTE: This method is written assuming that there's only one item
  # with this object code in the collection...
  def delete(obcdnm)
    object_code_name(obcdnm).delete
    self.delete_if { |np_item| np_item.object_code_name==obcdnm }
  end

  # this method is basically for debugging purposes, as it gets rid of things
  # that we don't care about when examining contents of the collection...
  def details
    self.collect{ |npc|
      hash = {}
      [:category_type, :category_code, :object_code_name, :total_base_cost,
       :cost_sharing, :start_date, :end_date, :rates, :apply_inflation, :submit_cost_sharing,
       :on_campus, :f_and_a, :inflation_amount, :f_and_a_cost_sharing, :total_days, :daily_total_base_cost, :daily_cost_share].each{ |iv| hash.store(iv, npc.send(iv)) }
      hash
    }
  end

end