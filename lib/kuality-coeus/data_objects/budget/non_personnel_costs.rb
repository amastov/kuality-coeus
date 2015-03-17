class NonPersonnelCost < DataFactory

  include StringFactory

  attr_reader :category_type, :category_code, :object_code_name, :total_base_cost,
              :cost_sharing, :start_date, :end_date, :rates, :apply_inflation, :submit_cost_sharing,
              :on_campus,
              #TODO someday:
              :quantity, :description # These don't seem to do anything, really
  attr_accessor :participants

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
      category_type:    '::random::',
      object_code_name: '::random::',
      total_base_cost:  random_dollar_value(1000000),
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
      page.save_changes
    end
    update_options opts
    get_rates

    DEBUG.inspect @category_type
    DEBUG.inspect @object_code_name
    DEBUG.inspect inflation_rates
    exit

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

  def get_rates
    @rates = @period_rates.non_personnel.in_range(start_date_datified, end_date_datified)
    if @on_campus != nil
      @rates.delete_if { |r| r.on_campus != Transforms::YES_NO[@on_campus] }
    end
  end

  def inflation_rates
    inf = @rates.inflation
    rat = []
    unless inf.empty?
      rat = inf.find_all { |r| r.description =~ /#{@category_type}/i }
    end
    rat.empty? ? inf : rat
  end

end

class NonPersonnelCostsCollection < CollectionFactory

  contains NonPersonnelCost

end