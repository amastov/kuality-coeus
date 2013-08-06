Then /^Submission details will be immediately available on the S2S tab$/ do
  # Note that there's no navigation here currently because
  # this step def comes after the submission step, which
  # should automatically switch the user to the S2S page.
  on S2S do |page|
    page.expand_all
    page.submission_details_table.should be_present
    page.submission_status.should=='Submitted to S2S'
  end
end

Then /^within a couple minutes the submission status will be updated$/ do
  on S2S do |page|
    x = 0
    while page.submission_status=='Submitted to S2S'
      sleep 5
      page.refresh_submission_details
      x += 1
      break if x == 24
    end
    # We don't care what it is. Only that it's updated...
    page.submission_status.should_not == 'Submitted to S2S'
  end
end

When(/^I attach the PHS training and fellowship forms to the proposal$/) do
  on S2S do |page|
    %w{PHS_Fellowship_Supplemental_1_2-V1.2
     PHS398_TrainingBudget-V1.0}.each { |form| page.include_form(form).set }
  end
end

Then /^the PHS training and fellowship questionnaires should appear in the proposal$/ do
  on(S2S).questions
  on(PHS398TrainingBudgetQuestions).form_tab("PHS398 Training Budget V1-0").should be_present
  on(PHSFellowshipQuestions).form_tab("PHS Fellowship Form V1-2").should be_present
end

When /^I? ?complete their respective questionnaires$/ do
  on(PHS398TrainingBudgetQuestions).complete_phs_training_questionnaire
  on(PHSFellowshipQuestions).complete_phs_fellowship_questionnaire
end

Then /^the questionnaire titles should indicate that the questionnaires have been completed$/ do
  on Questions do |page|
    %w{PHS_Fellowship_Supplemental_1_2-V1.2
     PHS398_TrainingBudget-V1.0}.each { |form| page.form_status(form).should=='Complete' }
  end
end