class CommitteeDocumentObject < DataFactory

  include StringFactory, DateFactory

  attr_reader :description, :committee_id, :document_id, :status, :name,
              :home_unit, :min_members_for_quorum, :maximum_protocols,
              :adv_submission_days, :review_type, :last_updated, :updated_user,
              :initiator, :members, :areas_of_research, :type, :schedule, :committee_type
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
      area_of_research:       []
    }
    set_options(defaults.merge(opts))
    @navigate = navigate
  end
    
  def create
    on(Header).central_admin
    @committee_type == 'irb' ? on(CentralAdmin).create_irb_committee : on(CentralAdmin).create_iacuc_committee

    on Committee do |comm|
      @document_id=comm.document_id
      @doc_header=comm.doc_title
      @initiator=comm.initiator
      @status=comm.status
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
    # FIXME!
    @navigate.call
    on Committee do |page|
      page.submit
    end
  end

  # FIXME
  # This method will create a new committee document if
  # the committee is in a final status. Not good!
  def view(tab)
    @navigate.call
    on(Committee).send(damballa(tab).to_sym)
  end

  def add_member opts={}
    defaults = {document_id: @document_id}
    view 'Members'
    @members.add defaults.merge(opts)
  end

  def add_schedule opts={}
    defaults = {document_id: @document_id,
                date: hours_from_now((@adv_submission_days.to_i+1)*24)[:date_w_slashes],
                min_days: @adv_submission_days.to_i+2
    }
    view 'Schedule'
    @schedule.add defaults.merge(opts)
  end

  def add_area_of_research
    view :area_of_research
    on ResearchAreasLookup do |page|
        page.search

        research_description = page.research_descriptions.sample
        page.check_item(research_description)
        page.return_selected
        @area_of_research << research_description
      end
  end

  # ===========
  private
  # ===========

  def navigate
    lambda {
      begin
        there = on(DocumentHeader).document_id==@document_id && @browser.frm.div(id: 'headerarea').h1.text.strip==@doc_header
      rescue Watir::Exception::UnknownObjectException, Selenium::WebDriver::Error::StaleElementReferenceError, WatirNokogiri::Exception::UnknownObjectException, Watir::Wait::TimeoutError
        there = false
      end
      unless there
        on(BasePage).close_extra_windows
        on(Header).central_admin
        on(CentralAdmin).search_iacuc_committee
        on CommitteeLookup do |page|
         fill_out page, :committee_id
         page.search
         # This rescue is a sad necessity, due to
         # Coeus's poor implementation of the Lookup pages
         # in conjunction with user Roles.
         begin
           page.results_table.wait_until_present(5)
         rescue Watir::Wait::TimeoutError
           if on(Header).doc_search_element.present?
             on(Header).doc_search
           else #you are on old ui and navigate to doc search this way
             visit(Researcher).doc_search
           end
           on DocumentSearch do |search|
             search.document_id.set @document_id
             search.search
             search.open_doc @document_id
           end
         end
         page.medusa
        end
        # Must update the document id, now:
        @document_id=on(DocumentHeader).document_id
      end
    }
  end

end
    
      