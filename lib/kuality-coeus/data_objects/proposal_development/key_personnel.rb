 class KeyPersonObject < DataFactory

  include StringFactory, Personnel

  attr_reader :first_name, :last_name, :type, :role, :document_id, :key_person_role,
              :full_name, :user_name, :home_unit, :organization, :units, :responsibility,
              :financial,
              :era_commons_name, :degrees

  # Note that you must pass in both first and last names (or neither).
  def initialize(browser, opts={})
    @browser = browser

    defaults = {
      type:                'employee',
      role:                'Principal Investigator',
      units:               [],
      degrees:             collection('Degrees'),
    }

    set_options(defaults.merge(opts))
    requires :navigate
    @full_name="#{@first_name} #{@last_name}"
  end

  # Note: This data object does not support a situation
  # where there are multiple pages of key personnel on a
  # Proposal...
  def create
    view 'Personnel'
    on(KeyPersonnel).add_personnel
    get_person
    # Assign the role...
    on AddPersonnel do |page|
      page.set_role(role_value[@role])
      page.key_person_role.fit @key_person_role



      page.add_person

    end
    on KeyPersonnel do |person|
      person.expand_all_personnel
      @user_name=person.user_name_of(@full_name)
      person.save
      return unless person.errors.empty?
      person.organization_of @full_name
      @home_unit=person.home_unit_of(@full_name)
    end
    set_up_units unless @role=='Key Person'
    # Add gathering/setting of more attributes here as needed
    on KeyPersonnel do |person|
      person.details_of @full_name
      person.era_commons_name_of(@full_name).fit @era_commons_name
      person.save
    end

    unless @role=='Key Person' # Set credit splits
      view 'Credit Allocation'
      on CreditAllocation do |page|
        fill_out_item @full_name, page, :responsibility, :financial
        page.save
      end
    end
  end

  def edit opts={}
    view 'Personnel'
    on KeyPersonnel do |page|
      # TODO
      page.save
    end
    update_options(opts)
  end

  def update_splits opts={}
    view 'Credit Allocation'
    on CreditAllocation do |page|
      edit_item_fields opts, @full_name, page, :responsibility, :financial
      page.save
    end
    update_options(opts)
  end

  # The opts parameter must be a Hash containing at least one
  # of the credit split types.
  def update_unit_splits(unit_number, opts)
    on CreditAllocation do |page|
      opts.each do |type, value|
        page.send("unit_#{type}", @full_name, unit_number).fit value
      end
      page.save
    end
    @units.find{ |u| u[:number]==unit_number}.merge!(opts)
  end

  def add_degree_info opts={}
    defaults = { navigate: @navigate }
    @degrees.add defaults.merge(opts)
  end

  def view(page)
    @navigate.call
    open_page(page) unless on_page?(page)
  end

  def delete
    view 'Personnel'
    on KeyPersonnel do |person|
      person.check_person @full_name
      person.delete_selected
    end
  end

  def update_from_parent(navigate)
    @navigate=navigate
    notify_collections navigate
  end

  # =======
  private
  # =======

  def open_page(page)
    #TODO: Add case logic here for documents other than Proposal...
    on(ProposalSidebar).send(damballa(page))
  end

  def on_page?(page)
    begin
      # TODO: Fix this when the Document header isn't "New" any more...
      on(NewDocumentHeader).section_header==page
    rescue Watir::Exception::UnknownObjectException, Selenium::WebDriver::Error::StaleElementReferenceError, WatirNokogiri::Exception::UnknownObjectException, Watir::Wait::TimeoutError
      false
    end
  end

  def set_up_units
    on KeyPersonnel do |page|
      page.unit_details_of @full_name
      if @units.empty? # No units in @units, so we're not setting units
        # ...so, get the units from the UI:
        @units=page.units_of @full_name if @key_person_role.nil?
        @units.uniq!
      else # We have Units to add and update...
        # Temporarily store any existing units...
        page.add_unit_details(@full_name) unless @key_person_role.nil?

        units=page.units_of @full_name
        # Note that this assumes we're adding
        # Unit(s) that aren't already present
        # in the list, so be careful!
        @units.each do |unit|
          page.add_unit_number(@full_name).set unit[:number]
          page.add_unit @full_name
        end
        # Now add the previously existing units to
        # @units
        units.each { |unit| @units << unit }
      end
      @units.uniq!
      unless @units.size < 2
        @lead_unit = page.lead_unit_of @full_name
      end
    end
  end

end # KeyPersonObject

class KeyPersonnelCollection < CollectionsFactory

  contains KeyPersonObject
  include People, DocumentUtilities

  attr_reader :questionnaire

  def initialize(browser)
    @browser=browser
    @questionnaire = QuestionnaireObject.new @browser, YAML.load_file("#{File.dirname(__FILE__)}/../questions/questionnaires.yml")[:proposal_person_cert]
  end

end # KeyPersonnelCollection