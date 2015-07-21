Then /^the IACUC Protocol (submission status|status) should be (.*)$/ do |status_field, status_message|
  on(Header).researcher
  on(ResearcherMenu).search_proposals
  @iacuc_protocol.view 'Protocol'
  expect(on(IACUCProtocolOverview).send(damballa(status_field))).to eq status_message
end

Then /^the summary will display the location of the procedure$/ do
  on(IACUCProcedures).select_procedure_tab 'summary'
  on IACUCProceduresSummary do |page|
    page.expand_all
    [:type, :room, :name, :description].each { |field| expect(page.locations).to include @iacuc_protocol.procedures.locations[0].send(field) }
  end
end

Then /^the edited location information should be displayed in the Procedure summary$/ do
  on(IACUCProcedures).select_procedure_tab 'summary'
  [:room, :name, :description].each { |field|
    expect(on(IACUCProceduresSummary).locations).to include @iacuc_protocol.procedures.locations[0].send(field)
  }
end

Then /^the (first |second )location is not listed in the Procedure summary$/ do |count|
  location = {'first ' => 0, 'second ' => 1}
  on(IACUCProcedures).select_procedure_tab 'summary'
  on IACUCProceduresSummary do |page|
    page.expand_all
    [:room, :name, :description].each { |field| expect(page.locations).to_not include @iacuc_protocol.procedures.locations[location[count]].send(field) }
  end
end

And /^the (first |second )location is listed on the IACUC Protocol$/ do |count|
  procedure = {'first ' => 0, 'second ' => 1}
  on(IACUCProcedures).select_procedure_tab 'summary'
  on IACUCProceduresSummary do |page|
    page.expand_all
    [:type, :room, :name, :description].each { |field| expect(page.locations).to include @iacuc_protocol.procedures.locations[procedure[count]].send(field) }
  end
end

Then /^the expiration date is set for the Protocol$/ do
  expect(on(KCProtocol).expiration_date).to_not equal ''
  expect(on(KCProtocol).expiration_date).to_not equal nil
end

Then /^the Organization that was added should display on the IACUC Protocol$/ do
  on IACUCProtocolOverview do |page|
    @iacuc_protocol.organizations.each { |org|
      expect(page.organization_ids).to include org.organization_id
    }
  end
end

And /^the added Organization information should display on the inquiry page$/ do
  on(IACUCProtocolOverview).direct_inquiry(@iacuc_protocol.organizations.last.organization_id)
  on OrganizationInquiry do |page|
    expect(page.organization_id).to eq @iacuc_protocol.organizations.last.organization_id
    expect(page.address).to eq @iacuc_protocol.organizations.last.organization_address
    expect(page.organization_name).to eq @iacuc_protocol.organizations.last.organization_name
    page.close_direct_inquiry
  end
end

Then /^on the IACUC Protocol the contact information for the added Organization is reverted$/ do
  on IACUCProtocolOverview do |page|
    page.expand_all
    expect(page.contact_address(@iacuc_protocol.organizations.last.organization_id)).to eq @iacuc_protocol.organizations.last.old_organization_address
  end
end

Then /^the group name, species, pain category, count type, species count should match the modified values$/ do
  line = 0
  species = @iacuc_protocol.species_groups[line]
  on SpeciesGroups do |page|
    expect(page.group_added_value(line)).to eq species.group
    expect(page.count_added_value(line)).to eq species.count.to_s
    expect(page.species_added_value(line)).to eq species.species
    expect(page.pain_category_added_value(line)).to eq species.pain_category
    expect(page.count_type_added_value(line)).to eq species.count_type
  end
end

Then /^the second Species added should be the only Species on the IACUC Protocol$/ do
  on SpeciesGroups do |page|
    expect(page.group_added(0).value).to eq @iacuc_protocol.species_groups[0].group
  end
end

Then /^the personnel members? added to the IACUC Protocol (is|are) present$/ do |x|
  on ProtocolPersonnel do |page|
    @iacuc_protocol.personnel.each do |person|
      expect(page.added_people).to include person.full_name
    end
  end
end

Then /^the three principles should have the edited values$/ do
  visit Landing
  @iacuc_protocol.view "The Three R's"
  on TheThreeRs do |page|
    [:reduction, :refinement, :replacement].each { |principle|
      expect(page.send(principle).value).to eq @iacuc_protocol.send(principle)
    }
  end
end

Then /(first |second |)Special Review should (not |)be updated on the IACUC Protocol$/ do |count, to_be_or_not_to_be|
  index = {'' => 0, 'first ' => 0, 'second ' => 1 }
  on SpecialReview do |page|
    page.reload
    confirmation
    if to_be_or_not_to_be == 'not '
      expect(page.type_added(index[count]).selected_options.first.text).to_not eq @iacuc_protocol.special_review[index[count]].type
      expect(page.approval_status_added(index[count]).selected_options.first.text).to_not eq @iacuc_protocol.special_review[index[count]].approval_status
    else
      expect(page.type_added(index[count]).selected_options.first.text).to eq @iacuc_protocol.special_review[index[count]].type
      expect(page.approval_status_added(index[count]).selected_options.first.text).to eq @iacuc_protocol.special_review[index[count]].approval_status
    end
  end
end

# ----
# Procedures Tab
# ----

#assusmes we are already on the Procedures tab
And /reloads? the IACUC Protocol to the procedures summary tab$/ do
  on(IACUCProcedures).reload
  on(Confirmation).yes if on(Confirmation).yes_button.present?
  on(IACUCProcedures).select_procedure_tab 'summary'
  on(IACUCProceduresSummary).expand_all
end

Then /^the procedures summary will display qualifications for the personnel$/ do
  on(IACUCProcedures).select_procedure_tab 'summary'
  on IACUCProceduresSummary do |page|
    page.view_qualification(@iacuc_protocol.procedures.personnel[0].full_name)
    expect(page.qualification_dialog).to include @iacuc_protocol.procedures.personnel[0].qualifications
  end
end

Then /^the IACUC Administrator cannot delete the Protocol$/ do
  steps '* log in with the IACUC Administrator user'
  @iacuc_protocol.view 'IACUC Protocol Actions'
  expect(on(IACUCProtocolActions).unavailable_actions).to include 'Delete Protocol, Amendment, or Renewal'
end