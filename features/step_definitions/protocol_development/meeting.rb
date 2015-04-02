And /(Protocol Creator|IRB Administrator) edits the meeting details to make it available to reviewers/ do  |correct_user|
  case correct_user
    when 'Protocol Creator'
      steps '* I log in with the Protocol Creator user'
      # @irb_protocol.view 'Protocol Actions'
    when 'IRB Administrator'
      steps '* log in with the IRB Administrator user'
  end

  visit CommitteeScheduleLookup do |page|
    page.protocol_number.set @irb_protocol.protocol_number
    page.search
    page.edit_meeting
  end
  on Meeting do |page|
    page.available_to_reviewers.fit 'yes'
    page.save
  end
end

And /^(the IRB Admin |)records the voting members' attendance at the Committee meeting$/ do |usr|
  steps '* I log in with the IRB Administrator user' if usr=='the IRB Admin '
  visit CommitteeScheduleLookup do |page|
    page.protocol_number.set @irb_protocol.protocol_number
    page.search
    page.edit_meeting
  end
  on Meeting do |page|
    page.expand_all
    @committee.voting_members.each do |member|
      page.present_voting(member.name)
    end
    page.save
  end
end

Then /the (.*) (can |can't )see the primary reviewer's comment in the meeting minutes/ do |person, bool|
  translate = { 'can ' => :not_to, 'can\'t ' => :to }
  comment = @irb_protocol.comments_of(@irb_protocol.primary_reviewers[0])[0][:comment].gsub(/\s+/, ' ').strip
  people = {
      'primary reviewer'               => @irb_protocol.primary_reviewers[0],
      'secondary reviewer'             => @irb_protocol.secondary_reviewers[0],
      'uninvolved committee member'    => (@committee.members.full_names - @irb_protocol.primary_reviewers - @irb_protocol.secondary_reviewers - @irb_protocol.personnel.names)[0],
      'non-reviewing committee member' => (@irb_protocol.personnel.names - [@irb_protocol.principal_investigator.full_name])[0]
  }
  member = people[person] ? @committee.members.member(people[person]) : @irb_protocol.principal_investigator
  member.sign_in
  visit CommitteeScheduleLookup do |page|
    page.protocol_number.set @irb_protocol.protocol_number
    page.search
    page.view_meeting
  end
  on Meeting do |page|
    page.expand_all
    expect(page.minute_entries.find{ |m_e| m_e[:description]==comment }).send(translate[bool], be_nil)
  end
  member.sign_out
end