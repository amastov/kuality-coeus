class BudgetPeriodObject < DataFactory

  include StringFactory, Utilities

  attr_reader :start_date, :end_date, :total_sponsor_cost,
              :direct_cost, :f_and_a_cost, :unrecovered_f_and_a,
              :cost_sharing, :cost_limit, :direct_cost_limit, :datified,
              :budget_name, :cost_sharing_distribution_list, :unrecovered_fa_dist_list,
              :participant_support, :assigned_personnel, :non_personnel_costs
              #TODO: Add support for this:
              :number_of_participants
  attr_accessor :number

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
      cost_sharing_distribution_list: collection('CostSharing'),
      unrecovered_fa_dist_list:       collection('UnrecoveredFA'),
      participant_support:            collection('ParticipantSupport'),
      assigned_personnel:             collection('AssignedPersonnel'),
      non_personnel_costs:            collection('NonPersonnelCosts')
    }

    set_options(defaults.merge(opts))
    requires :start_date, :open_budget
    @datified = Utilities.datify @start_date
    add_cost_sharing @cost_sharing
  end

  def create
    view 'Periods And Totals'
    on(PeriodsAndTotals).add_budget_period
    on AddBudgetPeriod do |create|
      # TODO!
    end
    initialize_unrecovered_fa @unrecovered_f_and_a
  end

  def edit opts={}
    view :periods_and_totals
    on PeriodsAndTotals do |edit|
      edit.edit_period @number unless edit.start_date_of(@number).present?
      edit.start_date_of(@number).fit opts[:start_date]
      edit.end_date_of(@number).fit opts[:end_date]
      dollar_fields.each do |field|
        edit.send("#{field}_of", @number).fit opts[field]
      end
      edit.save_period @number
      if opts.keys.include?(:start_date) || opts.keys.include?(:end_date)
        on(ChangePeriod).yes
      end
      # TODO: This is probably not going to work any more. Fix it!
      return if edit.errors.size > 0
    end
    @datified = Utilities.datify @start_date
    add_cost_sharing opts[:cost_sharing]
    initialize_unrecovered_fa opts[:unrecovered_f_and_a]
    set_options(opts)
  end

  def view(tab)
    @open_budget.call
    on(BudgetSidebar).send(damballa(tab.to_s))
  end

  # TODO: All this code is problematic when there are multiple
  # Project periods. It needs some serious re-thinking for 6.0
  def add_item_to_cost_sharing_dl opts={}
    defaults = {
        amount: random_dollar_value(10000),
        period: "#{@number}: #{@start_date} - #{@end_date}"
    }
    @open_budget.call
    @cost_sharing_distribution_list.add defaults.merge(opts)
  end

  def assign_person opts={}
    view :assign_personnel
    on(AssignPersonnelToPeriods) do |page|
      page.view_period @number
      page.assign_personnel @number
    end
    @assigned_personnel.add opts
  end

  def assign_non_personnel_cost opts={}
    view :non_personnel_costs
    on(NonPersonnelCosts).view_period @number
    @non_personnel_costs.add opts
  end

  def add_participant_support opts={}
    # TODO: Navigation here
    @participant_support.add opts
  end

  def delete
    view 'Periods And Totals'
    on(PeriodsAndTotals).delete_period(@number)
  end

  def get_dollar_field_values
    view 'Periods And Totals'
    on PeriodsAndTotals do |page|
      page.edit_period @number
      dollar_fields.each do |field|
        set(field, page.send("#{field}_of", @number).value)
      end
    end
  end

  def dollar_fields
    [:total_sponsor_cost, :direct_cost, :f_and_a_cost, :unrecovered_f_and_a,
                   :cost_sharing, :cost_limit, :direct_cost_limit]
  end

  # =======
  private
  # =======

  def add_cost_sharing(cost_sharing)
    if @cost_sharing_distribution_list.empty? && !cost_sharing.nil? && cost_sharing.to_f > 0
      cs = make CostSharingObject, period: "#{@number}: #{@start_date} - #{@end_date}",
                amount: cost_sharing, source_account: ''
      @cost_sharing_distribution_list << cs
    end
  end

  def initialize_unrecovered_fa unrec_fa
    if @unrecovered_fa_dist_list.empty? && !unrec_fa.nil? && unrec_fa.to_f > 0
      on(BudgetSidebar).unrecovered_fna
      on UnrecoveredFandA do |page|
        page.fna_rows.each do |row|
          fna_item = make UnrecoveredFAObject, number: row[0].text, fiscal_year: row[1].text_field.value,
                          applicable_rate: row[2].text_field.value, campus: row[3].select.selected_options[0].text,
                          source_account: row[4].text_field.value, amount: row[5].text_field.value
          @unrecovered_fa_dist_list << fna_item
        end
      end
    end
  end

end # BudgetPeriodObject

class BudgetPeriodsCollection < CollectionsFactory

  contains BudgetPeriodObject

  def period(number)
    self.find { |period| period.number==number.to_i }
  end

  # This will update the number values of the budget periods,
  # based on their start date values.
  def number!
    self.sort_by! { |period| period.datified }
    self.each_with_index { |period, index| period.number=index+1 }
  end

  def total_sponsor_cost
    self.collect{ |period| period.total_sponsor_cost.to_f }.inject(0, :+)
  end



end # BudgetPeriodsCollection