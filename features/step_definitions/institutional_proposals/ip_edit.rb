# Don't parameterize this unless and until it's necessary...
When /^the Institutional Proposal Maintainer edits the Institutional Proposal$/ do
  steps '* I log in with the Institutional Proposal Maintainer user'
  @institutional_proposal.edit
end

And /^the Funding Proposal version should be '(\d+)'$/ do |version|
  @institutional_proposal.view :institutional_proposal
  on InstitutionalProposal do |page|
    page.expand_all
    page.version.should==version
  end
end

When /^the Institutional Proposal Maintainer adds a cost sharing element with a missing required field$/ do
  steps %q{ * I log in with the Institutional Proposal Maintainer user }
  @institutional_proposal.view :institutional_proposal
  on(InstitutionalProposal).edit
  # Pick a field at random for the test...
  required_field = ['Project Period','Type','Source Account','Amount' ].sample
  # Properly set the nil value depending on the field type...
  required_field=='Type' ? value='select' : value=' '
  # Transform the field name to the appropriate symbol...
  field = damballa(required_field)
  @institutional_proposal.add_cost_sharing field=>value
  text = ' is a required field.'
  error_text = {
      project_period: "Project Period#{text}",
      type: "Cost Share Type#{text}",
      source_account: "Source Account (Source Account)#{text}",
      amount: "Cost Share Commitment Amount#{text}"
  }
  @required_field_error = error_text[field]
end

When /^the Institutional Proposal Maintainer enters letters in the numeric cost share fields$/ do
  steps %q{ * I log in with the Institutional Proposal Maintainer user }
  @institutional_proposal.view :institutional_proposal
  on(InstitutionalProposal).edit
  @institutional_proposal.add_cost_sharing  project_period: random_letters(4), percentage: random_letters(4),
                                            amount: random_letters(4)
  cs = @institutional_proposal.cost_sharing[0]
  @errors = [
      'Project Period is not formatted correctly.',
      "#{cs.percentage} is not a valid amount.",
      "#{cs.amount} is not a valid amount."
  ]
end

When /^the Institutional Proposal Maintainer adds an unrecovered f&a element with a missing required field$/ do
  steps %q{ * I log in with the Institutional Proposal Maintainer user }
  @institutional_proposal.view :institutional_proposal
  on(InstitutionalProposal).edit
  # Pick a field at random for the test...
  required_field = [:fiscal_year, :rate_type, :source_account, :amount
  ].sample
  # Properly set the nil value depending on the field type...
  required_field==:rate_type ? value='select' : value=' '
  @institutional_proposal.add_unrecovered_fa required_field=>value
  text = ' is a required field.'
  error_text = {
      source_account: "Source Account#{text}",
      amount: "Unrecovered F&A Amount#{text}",
      fiscal_year: "Fiscal Year#{text}",
      rate_type: "Rate Type#{text}"
  }
  @required_field_error = error_text[required_field]
end

When /^the Institutional Proposal Maintainer enters letters in the numeric unrecovered F&A fields$/ do
  steps %q{ * I log in with the Institutional Proposal Maintainer user }
  @institutional_proposal.view :institutional_proposal
  on(InstitutionalProposal).edit
  @institutional_proposal.add_unrecovered_fa fiscal_year: random_letters(4), applicable_rate: random_letters(4),
                                             amount: random_letters(4)
  fa = @institutional_proposal.unrecovered_fa[0]
  @errors = [
      'Fiscal Year is not formatted correctly.',
      "#{fa.applicable_rate} is not a valid amount.",
      "#{fa.amount} is not a valid amount."
  ]
end

When /^the Institutional Maintainer enters an invalid year for the fiscal year field$/ do
  steps %q{ * I log in with the Institutional Proposal Maintainer user }
  @institutional_proposal.view :institutional_proposal
  on(InstitutionalProposal).edit
  @institutional_proposal.add_unrecovered_fa :fiscal_year => '00'
end