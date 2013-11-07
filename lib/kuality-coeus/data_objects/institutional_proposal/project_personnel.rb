class ProjectPersonnelObject < DataObject

  include Navigation
  include Personnel

  attr_accessor :full_name, :first_name, :last_name, :role, :lead_unit,
                :units, :faculty, :total_effort, :academic_year_effort,
                :summer_effort, :calendar_year_effort, :responsibility,
                :recognition, :financial, :space, :project_role, :principal_name

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        units: [],
        role: 'Prinicipal Investigator'
    }

    set_options(defaults.merge(opts))
    requires :document_id
  end

  # Note: This currently only has support for adding
  # employees, not non-employees.

  def create

  end

  def edit opts={}
    navigate
    on IPContacts do |update|
      update.expand_all
      # TODO: This will eventually need to be fixed...
      # Note: This is a dangerous short cut, as it may not
      # apply to every field that could be edited with this
      # method...

      opts.each do |field, value|
        update.send(field, @full_name).fit value
      end
      update.save
    end
    update_options(opts)
  end

  # =======
  private
  # =======

  # Nav Aids...

  def navigate
    open_document @doc_type
    on(InstitutionalProposal).contacts
  end

  def page_class
    IPContacts
  end

end

class ProjectPersonnelCollection < CollectionsFactory

  contains ProjectPersonnelObject

  def with_units
    self.find_all { |person| person.units.size > 0 }
  end

  def units
    self.collect{ |person| person.units }.flatten
  end

end