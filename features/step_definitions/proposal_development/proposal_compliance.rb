When /^a compliance item is added to the Proposal with an approval date earlier than the application date$/ do
  @proposal.add_compliance approval_date: yesterday[:date_w_slashes], application_date: in_a_week[:date_w_slashes]
end

And /adds a compliance item to the Proposal$/ do
  @proposal.add_compliance
end