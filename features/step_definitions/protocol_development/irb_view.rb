Then /^the (.*) Checklist can be filled out$/ do |checklist|
  expect(on(SubmitForReview).send("#{damballa(checklist)}_checklist".to_sym)).to exist
end

Then /the system warns that the number of protocols exceeds the allowed maximum/ do
  on Confirmation do |page|
    page.yes_button.wait_until_present
    page.message.should=='The number of Protocols has reached or exceeded the maximum. Do you still want to submit the Protocol?'
  end
end

Then /the (.*) (can |can't )see the primary reviewer's comment in Submission Details/ do |person, bool|
  people = {
      'primary reviewer'               => @irb_protocol.primary_reviewers[0],
      'secondary reviewer'             => @irb_protocol.secondary_reviewers[0],
      'uninvolved committee member'    => (@committee.members.full_names - @irb_protocol.primary_reviewers - @irb_protocol.secondary_reviewers - @irb_protocol.personnel.names)[0],
      'non-reviewing committee member' => (@irb_protocol.personnel.names - [@irb_protocol.principal_investigator.full_name])[0]
  }
  member = people[person] ? @committee.members.member(people[person]) : @irb_protocol.principal_investigator
  member.sign_in
  #view_by_view is selecting the View link from the search results
  @irb_protocol.view_by_view 'Protocol Actions'
  on ProtocolActions do |page|
    page.expand_all
    page.review_comments.send(Transforms::CAN[bool], include, @irb_protocol.comments_of(@irb_protocol.primary_reviewers[0])[0][:comment])
  end
  member.sign_out
end

Then /^the summary approval date on the Protocol should be last year$/ do
  on ExpeditedApproval do |page|
    page.expand_all
    page.approval_date_ro.should == last_year[:date_w_slashes]
  end
end

And /^the expedited date on the Protocol should be yesterday$/ do
  on(ExpeditedApproval).expiration_date_ro.should == yesterday[:date_w_slashes]
end