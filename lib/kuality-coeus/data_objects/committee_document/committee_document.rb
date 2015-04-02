class CommitteeDocumentObject < DataFactory

  include StringFactory, DateFactory, Navigation

  attr_reader :description, :committee_id, :document_id, :status, :name,
              :home_unit, :min_members_for_quorum, :maximum_protocols,
              :adv_submission_days, :review_type, :last_updated, :updated_user,
              :initiator, :members, :areas_of_research, :type, :schedule
  def_delegators :@members, :member, :voting_members

  def initialize(browser, opts={})
    @browser = browser
    
    defaults = {
      description:            random_alphanums_plus,
      committee_id:           random_alphanums(15), # Restricted character set until this is fixed: https://jira.kuali.org/browse/KRAFDBCK-10718
      home_unit:              '000001',
      name:                   random_alphanums(60), # Restricted character set until this is fixed: https://jira.kuali.org/browse/KRAFDBCK-10768
      min_members_for_quorum: rand(100).to_s,
      maximum_protocols:      (rand(100)+1).to_s,
      adv_submission_days:    (rand(76)+14).to_s, # Defaults to a minimum of 14 days
      review_type:            'Full',
      members:                collection('CommitteeMember'),
      areas_of_research:      [],
      schedule:               collection('CommitteeSchedule'),
      save_type:              :save,
      committee_type:         'irb',
      area_of_research:         []
    }
    @lookup_class=CommitteeLookup
    set_options(defaults.merge(opts))
  end
    
  def create
    on(Header).central_admin
    @committee_type == 'irb' ? on(CentralAdmin).create_irb_committee : on(CentralAdmin).create_iacuc_committee

    on Committee do |comm|
      @document_id=comm.document_id
      @doc_header=comm.doc_title
      @initiator=comm.initiator
      @status=comm.status
      @search_key = { committee_id: @committee_id }
      comm.committee_id_field.set @committee_id
      comm.committee_name_field.set @name
      fill_out comm, :description, :home_unit, :min_members_for_quorum,
               :maximum_protocols, :adv_submission_days, :review_type
      comm.send(@save_type)
    end
  end

  def edit opts={}
    # TODO: Write this!
  end

  def submit
    open_document
    on Committee do |page|
      page.submit
    end
  end

  # FIXME
  # This method will create a new committee document if
  # the committee is in a final status. Not good!
  def view(tab)
    open_document
    on Committee do |page|
      page.description.set @description
      page.send(damballa(tab).to_sym)
    end
  end

  def add_member opts={}
    defaults = {document_id: @document_id}
    open_document
    on(Committee).members
    @members.add defaults.merge(opts)
  end

  def add_schedule opts={}
    defaults = {document_id: @document_id,
                date: hours_from_now((@adv_submission_days.to_i+1)*24)[:date_w_slashes],
                min_days: @adv_submission_days.to_i+2
    }
    open_document
    on(Committee).schedule
    @schedule.add defaults.merge(opts)
  end

  def add_area_of_research
    open_document
    on(Committee).area_of_research

    on ResearchAreasLookup do |page|
        page.search

        research_description = page.research_descriptions.sample
        page.check_item(research_description)
        page.return_selected
        @area_of_research << research_description
      end
  end
end
    
      