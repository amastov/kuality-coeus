class IACUCLocationTypeMaintenanceObject < DataFactory

  include StringFactory

  attr_reader :location_type_code, :location_type

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        description:        random_alphanums,
        location_type_code: rand(900...999),
        location_type:      random_alphanums,
        press:              'blanket_approve'
    }
    set_options(defaults.merge(opts))
  end

  def create
    visit(Maintenance).iacuc_location_type
    on(LocationTypeLookup).create
    on LocationTypeMaintenance do |page|
      fill_out page, :description, :location_type_code, :location_type

      page.send(@press) unless @press.nil?
    end
  end
end