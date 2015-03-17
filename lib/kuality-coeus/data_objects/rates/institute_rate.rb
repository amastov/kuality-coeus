class InstituteRateObject < DataFactory

  include StringFactory, DateFactory

  ACTIVITY_TYPES = {
    # Description                   # Code
      'Research'                   => '1',
      'Instruction'                => '2',
      'Public Service'             => '3',
      'Clinical Trial'             => '4',
      'Other'                      => '5',
      'Fellowship - Pre-Doctoral'  => '6',
      'Fellowship - Post-Doctoral' => '7',
      'Student Services'           => '8',
      'Construction'               => '9'
  }

  RATE_CLASS_TYPES = {
      'E' => 'Fringe Benefits',
      'I' => 'Inflation',
      'L' => 'Lab Allocation - Other',
      'O' => 'F & A',
      'V' => 'Vacation',
      'X' => 'Other',
      'Y' => 'Lab Allocation - Salaries'
  }

  RATE_CLASS_CODES = {
      'MTDC'                              => '1',
      'TDC'                               => '2',
      'S&W'                               => '3',
      'Employee Benefits'                 => '5',
      'Inflation'                         => '7',
  }

  RATE_TYPES = {
      'MTDC'=>{class: '1', type: '1'},
      'TDC'=>{class: '2', type: '2'},
      'S&W'=>{class: '3', type: '3'},
      'Salaries'=>{class: '5', type: '10'},
      'Salaries - Non-Classified: SalNC'=>{class: '5', type: '4'},
      'Salaries - Classified: SalClass'=>{class: '5', type: '5'},
      'Salaries - Graduate Assistants: SalGA'=>{class: '5', type: '6'},
      'Hourly - Employee/Non-Student: Wages'=>{class: '5', type: '7'},
      'Hourly - Enrolled Students: WagesSTU'=>{class: '5', type: '8'},
      'Salaries - Summer: SalSumAL'=>{class: '5', type: '9'},
      'Salaries-Non Student'=>{class: '7', type: '10'},
      'Tuition - GA'=>{class: '7', type: '11'},
      'Equipment'=>{class: '7', type: '12'},
      'Salaries-Student'=>{class: '7', type: '3'},
      'Domestic Travel'=>{class: '7', type: '7'},
      'Materials and Services'=>{class: '7', type: '4'}
  }

  attr_reader :activity_type, :activity_type_code, :fiscal_year, :on_off_campus_flag,
              :rate_type, :rate_class_code, :rate_type_code, :start_date, :unit_number,
              :rate, :active, :description, :save_type

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
      description: random_alphanums_plus,
      fiscal_year: right_now[:year],
      activity_type: 'Instruction',
      on_off_campus_flag: :set,
      rate_type: 'Salaries',
      unit_number: '000001',
      rate: "#{rand(9)+1}.#{rand(100)}",
      active: :set,
      save_type: :blanket_approve
    }

    set_options(defaults.merge(opts))
    @start_date ||= "01/01/#{@fiscal_year}"
    @activity_type_code = ACTIVITY_TYPES[@activity_type]
    @rate_class_code = RATE_TYPES[@rate_type][:class]
    @rate_type_code = RATE_TYPES[@rate_type][:type]
  end

  def create
    navigate
    on(InstituteRatesLookup).create_new
    on InstituteRatesMaintenance do |create|
      fill_out create, :description, :activity_type_code, :fiscal_year,
               :rate_class_code, :rate_type_code, :start_date, :unit_number,
               :rate, :on_off_campus_flag, :active
      create.send(@save_type)
    end
  end

  def exist?
    $users.admin.log_in if $current_user==nil
    navigate
    search
    if on(InstituteRatesLookup).results_table.present?
      return true
    else
      return false
    end
  end

  # This method...
  # - Breaks the CRUD model and the design pattern, but is necessary because of how the system
  #   restricts creation of rate records
  # - Assumes it doesn't need to navigate because it's being used
  #   in very specific places
  def get_current_rate
    on(InstituteRatesLookup).edit_item "#{@activity_type}.#{@fiscal_year}.+#{@rate_type}"
    @rate=on(InstituteRatesMaintenance).rate.value
  end

  # This method...
  # - Breaks the CRUD model and the design pattern, but is necessary because of how the system
  #   restricts creation of rate records
  # - Assumes it doesn't need to navigate  because it's being used
  #   in very specific places
  def activate
    @active=:set
    on InstituteRatesMaintenance do |edit|
      edit.active.send(@active)
      fill_out edit, :description
      edit.blanket_approve
    end
  end

  def delete
    navigate
    search
    on(InstituteRatesLookup).delete_item "#{@rate_type}"
    on InstituteRatesMaintenance do |del|
      del.description.set @description
      del.blanket_approve
    end
  end

  def search
    on InstituteRatesLookup do |look|
      fill_out look, :activity_type_code, :fiscal_year, :rate_class_code,
               :rate_type_code, :unit_number
      look.on_off_campus campus_lookup[@on_off_campus_flag]
      look.active('both')
      look.search
    end
  end

  # =========
  private
  # =========

  def navigate
    # TODO: Throw some conditional logic in here so that we don't navigate every time.
    visit Maintenance do |page|
      page.close_parents
      page.institute_rate
    end
  end

  def campus_lookup
    { :set=>'Y', :clear=>'N' }
  end
  alias_method :active_lookup, :campus_lookup

end