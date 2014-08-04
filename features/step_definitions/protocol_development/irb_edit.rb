When /^the Protocol is given an '(.*)' Submission Review Type$/ do |type|
  @irb_protocol.view 'Protocol Actions'
  on ProtocolActions do |page|
    page.expand_all
    page.submission_review_type.select type
  end
end

When /the Protocol is being submitted to that Committee for review/ do
  @irb_protocol.view 'Protocol Actions'
  on ProtocolActions do |page|
    page.expand_all
    page.committee.select @committee.name
  end
end

And /^submits the Protocol to the Committee for review$/ do
  @irb_protocol.submit_for_review committee: @committee.name
end

And /assigns reviewers to the Protocol/ do
  @irb_protocol.assign_primary_reviewers
  @irb_protocol.assign_secondary_reviewers
end

# Note: This stepdef assumes no reviewers are already assigned...
And /assigns a primary reviewer to the Protocol/ do
  @irb_protocol.assign_primary_reviewers @committee.members.full_names.sample
end

# Note: This stepdef assumes no reviewers are already assigned...
And /assigns a primary and a secondary reviewer to the Protocol/ do
  # Select a random committee member who is not already in the Protocol's personnel...
  names = (@committee.members.full_names - @irb_protocol.personnel.names).shuffle
  @irb_protocol.assign_primary_reviewers names[0]
  @irb_protocol.assign_secondary_reviewers names[1]
end

And /assigns a committee member the the Protocol's personnel/ do
  # Need to make sure the selected member isn't already assigned to the Protocol somehow...
  reviewers = @irb_protocol.reviews ? @irb_protocol.primary_reviewers + @irb_protocol.secondary_reviewers : []
  names = @committee.members.full_names - @irb_protocol.personnel.names - reviewers
  name = names.sample
  first = name[/^\w+/]
  last = name[/\w+$/]
  role = ['Co-Investigator', 'Correspondent - CRC', 'Correspondent Administrator', 'Study Personnel'].sample
  @irb_protocol.view 'Personnel'
  @irb_protocol.personnel.add full_name: name,
                              role: role, first_name: first,
                              last_name: last
end

And /^the Protocol is submitted to the Committee for review, with:$/ do |table|
  review_data = table.rows_hash

  @irb_protocol.submit_for_review  submission_type: review_data['Submission Type'],
                                   submission_review_type: review_data['Review Type'],
                                   type_qualifier: review_data['Type Qualifier'],
                                   committee: @committee.name
end

And /^submits the Protocol to the Committee for Expedited review$/ do
  @irb_protocol.submit_for_review committee: @committee.name, submission_review_type: 'Expedited'
end

When /the second Protocol is submitted to the Committee for review on the same date/ do
  @irb_protocol2.submit_for_review committee: @committee.name, schedule_date: @irb_protocol.schedule_date
end

And /suspends the Protocol$/ do
  @irb_protocol.suspend
end

And /the IRB Admin closes the Protocol$/ do
  steps '* log in with the IRB Administrator user'
  @irb_protocol.view 'Protocol Actions'
  on Close do |page|
    page.expand_all
    page.comments.set random_alphanums_plus
    page.submit
  end
  DEBUG.pause 300
end

And /the principal investigator approves the Protocol$/ do
  $users.current_user.log_out
  @irb_protocol.principal_investigator.log_in

  # TODO: This is probably not the right pathway through the UI...
  visit(Researcher).action_list
  on(ActionList).filter
  on ActionListFilter do |page|

    DEBUG.message @irb_protocol.protocol_number

    page.document_title.set @irb_protocol.protocol_number
    page.filter
  end
  on(ActionList).open_review(@irb_protocol.protocol_number)
  @irb_protocol.view 'Protocol Actions'
  DEBUG.message
  DEBUG.pause 300

end