 class KeyPersonObject < DataFactory

  include StringFactory, Personnel

  attr_reader :first_name, :last_name, :type, :role, :document_id, :key_person_role,
              :full_name, :user_name, :home_unit, :units, :responsibility,
              :financial, :recognition, :certified, :certify_info_true,
              :potential_for_conflicts, :submitted_financial_disclosures,
              :lobbying_activities, :excluded_from_transactions, :familiar_with_pla,
              :space, :other_key_persons, :era_commons_name, :degrees

  # Note that you must pass in both first and last names (or neither).
  def initialize(browser, opts={})
    @browser = browser

    defaults = {
      type:                            'employee',
      role:                            'Principal Investigator',
      units:                           [],
      degrees:                         collection('Degrees'),
      certified:                       true, # Set this to false if you do not want any Proposal Person Certification Questions answered
      certify_info_true:               'Y',
      potential_for_conflict:          'Y',
      submitted_financial_disclosures: 'Y',
      lobbying_activities:             'Y',
      excluded_from_transactions:      'Y',
      familiar_with_pla:               'Y',
    }

    set_options(defaults.merge(opts))
    requires :document_id; :doc_header
    @full_name="#{@first_name} #{@last_name}"
  end

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
      person.save
      @user_name=person.user_name_of(@full_name).value
      @home_unit=person.home_unit_of(@full_name).value
    end
    return unless on(KeyPersonnel).errors.empty?
    set_up_units

    # Proposal Person Certification
    certification

    # Add gathering/setting of more attributes here as needed
    on KeyPersonnel do |person|
      person.details_of @full_name
      person.era_commons_name_of(@full_name).fit @era_commons_name
      person.save
    end

    # Set credit splits
    view 'Credit Allocation'
    on CreditAllocation do |page|
      fill_out_item @full_name, page, :recognition, :responsibility, :space, :financial
      page.save
    end
  end

  def update_splits opts={}
    view 'Credit Allocation'
    on CreditAllocation do |page|
      edit_item_fields opts, @full_name, page, :recognition, :responsibility, :space, :financial
      page.save
    end
    update_options(opts)
  end

  def add_degree_info opts={}
    defaults = { document_id: @document_id,
                 person: @full_name }
    @degrees.add defaults.merge(opts)
  end

  def view(page)
    open_document unless on_document?
    open_page(page) unless on_page?(page)
  end

  def delete
    view 'Personnel'
    on KeyPersonnel do |person|
      person.check_person @full_name
      person.delete_selected
    end
  end

  def certification
    if @certified
      view 'Personnel'
      on(KeyPersonnel).proposal_person_certification_of @full_name
      cert_questions.each { |q| on(KeyPersonnel).send(q, @full_name, get(q)) }
    else
      cert_questions.each { |q| set(q, nil) }
    end
  end

  def update_from_parent(doc_id)
    @document_id=doc_id
    @search_key[:document_id]=doc_id
    notify_collections doc_id
  end

  # =======
  private
  # =======

  def open_document
    on(Header).researcher
    on(ResearcherMenu).search_proposals
    on DevelopmentProposalLookup do |search|
      search.proposal_number.set @proposal_number
      search.search
      search.edit_proposal @proposal_number
    end
  end

  def open_page(page)
    #TODO: Add case logic here for documents other than Proposal...
    on(ProposalSidebar).send(damballa(page))
  end

  def on_document?
    begin
      # TODO: Fix this when the Document header isn't "New" any more...
      on(NewDocumentHeader).document_title==@doc_header
    rescue Watir::Exception::UnknownObjectException, Selenium::WebDriver::Error::StaleElementReferenceError, WatirNokogiri::Exception::UnknownObjectException, Watir::Wait::TimeoutError
      false
    end
  end

  def on_page?(page)
    begin
      # TODO: Fix this when the Document header isn't "New" any more...
      on(NewDocumentHeader).section_header==page
    rescue Watir::Exception::UnknownObjectException, Selenium::WebDriver::Error::StaleElementReferenceError, WatirNokogiri::Exception::UnknownObjectException, Watir::Wait::TimeoutError
      false
    end
  end

  def cert_questions
    [:certify_info_true,
     :potential_for_conflict,
     :submitted_financial_disclosures,
     :lobbying_activities,
     :excluded_from_transactions,
     :familiar_with_pla]
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
  include People

end # KeyPersonnelCollection