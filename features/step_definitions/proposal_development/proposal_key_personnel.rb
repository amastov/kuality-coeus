And /^I? ?add the (.*) user as an? (.*) to the key personnel proposal roles$/ do |user_role, proposal_role|
  user = get(user_role)
  @proposal.add_key_person first_name: user.first_name, last_name: user.last_name, role: proposal_role
end

And /adds? a key person to the Proposal$/ do
  @proposal.add_key_person role: 'Key Person', key_person_role: random_alphanums
end

When /^I? ?add (.*) as a key person with a role of (.*)$/ do |user_name, kp_role|
  user = get(user_name)
  @proposal.add_key_person first_name: user.first_name,
                           last_name: user.last_name,
                           role: 'Key Person',
                           key_person_role: kp_role
end

And /^I? ?add a (.*) with a (.*) credit split of (.*)$/ do |role, cs_type, amount|
  @split_type = cs_type
  @proposal.add_key_person cs_type.downcase.to_sym=>amount, role: role
end

When /^I? ?adds? a key person without a key person role$/ do
  @proposal.add_key_person role: 'Key Person', key_person_role:''
end

And /adds? a co-investigator to the Proposal$/ do
  @proposal.add_key_person role: 'Co-Investigator'
  on(KeyPersonnel).save
end

When /adds? a principal investigator to the Proposal$/ do
  @proposal.add_principal_investigator
end

When /^various personnel are added to the Proposal$/ do
  steps %q|
    * add a principal investigator to the Proposal
    * add a co-investigator to the Proposal
    * add a key person to the Proposal
  |
end

And /certifies the Proposal's/ do
  @proposal.view 'Personnel'
  @proposal.key_personnel.each do |person|
    next if person.role == 'Key Person'
    on KeyPersonnel do |page|
      page.expand_all_personnel
      page.proposal_person_certification_of person.full_name
    end
    @proposal.key_personnel.questionnaire.answer_for(person.full_name, 'Y')
    if @proposal.key_personnel.questionnaire.questions.size != on(KeyPersonnel).questions(person.full_name).size
      warn "The Proposal Person Questionnaire object is out of sync with the system's setup.\nGoing to brute-force answer the questionnaire, so that\nthe Person gets certified and the step definition requirements are met,\nbut the code and the system need to be synced up."
      on KeyPersonnel do |page|
        page.questions(person.full_name).each do |ques|
          page.answer(person.full_name, ques, 'Y')
        end
      end
    end
  end
end

Given /^I? ?adds? the Grants.Gov user as the Proposal's PI$/ do
  @proposal.add_principal_investigator last_name: $users.grants_gov_pi.last_name, first_name: $users.grants_gov_pi.first_name
end

When /^I? ?sets? valid credit splits for the Proposal$/ do
  @proposal.key_personnel.set_valid_credit_splits
end

And /can approve the Proposal$/ do
  expect{
    on(ProposalSummary).approve
  }.not_to raise_error
end

When /^the (.*) user approves the Proposal$/ do |role|
  get(role).sign_in
  @proposal.approve
end

When /add the (.*) user as a (.*) to the key personnel Proposal roles$/ do |user_role, proposal_role|
  user = get(user_role)
  @proposal.add_key_person first_name: user.first_name, last_name: user.last_name, role: proposal_role
end

Then /^the same person cannot be added to the Proposal personnel again$/ do
  @last_name = @proposal.principal_investigator.last_name
  @first_name = @proposal.principal_investigator.first_name
  expect{@proposal.add_key_person role: 'Co-Investigator', last_name: @last_name, first_name: @first_name}.to raise_error
end

And /^(\d+) key persons can be added to the Proposal$/ do |number|
  number.to_i.times do
    @proposal.view 'Personnel'
    on(KeyPersonnel).add_personnel
    on(AddPersonnel) do |page|
      page.employee.set
      names = []
      while names.empty?
        page.last_name.set("*#{%w{b c e f g h j k l o p r s t u v w y}.sample}*")
        page.continue

        # We need to exclude the set of test users from the list
        # of names we'll randomly select from...
        names = page.returned_full_names - $users.full_names
        names.delete_if { |name| name.scan(' ').size != 1 }
        if names.empty?
          page.go_back
        end
      end
      name = names.sample
      page.select_person name
      page.continue
    end
    # Assign the role...
    on AddPersonnel do |page|
      page.set_role 'KP'
      page.key_person_role.set random_alphanums
      page.add_person
    end
  end
end