class CopyToNewDocument < BasePage

  element(:lead_unit) { |b| b.select(name: 'proposalCopyCriteria.leadUnitNumber') }
  element(:include_budget) { |b| b.checkbox(name: 'proposalCopyCriteria.includeBudget') }
  element(:budget_version) { |b| b.select(name: 'proposalCopyCriteria.budgetVersions') }
  element(:include_attachments) { |b| b.checkbox(name: 'proposalCopyCriteria.includeAttachments') }
  element(:include_questionnaire) { |b| b.checkbox(name: 'proposalCopyCriteria.includeQuestionnaire') }

  action(:copy) { |b| b.button(text: 'Copy...').click; b.loading }

end