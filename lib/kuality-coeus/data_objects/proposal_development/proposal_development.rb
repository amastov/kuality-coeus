class ProposalDevelopmentObject < DataFactory

  include StringFactory, DateFactory, DocumentUtilities
  
  attr_reader :proposal_type, :lead_unit, :activity_type, :project_title, :proposal_number,
              :sponsor_id, :sponsor_type_code, :project_start_date, :project_end_date, :document_id,
              :status, :initiator, :created, :sponsor_deadline_date, :sponsor_deadline_time, :key_personnel,
              :opportunity_id, # Maybe add competition_id and other stuff here...
              :compliance, :questionnaire, :budget_versions, :permissions, :s2s_questionnaire, :proposal_attachments,
              :proposal_questions, :supplemental_info, :recall_reason,
              :personnel_attachments, :mail_by, :mail_type, :institutional_proposal_number, :nsf_science_code,
              :original_ip_id, :award_id
  def_delegators :@key_personnel, :principal_investigator, :co_investigator
  
  def initialize(browser, opts={})
    @browser = browser

    defaults = {
      proposal_type:         'New',
      lead_unit:             '::random::',
      activity_type:         '::random::',
      project_title:         random_multiline(11, 1, :string),
      sponsor_id:            '::random::',
      nsf_science_code:      '::random::',
      project_start_date:    next_week[:date_w_slashes],
      project_end_date:      next_year[:date_w_slashes],
      sponsor_deadline_date: next_year[:date_w_slashes],
      mail_by:               '::random::',
      mail_type:             '::random::',
      key_personnel:         collection('KeyPersonnel'),
      compliance:            collection('Compliance'),
      budget_versions:       collection('BudgetVersions'),
      personnel_attachments: collection('PersonnelAttachments'),
      proposal_attachments:  collection('ProposalAttachments')
    }
    set_options(defaults.merge(opts))
    @navigate = navigate
  end
    
  def create
    on(Header).researcher
    on(ResearcherMenu).create_proposal
    on CreateProposal do |doc|
      set_sponsor_code
      # Because of the Date Picker box that appears when clicking on the
      # Date fields, we need this special handling here. Otherwise
      # the select lists might not all get filled out, causing the
      # create to error out inappropriately.
      fill_out doc, :project_start_date, :project_end_date
      doc.date_picker.button(text: 'Done').click if doc.date_picker.button(text: 'Done').present?
      fill_out doc,  :project_title, :proposal_type, :activity_type, :lead_unit
      doc.save_and_continue
      return if doc.errors.size > 0
    end
    on ProposalDetails do |page|
      fill_out page, :original_ip_id, :award_id
      page.more
      @doc_header=page.doc_title
      @document_id=page.document_id
      @status=page.document_status
      @initiator=page.initiator
      @created=page.created
      @proposal_number=page.proposal_number
      page.save
      return if page.errors.size > 0
      # Removed until permissions is working again...
      #@permissions = make PermissionsObject, merge_settings(aggregators: [@initiator])
    end
    on(ProposalSidebar).sponsor_and_program_info
    on SponsorAndProgram do |page|
      if @nsf_science_code=='::random::'
        @nsf_science_code = page.science_codes.sample
      end
      fill_out page, :sponsor_deadline_date, :nsf_science_code, :opportunity_id, :sponsor_deadline_time
      page.save_and_continue
    end
  end

  def edit opts={}
    view 'Proposal Details'
    on ProposalDetails do |edit|
      edit_fields opts, edit, :project_title, :project_start_date, :proposal_type,
                              :project_end_date, :activity_type
      # TODO: Add more stuff here as necessary
      edit.save
    end
    update_options(opts)
  end

  def add_key_person opts={}
    @key_personnel.add merge_settings(opts)
  end
  # This alias is recommended only for when
  # using this method with no options.
  alias_method :add_principal_investigator, :add_key_person

  def add_compliance opts={}
    @compliance.add merge_settings(opts)
  end

  def add_budget_version opts={}
    # FIXME: We should not be hard-coding the NIH sponsor code, here.
    # We need to come up with a smarter way to do this:
    opts[:modular] ||= ['Y','N'].sample if @sponsor_id=='000340'
    @budget_versions.add merge_settings(opts)
  end

  # Note: this is not currently a Proposal requirement in CX...
  def add_supplemental_info opts={}
    @supplemental_info = prep(SupplementalInfoObject, opts)
  end

  def add_proposal_attachment opts={}
    @proposal_attachments.add merge_settings(opts)
  end

  def add_personnel_attachment opts={}
    @personnel_attachments.add merge_settings(opts)
  end

  def fill_out_questionnaire opts={}
    @questionnaire = prep(QuestionnaireObject, opts)
  end

  def make_institutional_proposal
    on(Header).researcher
    on(ResearcherMenu).search_institutional_proposals
    on InstitutionalProposalLookup do |look|
      fill_out look, :institutional_proposal_number
      look.search
      look.open @institutional_proposal_number
    end
    doc_id = on(InstitutionalProposal).document_id
    @si = @supplemental_info.data_object_copy if @supplemental_info
    ip = make InstitutionalProposalObject, dev_proposal_number: @proposal_number,
         proposal_type: @proposal_type,
         activity_type: @activity_type,
         project_title: @project_title,
         compliance: @compliance.copy,
         supplemental_info: @si,
         document_id: doc_id,
         proposal_number: @institutional_proposal_number,
         nsf_science_code: @nsf_science_code,
         sponsor_id: @sponsor_id
    @budget_versions.complete.budget_periods.each { |period|
      period.cost_sharing_distribution_list.each { |cost_share|
        cs_item = make IPCostSharingObject,
                  percentage: cost_share.percentage,
                  source_account: cost_share.source_account,
                  project_period: cost_share.project_period,
                  amount: cost_share.amount,
                  type: 'funded'
        ip.cost_sharing << cs_item
        period.unrecovered_fa_dist_list.each { |fna|
          f_n_a = make IPUnrecoveredFAObject,
                  fiscal_year: fna.fiscal_year,
                  index: fna.index,
                  applicable_rate: fna.applicable_rate,
                  rate_type: @budget_versions.complete.unrecovered_fa_rate_type,
                  on_campus_contract: Transforms::YES_NO.invert[fna.campus],
                  source_account: fna.source_account,
                  amount: fna.amount
          ip.unrecovered_fa << f_n_a
        } unless period.unrecovered_fa_dist_list.empty?
      }
    } unless @budget_versions.empty?
    @key_personnel.each { |person|
      project_person = make ProjectPersonnelObject, full_name: person.full_name,
                            first_name: person.first_name, last_name: person.last_name,
                            lead_unit: person.home_unit, role: person.role,
                            project_role: person.key_person_role, units: person.units,
                            responsibility: person.responsibility,
                            financial: person.financial,
                            document_id: doc_id, search_key: { institutional_proposal_number: doc_id },
                            lookup_class: InstitutionalProposalLookup, doc_header: 'KC Institutional Proposal'
      ip.project_personnel << project_person
    }
    ip
  end

  def delete
    #TODO
  end

  def recall(reason=random_alphanums)
    @recall_reason=reason
    view 'Summary/Submit'
    on(ProposalSummary).recall
    on Recall do |conf|
      conf.reason.set @recall_reason
      conf.yes
    end

    DEBUG.snap @browser

    @status=on(DocumentHeader).document_status
  end

  def reject
    view 'Summary/Submit'
    on(ProposalSummary).reject
  end

  def close
    @navigate.call
    on(Proposal).close
  end

  def view(tab)
    @navigate.call
    on(ProposalSidebar).send(damballa(tab.to_s))
  end

  def submit(type=:s)


    types={
        s:            :submit,
        ba:           :blanket_approve,
        to_sponsor:   :submit_to_sponsor,
        to_s2s: :submit_to_s2s
    }

    case(type)
      when :to_sponsor
        view 'Summary/Submit'
        on(ProposalSummary).submit_to_sponsor
        on SendNotifications do |page|
          page.employee_set
          page.search_for_recipients

          #get results
          # select results in correct table
          select_random_result
          page.add_recipients
          @institutional_proposal_number=page.institutional_proposal_number
          page.send_notifications
        end
        # FIXME! Need to get the @status value updated here!
      when :to_s2s
        view :s2s
        on S2S do |page|
          @status=page.document_status
        end
      else
        view 'Summary/Submit'
        on(ProposalSummary).submit_for_review
        @status=on(NewDocumentHeader).document_status
    end
  end

  def select_random_result
    on SendNotifications do |page|
      results_array = page.get_search_results
      page.select_random_checkbox(results_array.sample)
    end
  end
  # Note: This method currently assumes you've entered
  # an original institutional proposal ID and you want to
  # generate a new version of that same IP. If that's not
  # what you want to do then this method will need to be
  # rethought...
  def resubmit
    raise 'Fix this method'
  end

  # Note: This method does not navigate because
  # the assumption is that the only time you need
  # to save the proposal is when you are on the
  # proposal. You will never need to open the
  # proposal and then immediately save it.
  def save
    on(Proposal).save
  end

  def blanket_approve
    submit :ba
  end

  def approve(future=:no)
    view 'Summary/Submit'
    on(ProposalSummary).approve
    on(ReceiveRequests).send(future) unless future.nil?
    # TODO: Need some means of updating the @status variable here!
  end

  def approve_from_action_list(future=:no)
    on(Header).action_list
    on(ActionList).filter
    on ActionListFilter do |page|
      page.document_title.set @project_title[0..18]
      page.filter
    end
    on(ActionList).open_item(@document_id)
    on(ProposalSummary).approve

    on(ReceiveRequests).send(future) unless future.nil?

    on(ProposalSummary) do |page|
      page.wait_until { page.messages.size > 0 }
    end
    # TODO: Need some means of updating the @status variable here!
  end

  alias :sponsor_code :sponsor_id

  def copy(lead_unit, budget=:clear, budget_version=nil, attachments=:clear, questionnaire=:clear)
    view 'Proposal Details'
    on(NewDocumentHeader).copy
    on CopyToNewDocument do |page|
      page.lead_unit.select lead_unit
      page.include_budget.send(budget)
      page.budget_version.pick budget_version
      page.include_attachments.send(attachments)
      page.include_questionnaire.send(questionnaire)
      page.copy
    end

    #TODO: There's more stuff to do, here. When the system doesn't throw an exception at this spot!

    new_doc_num = on(NewDocumentHeader).document_id
    new_prop_dev = data_object_copy
    new_prop_dev.set_new_doc_number new_doc_num

    new_prop_dev
  end

  def set_new_doc_number(new_doc_number)
    @document_id = new_doc_number
    #TODO: What else goes here?
  end

  # =======
  private
  # =======

  def navigate
    lambda{
      begin
        there = on(NewDocumentHeader).document_title==@doc_header
      rescue
        there = false
      end
      unless there
        visit Landing
        on(Header).doc_search
        on DocumentSearch do |lookup|
          lookup.document_id.fit @document_id
          lookup.search
          lookup.open_result(@document_id)
        end
      end
    }
  end

  def merge_settings(opts)
    defaults = {
        navigate: @navigate
    }
    opts.merge!(defaults)
  end

  def prep(object_class, opts)
    merge_settings(opts)
    object = make object_class, opts
    object.create
    object
  end

  def set_sponsor_code
    if @sponsor_id=='::random::'
      on(CreateProposal).lookup_sponsor
      on SponsorLookup do |look|
        # Necessary here because of how the HTML gets instantiated...
        look.sponsor_name.wait_until_present(10)
        # Commented out for CX...
        #fill_out look, :sponsor_type_code
        look.search
        look.results_table.wait_until_present
        look.select_random
        look.loading
      end
      @sponsor_id=on(CreateProposal).sponsor_code.value
    else
      on(CreateProposal).sponsor_code.fit @sponsor_id
    end
  end

end # ProposalDevelopmentObject