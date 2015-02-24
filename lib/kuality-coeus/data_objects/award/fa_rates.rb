class AwardFARatesObject < DataFactory

  include DateFactory, StringFactory

  attr_reader :rate, :type, :fiscal_year, :start_date, :end_date,
              :campus, :source, :destination, :unrecovered_fa

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        rate:           VALID_RATES.sample,
        type:           '::random::',
        fiscal_year:    date_factory(Time.random(year_range: 500))[:year],
        campus:         '::random::',
        source:         random_alphanums_plus,
        destination:    random_alphanums_plus,
        unrecovered_fa: random_dollar_value(99999)
    }
    set_options(defaults.merge(opts))
  end

  def create
    # Currently navigation is handled by the AwardObject
    on Commitments do |page|
      page.expand_all
      page.new_rate.fit @rate
      page.new_rate_type.pick! @type
      page.new_rate_fiscal_year.fit @fiscal_year
      if @start_date
        page.new_rate_start_date.set @start_date
        page.new_rate_end_date.set @end_date
      else
        page.new_rate_fiscal_year.fire_event 'onblur'
        sleep 1.5
        x = 0
        while page.new_rate_start_date.value == ''
          page.new_rate_fiscal_year.fire_event 'onblur'
          sleep 1.5
          x+=1
          raise 'The Date Fields are not auto-populating!' if x==10
        end
        @start_date=page.new_rate_start_date.value
        @end_date=page.new_rate_end_date.value
      end
      page.new_rate_source.fit @source
      page.new_rate_campus.pick! @campus
      page.new_rate_destination.fit @destination
      page.new_rate_unrecovered_fa.fit @unrecovered_fa
      # Added this line for testing a blank start date field...
      page.new_rate_start_date.clear if @start_date==''
      page.add_rate
      # Note: This line may have unintended consequences...
      page.save unless page.errors.size > 0
    end
  end

  private

  VALID_RATES = %w{0 10 11.11 12 13.3 14 15 17 17.8 18 19 20 25 40.7 999.99}

end

class AwardFARatesCollection < CollectionsFactory

  contains AwardFARatesObject

end