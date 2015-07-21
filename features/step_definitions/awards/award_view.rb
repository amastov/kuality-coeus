Then /^The Award PI's Lead Unit is (.*)$/ do |unit|
  on(Award).award
  expect(on(Award).lead_unit_ro).to include unit
end

Then /^the Award's Lead Unit is changed to (.*)$/ do |unit|
  @award.view 'Award'
  expect(on(Award).lead_unit_ro).to =~ /^#{unit}/
end

Then /^the Award's title is trimmed to the first 200 characters$/ do
  expect(on(Award).award_title.value).to eq @award.award_title[0..199]
end

Then /^a warning appears saying tracking details won't be added until there's a PI$/ do
  expect(on(PaymentReportsTerms).errors).to include 'Report tracking details won\'t be added until a principal investigator is set.'
end

Then /^the new Award should not have any subawards or T&M document$/ do
  on Award do |test|
    # If there are no Subawards, the table should only have 3 rows...
    expect (test.approved_subaward_table.rows.size).to eq 3
    test.time_and_money
    # If there is no T&M, then an error should be thrown...
    expect(test.errors).to include 'Project End Date (Project End Date) is a required field.'
  end
end

Then /^the new Award's transaction type is 'New'$/ do
  @award.view :award
  on Award do |page|
    page.expand_all
    expect(page.transaction_type.selected?('New')).to be true
  end
end

Then /^the child Award's project end date should be the same as the parent, and read-only$/ do
  expect(on(Award).project_end_date_ro).to eq @award.project_end_date
end

Then /^the anticipated and obligated amounts are read-only and (.*)$/ do |amount|
  on Award do |page|
    expect(page.anticipated_direct_ro).to eq amount
    expect(page.obligated_direct_ro).to eq amount
  end
end

Then /^the anticipated and obligated amounts are zero$/ do
  on Award do |page|
    page.expand_all
    expect(page.anticipated_direct_ro).to eq ''
    expect(page.obligated_direct_ro).to eq ''
  end
end

And /^the Award's PI should match the PI of the (.*) Funding Proposal$/ do |number|
  index = { 'first'=> 0, 'second' => 1 }
  person = @ips[index[number]].project_personnel.principal_investigator.full_name
  @award.view :contacts
  on AwardContacts do |page|
    page.expand_all
    expect(page.key_personnel).to include person
    expect(page.project_role(person).selected_options[0].text).to eq 'Principal Investigator'
  end
end

And /^the first Funding Proposal's PI is not listed in the Award's Contacts$/ do
  expect(on(AwardContacts).key_personnel).not_to include @ips[0].project_personnel.principal_investigator.full_name
end

And /^the second Funding Proposal's PI should be a (.*) on the Award$/ do |role|
  person = @ips[1].project_personnel.principal_investigator.full_name
  on AwardContacts do |page|
    expect(page.key_personnel).to include person
    expect(page.project_role(person).selected_options[0].text).to eq role
  end
end

And /^the second Funding Proposal's PI should not be listed on the Award$/ do
  expect(on(AwardContacts).key_personnel).not_to include @ips[1].project_personnel.principal_investigator.full_name
end

And /^the Award's cost share data are from the (.*) Funding Proposal$/ do |cardinal|
  index = { 'first' => 0, 'second' => 1 }
  n_i = index[cardinal]==0 ? 1 : 0
  @award.view :commitments
  cs_list = @ips[index[cardinal]].cost_sharing
  not_cs = @ips[n_i].cost_sharing
  on Commitments do |page|
    page.expand_all
    cs_list.each { |cs|
      expect(page.cost_sharing_commitment_amount(cs.source_account, cs.amount).value.groom).to eq cs.amount.to_f
      expect(page.cost_sharing_source(cs.source_account, cs.amount).value).to eq cs.source_account
    }
    not_cs.each { |not_cost_share|
      expect(page.cost_share_sources).not_to include not_cost_share.source_account
    }
  end
end

And /^the Award's cost share data are from both Proposals$/ do
  @award.view :commitments
  cs_list = []
  # TODO: This can be cleaned up...
  cs_list = @ips.collect{ |ip| ip.cost_sharing }.flatten
  on Commitments do |page|
    page.expand_all
    cs_list.each { |cs|
      expect(page.cost_sharing_commitment_amount(cs.source_account, cs.amount).value.groom).to eq cs.amount.to_f
      expect(page.cost_sharing_source(cs.source_account, cs.amount).value).to eq cs.source_account
    }
  end
end

And /^the Award's special review items are from both Proposals$/ do
  @award.view :special_review
  on AwardsSpecialReview do |page|
    @ips.collect{ |ip| ip.special_review }.flatten.each_with_index do |s_r, index|
      expect(page.type_code(index).selected_options[0].text).to eq s_r.type
      expect(page.approval_status(index).selected_options[0].text).to eq s_r.approval_status
    end
  end
end

And /^the Award's special review items are from the first Proposal$/ do
  @award.view :special_review
  on AwardsSpecialReview do |page|
    @ips[0].special_review.each_with_index do |s_r, index|
      expect(page.type_code(index).selected_options[0].text).to eq s_r.type
      expect(page.approval_status(index).selected_options[0].text).to eq s_r.approval_status
    end
    @ips[1].special_review.each do |s_r|
      expect(page.types).not_to include s_r.type
    end
  end
end

Then /^all Award fields remain editable$/ do
  on Award do |page|
    page.expand_all
    expect(page.transaction_type).to be_present
    expect(page.award_status).to be_present
    expect(page.activity_type).to be_present
    expect(page.award_type).to be_present
    expect(page.award_title).to be_present
    expect(page.sponsor_id).to be_present
    expect(page.project_end_date).to be_present
  end
end

And /^the Award\'s F&A data are from both Proposals$/ do
  @award.view :commitments
  ufna = IPUnrecoveredFACollection.new(@browser)
  @ips.each do |ip|
    ip.unrecovered_fa.each { |u| ufna << u }
  end
  ufna.reindex
  on Commitments do |page|
    page.expand_all
    ufna.each do |unrecfna|
      i = unrecfna.index
      expect(page.fna_rate(i).value).to eq unrecfna.applicable_rate
      expect(page.fna_type(i).selected_options[0].text).to eq unrecfna.rate_type
      expect(page.fna_fiscal_year(i).value).to eq unrecfna.fiscal_year
      expect(page.fna_campus(i).selected_options[0].text).to eq Transforms::ON_OFF[unrecfna.on_campus_contract]
      expect(page.fna_source(i).value).to eq unrecfna.source_account
      expect(page.fna_amount(i).value.groom.to_s).to eq unrecfna.amount
    end
    expect(page.unrecovered_fna_total.groom).to eq ufna.total
  end
end

And /^the Award's F&A data are from the first Proposal$/ do
  @award.view :commitments
  on Commitments do |page|
    page.expand_all
    @ips[0].unrecovered_fa.each do |unrecfna|
      i = unrecfna.index
      expect(page.fna_rate(i).value).to eq unrecfna.applicable_rate
      expect(page.fna_type(i).selected_options[0].text).to eq unrecfna.rate_type
      expect(page.fna_fiscal_year(i).value).to eq unrecfna.fiscal_year
      expect(page.fna_campus(i).selected_options[0].text).to eq Transforms::ON_OFF[unrecfna.on_campus_contract]
      expect(page.fna_source(i).value).to eq unrecfna.source_account
      expect(page.fna_amount(i).value).groom.to_s.to eq unrecfna.amount
    end
    @ips[1].unrecovered_fa.each do |fna|
      expect(page.fna_sources).not_to include fna.source_account
    end
    expect(page.unrecovered_fna_total.groom).to eq @ips[0].unrecovered_fa.total
  end
end

And /^the Award Modifier can see that the Funding Proposal has been removed from the Award$/ do
  steps '* I log in with the Award Modifier user'
  @award.view :award
  on Award do |page|
    page.expand_all
    #TODO: Improve what's being validated, here...
    expect(page.current_funding_proposals_table.rows.size).to eq 4
  end
end

And(/^the Award's version number is '(\d+)'$/) do |version|
  @award.view :award
  on Award do |page|
    page.expand_all
    expect(page.version).to eq version
  end
end

Then /^the default start and end dates are based on the F&A rate's fiscal year$/ do
  fna = @award.fa_rates[0]
  f_y = fna.fiscal_year.to_i
  expect(fna.start_date).to eq "07/01/#{f_y-1}"
  expect(fna.end_date).to eq "06/30/#{f_y}"
end

And /^returning to the Award goes to the new, pending version$/ do
  on(TimeAndMoney).return_to_award
  on Award do |page|
    expect(page.header_status).to eq 'SAVED'
    expect(page.header_document_id).to eq @award.document_id
  end
end

And /opens the Award$/ do
  @award.view :award
end

When /^the Award Modifier searches for the Award from the award lookup page$/ do
    on(Header).central_admin
    on(CentralAdmin).search_award
    on AwardLookup do |lookup|
      lookup.award_id.set @award.id
      lookup.search
    end
end

Then /^no results should be returned$/ do
  expect(on(AwardLookup).results_text).to include 'No values match this search'
end

When /^the unassigned user visits the Award$/  do
  steps "* I'm logged in with unassigneduser"
  @award.view :award
end

Then /^an error notification will indicate that the user cannot access the Award$/ do
  expect(on(Award).exception_errors).to include "user 'unassigneduser' is not authorized to open document '#{@award.document_id}'"
  expect(@browser.html).to include "user 'unassigneduser' is not authorized to open document '#{@award.document_id}'"
end