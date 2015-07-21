And /the IACUC Admin verifies that the (.*) committee has future scheduled events/ do |committee_name|
  steps '* log in with the IACUC Administrator user'
  # First we need to make the KC IACUC 1 committee data object. The easiest way to do this
  # is to search for the committee via the name and then build the data object from what's on the page...
  on(Header).central_admin
  on(CentralAdmin).search_iacuc_committee
  on CommitteeLookup do |page|
    page.committee_name.set committee_name
    page.search
    page.edit_first_item
  end
  # TODO: Add conditional code that takes care of a situation where the committee doesn't exist in the system already.
  on Committee do |page|
    @committee = make CommitteeDocumentObject, committee_id: page.committee_id, name: page. committee_name,
        document_id: page.document_id, home_unit: page.home_unit.value, committee_type: 'IACUC',
        min_members_for_quorum: page.min_members_for_quorum.value, maximum_protocols: page.maximum_protocols.value,
        adv_submission_days: page.adv_submission_days.value, review_type: page.review_type.value, doc_header: page.doc_title
  end
  # Now that the Committee data object exists, we can check out the scheduled events and see if there are
  # any in the future...
  @committee.view 'Schedule'

  on CommitteeSchedule do |page|
    page.view_from.set right_now[:date_w_slashes]
    page.view_to.set next_year[:date_w_slashes]
    page.filter
    # If there aren't, we add some...
    if page.events.size == 0
      @committee.add_schedule
    end
  end
end

Then /^the non\-employee's review comments can be added to the online review document$/ do
  @iacuc_protocol.view 'Online Review'
  n_e_r = @iacuc_protocol.submission.primary_reviewers[0]
  on OnlineReview do |page|
    page.expand_all
    page.new_review_comment(n_e_r).set random_multiline
    page.save_review_of n_e_r
    expect(page.notification).to eq "Protocol Online Review (document number:#{page.review_doc_nbr(n_e_r)}, reviewer:#{n_e_r} ), saved successfully."
  end
end