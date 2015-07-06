class AwardKeyPersonObject < DataFactory

  include Personnel

  attr_reader :employee_user_name, :non_employee_id, :project_role,
              :key_person_role, :units, :first_name, :last_name, :full_name,
              :lead_unit, :type, :responsibility, :financial, :recognition,
              :space, :key_person_role, :get_units

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        type:            'employee',
        project_role:    'Principal Investigator',
        units:           [], # Contains Hashes with Keys... :number, :name, :recognition, :responsibility, :space, :financial
        key_person_role: random_alphanums,
        get_units: 'yes'
    }

    set_options(defaults.merge(opts))
    @full_name = @type=='employee' ? "#{@first_name} #{@last_name}" : "#{@last_name}, #{@first_name}"
    requires :navigate
  end

  # Navigation done by parent object...
  def create
    on(AwardContacts).expand_all
    if @type == 'employee'
      on AwardContacts do |page|
        page.employee_search
      end

      if @last_name == nil && @first_name == nil

        on KcPersonLookup do |lookup|
          lookup.last_name.fit @last_name
          lookup.first_name.fit @first_name
          lookup.search
          #capture full_name last_name first_name
          lookup.select_random_with_name
        end
        #need to view person to get the first and last name because full name is given
        on KCPerson do |gather|
          @last_name = gather.last_name
          @first_name = gather.first_name
          @full_name = gather.full_name
          gather.close_window
        end
      end
      on KcPersonLookup do |lookup|
        lookup.last_name.fit @last_name
        lookup.first_name.fit @first_name
        lookup.search
        lookup.return_random
      end

    else #Non-employee
      on AwardContacts do |page|
        page.non_employee_search
        #Non-Organizational Address Book Lookup
      end
      on NonOrgAddressBookLookup do |lookup|
        lookup.search
        lookup.return_random
      end
      #set up name
      on AwardContacts do |page|
        @full_name = page.kp_non_employee_id.value.strip
        @first_name = @full_name.partition(',').first.strip
        @last_name =  @full_name.partition(',').last.strip
      end

    end #to employee or non-employee

    on AwardContacts do |page|
      page.kp_project_role.select @project_role
      page.key_person_role.fit @key_person_role if @project_role == 'Key Person'

      page.add_key_person
      page.expand_all
      #need to remove spaces and commas because of the way the div is constructed
      @full_name_no_spaces = @full_name.gsub(' ', '').gsub(',', '')
      if @get_units == 'yes' && @role != 'Key Person'
        @units = page.units(@full_name_no_spaces)
      end
    end
  end  #create

  def edit opts={}
    # TODO: Add navigation
    on AwardContacts do |update|
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

  # TODO: Some of this method should be moved to the Personnel
  # module at some point, so it can be used by the KeyPersonObject.
  def add_unit(unit_number, lead=false)
    # TODO: Add conditional navigation
    on AwardContacts do |add_unit|
      add_unit.expand_all
      add_unit.add_lead_unit(@full_name) if lead
      add_unit.add_unit_number(@full_name).set unit_number
      add_unit.add_unit(@full_name)
      @units << {number: unit_number, name: add_unit.unit_name(@full_name, unit_number) }
      confirmation 'no'
      add_unit.save
    end
    @lead_unit=unit_number if lead
  end

  def add_lead_unit(unit_number)
    add_unit(unit_number, true)
  end

  def set_lead_unit(unit_number)
    # TODO: Add conditional navigation
    on AwardContacts do |page|
      page.lead_unit_radio(@full_name, unit_number).set
      page.save
    end
  end

  def delete_unit(unit_number)
    # TODO: Add conditional navigation
    on AwardContacts do |delete_unit|
      delete_unit.delete_unit(@full_name, unit_number)   if delete_unit.delete_unit_element(@full_name, unit_number).present?
      delete_unit.save
    end
    @units.delete(unit_number)
  end

  def update_from_parent(id, navigation_lambda)
    @document_id=id
    @navigate=navigation_lambda
  end

  def update_splits opts={}
    view 'Contacts'
    on AwardContacts do |page|
      page.expand_all
      edit_item_fields opts, @full_name, page, :recognition, :responsibility, :space, :financial
      page.save
    end
    update_options(opts)
  end

  def view(tab)
    @navigate.call
    unless on(Award).send(StringFactory.damballa("#{tab}_element")).parent.class_name=~/tabcurrent$/
      on(Award).send(StringFactory.damballa(tab.to_s))
    end
  end

  def update_unit_splits(unit_number, opts)
    on CombinedCreditSplit do |page|
      opts.each do |type, value|
        page.send("unit_#{type}", @full_name, unit_number).fit value
      end
      page.save
    end
    # @units.find{ |u| u[:number]==unit_number}.merge!(opts)
  end

end

class AwardKeyPersonnelCollection < CollectionsFactory

  contains AwardKeyPersonObject

  def principal_investigator
    self.find{ |person| person.project_role=='Principal Investigator' || person.project_role=='PI/Contact' }
  end

  def with_units
    self.find_all { |person| person.units.size > 0 }
  end

end