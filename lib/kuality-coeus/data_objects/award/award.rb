# coding: UTF-8
class AwardObject < DataFactory

  include Navigation, DateFactory, StringFactory, DocumentUtilities

  attr_accessor :document_status,
                :document_id, :transaction_type, :award_status, :award_title, :activity_type, :award_type,
                :project_start_date, :project_end_date, :sponsor_id, :lead_unit_id,
                :subaward_org_name, :subaward_amount, :custom_data, :time_and_money,
                :version, :prior_versions, :id, :terms, :pi_full_name, :principal_investigator, :press,
                :project_role, :key_personnel,
                :fa_rates, :cost_sharing, :approved_equipment, :funding_proposals, :subawards,
                :view

  def_delegators :@key_personnel, :principal_investigator


  def initialize(browser, opts={})
    @browser = browser
    amount = random_dollar_value(1000000)


    defaults = {
      description:           random_alphanums_plus,
      transaction_type:      '::random::',
      award_status:          %w{Active Hold Pending}.sample, # Needs to be this way because we don't want it to pick a status of, e.g., 'Closed'
      award_title:           random_alphanums_plus,
      activity_type:         '::random::',
      award_type:            '::random::',
      project_start_date:    right_now[:date_w_slashes],
      project_end_date:      in_a_year[:date_w_slashes],
      sponsor_id:            '::random::',
      lead_unit_id:             '::random::',
      version:               '1',
      prior_versions:        {}, # Contains the version number and document ids of prior versions
      fa_rates:              collection('AwardFARates'),
      cost_sharing:          collection('AwardCostSharing'),
      approved_equipment:    collection('ApprovedEquipment'),
      key_personnel:         collection('AwardKeyPersonnel'),
      funding_proposals:     [], # Contents MUST look like: {ip_number: '00001', merge_type: 'No Change'}, ...
      subawards:             [], # Contents MUST look like: {org_name: 'Org Name', amount: '999.99'}, ...
      sponsor_contacts:      [], # Contents MUST look like: {non_employee_id: '333', project_role: 'Close-out Contact'}, ...
      press: 'save'
    }
    @lookup_class=AwardLookup
    set_options(defaults.merge(opts))
  end
#
  def create
    on(Header).central_admin
    on(CentralAdmin).create_award
    on Award do |create|
      create.expand_all
      fill_out create, :description, :transaction_type,
               :award_status, :activity_type, :award_type,
               :award_title, :project_start_date, :project_end_date,
               :obligation_start_date, :obligation_end_date, :obligated_direct,
               :anticipated_direct

    end
    set_lead_unit
    set_sponsor_id
    on Award do |create|

      create.send(@press) unless @press.nil?
      #error messages are not displayed on first save...
      create.send(@press) unless @press.nil?
      @document_id = create.header_document_id
      @id = create.award_id.strip
      @search_key = { award_id: @id }
      @document_status = create.header_status
    end
  end #create

  def edit opts={}
    view :award
    @prior_versions.store(@version, @document_id)
    on Award do |edit|
      if edit.edit_button.present?
        edit.edit
        @prior_versions.store(@version, @document_id)
        @version = edit.version
        @document_id = edit.header_document_id
        # TODO: update child objects with new @document_id value!
      end
      edit_fields opts, edit, :description, :transaction_type, :award_status, :award_title,
                  :activity_type, :award_type, :obligated_direct, :anticipated_direct,
                  :project_start_date, :project_end_date, :obligation_start_date,
                  :obligation_end_date, :nsf_science_code, :account_id, :account_type,
                  :cfda_number, :obligated_fna, :anticipated_fna
      edit.save
    end
    set_options(opts)
  end

  def view(tab)
    navigate unless on_award?
    unless on(Award).send(StringFactory.damballa("#{tab}_element")).parent.class_name=~/tabcurrent$/
      on(Award).send(StringFactory.damballa(tab.to_s))
    end

  end

  def view_tab(tab)
    unless on(Award).send(StringFactory.damballa("#{tab}_element")).parent.class_name=~/tabcurrent$/
      on(Award).send(StringFactory.damballa(tab.to_s))
    end
  end

  def view_award
    on(Header).doc_search
    on DocumentSearch do |search|
      search.document_id.set @document_id
      search.search
      search.open_item @document_id
    end
  end

  def navigate

    #we are in a strange place without a header because of time and money. need to get back from there
    @browser.goto $base_url+$context unless on(Header).header_div.exists?

    if on(Header).krad_portal_element.exists?
      on(Header).krad_portal
    else
      # DEBUG.message "krad portal does not exist we can continue on"
    end


    on(Header).central_admin
    on(CentralAdmin).search_award
    on AwardLookup do |page|
      page.award_id.set @id
      page.search
      # TODO: Remove this when document search issues are resolved
      begin
        page.medusa
      rescue Watir::Exception::UnknownObjectException
        on(Header).doc_search
        on DocumentSearch do |search|
          search.document_id.set @document_id
          search.search
          search.open_item @document_id
        end
      end
    end
    # on(Award).horzontal_links.wait_until_present
    on(Award).headerinfo_table.wait_until_present
  end



  def copy(type='new', parent=nil, descendents=:clear)
    view :award_actions
    on AwardActions do |copy|
      copy.close_parents
      copy.expand_all
      copy.expand_tree
      sleep 3 # FIXME!
      copy.show_award_details_panel(@id) unless copy.award_div(@id).visible?
      copy.copy_descendents(@id).send(descendents) if copy.copy_descendents(@id).enabled?
      copy.send("copy_as_#{type}", @id)
      copy.child_of_target_award(@id).pick! parent
      copy.copy_award @id
    end
  end


  def on_award?
    if on(Award).headerinfo_table.exist?
      on(Award).header_award_id==@id
    else
      false
    end
  end

  def set_lead_unit
    if @lead_unit_id == '::random::'
      on(Award).lookup_lead_unit
      on UnitLookup do |lookup|
        lookup.search
        lookup.return_random
      end
      on Award do |page|
        page.lead_unit_id.wait_until_present
        @lead_unit_id = page.lead_unit_id.value
      end
    else
      on(Award).lead_unit_id.fit @lead_unit_id
    end
  end

  def set_sponsor_id
    if @sponsor_id=='::random::'
      on(Award).lookup_sponsor
      on OLDSponsorLookup do |look|
        fill_out look, :sponsor_type_code
        look.search
        look.return_random
      end
      @sponsor_id=on(Award).sponsor_id.value
    else
      on(Award).sponsor_id.fit @sponsor_id
    end
  end

    def add_payment_and_invoice opts={}
      raise "You already created a Payment & Invoice in your scenario.\nYou want to interact with that item directly, now." unless @payment_and_invoice.nil?
      view :payment_reports__terms
      @payment_and_invoices = make PaymentInvoiceObject, opts
      @payment_and_invoices.create
    end

    def add_sponsor_contact opts={}
      s_c = opts.empty? ? {non_employee_id: rand(4000..4103).to_s, project_role: '::random::'} : opts
      view :contacts
      on AwardContacts do |page|
        page.expand_all
        page.search_sponsor_contact
      end
      on NonOrgAddressBookLookup do |lookup|
        lookup.search
        lookup.return_random
      end

      on AwardContacts do |page|
        page.sponsor_project_role.pick! s_c[:project_role]
        page.add_sponsor_contact
        page.save
      end
    end
  def add_terms opts={}
    raise "You already created terms in your scenario.\nYou want to interact with that object directly, now." unless @terms.nil?
    view :payment_reports__terms
    @terms = make AwardTermsObject, opts
    @terms.create
  end

  def set_valid_credit_splits
    view :contacts
    on(AwardContacts).expand_all
    on CombinedCreditSplit do |page|
      page.set_credit_split_values('100')
      page.recalculate_splits
      page.save
    end
  end

  def submit
    view :award_actions
    on AwardActions do |page|
      DEBUG.pause(3)
      page.submit
    end
    on(Confirmation).yes if on(Confirmation).yes_button.exists?
    #was causing problem with logout need to wait for page to load here.
    DEBUG.pause(4)
  end

  def add_custom_data opts={}
    view :custom_data
    defaults = {
        document_id: @document_id,
        doc_header: @doc_header,
        lookup_class: @lookup_class,
        search_key: @search_key
    }
    if @custom_data.nil?
      @custom_data = make AwardCustomDataObject, defaults.merge(opts)
      @custom_data.create
    end
  end

  def initialize_time_and_money
    open_document
    on(Award).time_and_money
    # Set up to only create the instance variable if it doesn't exist, yet
    if @time_and_money.nil?
      @time_and_money = make TimeAndMoneyObject, document_id: on(TimeAndMoney).header_document_id,
                             award_number: @id
      @time_and_money.create
    else
      @time_and_money.check_status
    end
  end

  def add_fna_rate opts={}
    view :commitments
    @fa_rates.add(opts)
  end

  def add_cost_share opts={}
    view :commitments
    @cost_sharing.add(opts)
  end

  def add_funding_proposal(ip_number, merge_type)
    view :award
    on Award do |page|
      page.expand_all
      page.institutional_proposal_number.fit ip_number
      page.proposal_merge_type.pick merge_type
      page.add_proposal
      page.save if page.errors.empty?
    end
    @funding_proposals << {ip_number: ip_number, merge_type: merge_type}
  end

  def add_subaward(name='random', amount=nil)
    amount ||= random_dollar_value(10000000)
    view :award
    on Award do |page|
      page.expand_all
      page.search_organization
    end
    if name=='random'
      on OrganizationLookup do |page|
        page.search
        page.return_random
      end
      name = on(Award).add_organization_name.value
    else
      on OrganizationLookup do |page|
        page.organization_name.set name
        page.search
        page.return_value name
      end
    end
    on Award do |page|
      page.add_subaward_amount.fit amount
      page.add_subaward
      page.save #unless page.errors.size > 0
    end
    @subawards << {org_name: name, amount: amount}
  end

  def add_approved_equipment opts={}
    view :payment_reports__terms
    @approved_equipment.add(opts)
  end

  def add_key_person opts={}
    @key_personnel = { type: 'employee',
                       project_role: 'Principal Investigator',
                       key_person_role: random_alphanums(5),
                       press: 'save'

                     }
    @key_personnel.merge!(opts)

    view :contacts
    on(AwardContacts).expand_all

      if @key_personnel[:type] == 'employee'
        on(AwardContacts).employee_search
        on KcPersonLookup do |lookup|
          lookup.last_name.fit @key_personnel[:last_name]
          lookup.first_name.fit @key_personnel[:first_name]
          lookup.search
          lookup.return_random
        end
      else
        on(AwardContacts).non_employee_search
        on AddressBookLookup do |lookup|
          lookup.last_name.fit @key_personnel[:last_name]
          lookup.first_name.fit @key_personnel[:first_name]
          lookup.search
          lookup.return_random
        end
      end

    on AwardContacts do |page|
      if @key_personnel[:project_role] == 'Principal Investigator'
        page.kp_project_role.select_value 'PI'
      else
        page.kp_project_role.pick! @key_personnel[:project_role]
      end


      case @key_personnel[:type]
        when 'employee'
          person_type = 'kp_employee_user_name'
        when 'non_employee'
          person_type = 'kp_non_employee_id'
      end

      case @key_personnel[:project_role]
        when 'Principal Investigator'
          @key_personnel[:principal_investigator] = page.send(person_type).value.gsub('  ', ' ').strip
        when 'Co-Investigator'
          @key_personnel[:co_investigator] = page.send(person_type).value.strip
        when 'Key Person'
          page.key_person_role.fit @key_person_role
          @key_personnel[:key_person] = page.send(person_type)
      end

      if @key_personnel[:type] == 'non-employee'
        @key_personnel[:added_personnel] = page.send(person_type) if @key_personnel[:type] == 'non-employee'
      else
        @key_personnel[:added_personnel] = page.send(person_type)
      end
      DEBUG.message "Award PI is #{@key_personnel[:principal_investigator]}"
      page.add_key_person

      page.send(@key_personnel[:press]) unless @key_personnel[:press].nil?
      # set_options(@key_personnel.merge(opts))
    end
  end


end #NewAwardObject