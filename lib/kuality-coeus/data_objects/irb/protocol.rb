class IRBProtocolObject < DataFactory

  include StringFactory, Navigation, DateFactory

  attr_reader  :description, :organization_document_number, :protocol_type, :title, :lead_unit,
               :other_identifier_type, :other_identifier_name, :organization_id, :organization_type,
               :funding_type, :funding_number, :source, :participant_type, :document_id, :initiator,
               :protocol_number, :status, :submission_status, :expiration_date, :personnel,
               # Submit for review...
               :reviews, :schedule_date,
               # Withdraw
               :withdrawal_reason,
               # Amendment
               :amendment,
               # Return to PI
               :return_to_pi

  def_delegators :@personnel, :principal_investigator
  def_delegators :@reviews, :add_comment_for, :approve_review_of, :accept_comments_of, :comments_of,
                 :mark_comments_private_for, :mark_comments_final_for, :assign_primary_reviewers,
                 :assign_secondary_reviewers, :primary_reviewers, :secondary_reviewers

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        description:         random_alphanums_plus,
        protocol_type:       '::random::',
        title:               random_alphanums_plus,
        lead_unit:           '::random::',
        personnel:           collection('ProtocolPersonnel')
    }
    @lookup_class = ProtocolLookup
    set_options(defaults.merge(opts))
  end

  def create
    on(Header).researcher
    on(ResearcherMenu).create_irb_protocol
    on ProtocolOverview do |doc|
      @document_id=doc.document_id
      @doc_header=doc.doc_title
      @status=doc.document_status
      @initiator=doc.initiator
      @submission_status=doc.submission_status
      @expiration_date=doc.expiration_date
      doc.expand_all
      fill_out doc, :description, :protocol_type, :title
    end
      set_pi
      set_lead_unit
    on ProtocolOverview do |doc|
      doc.save
      @protocol_number=doc.protocol_number
      @search_key = { protocol_number: @protocol_number }
    end
  end

  def view(tab)
    raise 'Please pass a string for the Protocol\'s view method.' unless tab.kind_of? String
    navigate
    on(ProtocolOverview).send(damballa(tab))
  end

  def view_by_view(tab)
    raise 'Please pass a string for the Protocol\'s view method.' unless tab.kind_of? String
    navigate('view')
    on(ProtocolOverview).send(damballa(tab))
  end

  def view_by_edit(tab)
    view(tab)
  end

  def on_protocol?
    # if on(ProtocolOverview).headerinfo_table.exists?
    #   on(ProtocolOverview).protocol_number==@protocol_number
    # else
      false
    # end
  end

  def navigate(type='edit')

    #we have gotten to a strange place without a header because of time and money need to get back from there
    @browser.goto $base_url+$context unless on(Header).header_div.exists?

    #Return to the right header
    on(Header).krad_portal if on(Header).krad_portal_element.exists?

    unless on_protocol?
      DEBUG.message 'not on document'
      on(Header).central_admin
      on(CentralAdmin).search_human_participants

      on ProtocolLookup do |page|
        page.protocol_number.set @protocol_number
        page.search

        case type
          when 'edit'
            page.edit_first_item
          when 'view'
            page.view_first_item
        end
      end
    end

  end

  def submit_for_review opts={}
    view 'Protocol Actions'
    @reviews = make ReviewObject, opts
    @reviews.create
    #Need to capture the Document ID, after submit
    #but there is one test that needs to verify maximum number of Protocol reached.
    if @reviews.max_protocol_confirm == nil
      on(Confirmation).yes if on(Confirmation).yes_button.present?
      on SubmitForReview do |page|
        @status=page.document_status
        @document_id=page.document_id
      end
    else
      puts 'Now on the Confirmation page and happy to be here without pressing any button'
    end
  end

  def modify_submission_request opts={}
    view 'Protocol Actions'
    @reviews.modify opts
  end

  def withdraw(reason=random_multiline(50,4))
    @withdrawal_reason=reason
    view 'Protocol Actions'
    on WithdrawProtocol do |page|
      page.expand_all
      fill_out page, :withdrawal_reason
      page.submit
      @status=page.document_status
      @document_id=page.document_id
    end
  end

  def assign_to_agenda
    view 'Protocol Actions'
    on AssignToAgenda do |page|
      page.expand_all
      # TODO: Add more stuff here when needed.
      page.submit
    end
  end

  def notify_committee(committee_name)
    view 'Protocol Actions'
    on NotifyCommittee do |notify|
      notify.expand_all
      notify.committee_id.select committee_name

      notify.submit
    end
  end

  def create_amendment opts={}
    @amendment = {
        summary: random_alphanums_plus,
        sections: [['General Info', 'Funding Source', 'Protocol References and Other Identifiers',
              'Protocol Organizations', 'Subjects', 'Questionnaire', 'General Info',
              'Areas of Research', 'Special Review', 'Protocol Personnel', 'Others'].sample]
    }
    @amendment.merge!(opts)
    view 'Protocol Actions'

    on CreateAmendment do |page|
      page.expand_all
      page.create_amendment_div.wait_until_present
      page.summary.set @amendment[:summary]
      @amendment[:sections].each do |sect|
        page.amend(sect).set
      end
      page.create
    end

    confirmation('yes')
    @document_id = on(ProtocolActions).document_id
  end

  def submit_expedited_approval opts={}
    view 'Protocol Actions'
    @expedited_approval = make ExpeditedApprovalObject, opts
    @expedited_approval.create

    #FIXME!
    # on(ProtocolActions).save_correspondence if on(ProtocolActions).save_correspondence_button.present?
  end

  # TODO: Finish this off...
  def suspend
    view 'Protocol Actions'
    on Suspend do |page|
      page.expand_all
      page.x
    end
  end

  def return_to_pi opts={}
    @return_to_pi = { comments: random_alphanums_plus,
                      action_date: in_a_week[:date_w_slashes] }
    @return_to_pi.merge!(opts)
    on ReturnToPI do |page|
      page.action_date.fit @return_to_pi[:action_date]
      page.comments.fit @return_to_pi[:comments]
      page.submit
      @document_id=page.document_id
    end

    on NotificationEditor do |page|
      if page.notification_editor_div.present?
        page.send_it
      end
    end
  end

  # TODO: This needs to be made much more robust...
  def approve_action
    view 'Protocol Actions'
    on ApproveAction do |page|
      page.expand_all
      page.submit
    end
  end

  # =======
  private
  # =======

  def merge_settings(opts)
    defaults = {
        document_id: @document_id,
        doc_header: @doc_header
    }
    opts.merge!(defaults)
  end

  def set_lead_unit
    if @lead_unit=='::random::'
      on(ProtocolOverview).find_lead_unit
      on UnitLookup do |look|
        look.search
        look.page_links[rand(look.page_links.length)].click if look.page_links.size > 0
        look.return_random
      end
      @lead_unit=on(ProtocolOverview).lead_unit.value
    else
      on(ProtocolOverview).lead_unit.fit @lead_unit
    end
  end

  # TODO: This is going to have to be updated when we want to
  # be able to specify a particular person as the PI. Right now
  # it selects a PI at random.
  def set_pi
    on(ProtocolOverview).pi_employee_search
    on KcPersonLookup do |look|
      look.search
      # We need to exclude the set of test users from the list
      # of names we'll randomly select from...
      names = look.returned_full_names - $users.full_names
      name = 'William Lloyd Garrison'
      while name.scan(' ').size > 1
        name = names.sample
        # The KcPerson_Id of the user must not contain letters...
        name = 'William Lloyd Garrison' if look.person_id_of(name) =~ /[a-z]/
      end
      first_name = name[/^\w+/]
      last_name = name[/\w+$/]
      user_name = look.user_name_of name
      look.return_value name
      pi = make ProtocolPersonnelObject, first_name: first_name, last_name: last_name,
                full_name: name, role: 'Principal Investigator', user_name: user_name
      @personnel << pi
    end
  end

end