class IACUCProceduresObject < DataFactory

  include StringFactory, DateFactory, Protocol

  attr_reader  :locations, :categories,
               :personnel

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        categories: collection('ProcedureCategories'),
        personnel:  collection('ProcedurePersonnel'),
        locations:  collection('ProcedureLocations')
    }
    set_options(defaults.merge(opts))
    requires :navigate
  end

  def create
    view
    add_category
    add_personnel
  end

  def add_category opts={}
    @categories.add opts
  end

  def add_personnel
    view
    on(IACUCProcedures).select_procedure_tab 'personnel'
    on(IACUCProceduresPersonnel).personnel.each { |name|
      # The ProcedurePerson class does not have a #create method,
      # so we add persons to the collection this way...
      @personnel << (make ProcedurePerson, full_name: name)
    }
  end

  def view
    @navigate.call
    on(IACUCProtocolOverview) do |page|
      page.procedures
      page.expand_all
    end
  end

  def add_location opts={}
    defaults = {
      navigate: @navigate,
      index: @locations.size
    }
    view
    on(IACUCProcedures).select_procedure_tab 'location'
    @locations.add defaults.merge(opts)
  end

end   # IACUCProceduresObject