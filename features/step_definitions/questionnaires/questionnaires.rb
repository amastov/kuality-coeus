And /^the Aggregator adds a question to the proposal person questionnaire$/ do
  steps '* log in with the Aggregator user'
  @proposal.key_personnel.questionnaire.add_question
end

And /^the Aggregator cleans up the proposal person questionnaire$/ do
  steps '* log in with the Aggregator user'
  q = QuestionnaireObject.new @browser, YAML.load_file("#{File.dirname(__FILE__)}/../../../lib/kuality-coeus/data_objects/questions/questionnaires.yml")[:proposal_person_cert]
  q.view
  q.clean
end

And /the Proposal Creator can answer the new certification question for the personnel/ do
  steps %q|* log in with the Proposal Creator user|
  @proposal.view 'Personnel'
  on UpdateQuestionnaire do |page|
    page.copy
    page.ok
  end
  steps %q|* certifies the Proposal's|
end

Then /^the questionnaire update dialog does not appear when the Creator views the personnel/ do
  @proposal.view 'Personnel'
  expect(@browser.header(id: 'PropDev-PersonnelPage-UpdateCertification-Dialog_headerWrapper')).not_to be_visible
end