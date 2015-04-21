Then /^the IACUC Protocol (submission status|status) should be (.*)$/ do |status_field, status_message|
    @iacuc_protocol.view 'Protocol'
    @iacuc_protocol.gather_document_info
    expect(@iacuc_protocol.doc[damballa(status_field).to_sym]).to eq status_message
end

Then /^the summary will display the location of the procedure$/ do
  on(IACUCProcedures).select_procedure_tab 'summary'
  on IACUCProceduresSummary do |page|
    page.expand_all
    [:type, :room, :name, :description].each { |field| expect(page.summary_locations).to include @procedures.location[field].to_s}
  end
end

Then /^the edited location information should be displayed in the Procedure summary$/ do
  [:room, :name, :description].each { |field| expect(on(IACUCProceduresSummary).summary_locations).to include @procedures_edit.location[field].to_s}
end

Then /^the (first |second )location is not listed in the Procedure summary$/ do |count|
  procedure = {'first ' => '', 'second ' => '2'}
  on(IACUCProcedures).select_procedure_tab 'summary'
  on IACUCProceduresSummary do |page|
    page.expand_all
    [:room, :name, :description].each { |field| expect(page.summary_locations).to_not include get("@procedures#{procedure[count]}").location[field].to_s}
  end
end

And /^the (first |second )location is listed on the IACUC Protocol$/ do |count|
  procedure = {'first ' => '', 'second ' => '2'}
  on(IACUCProcedures).select_procedure_tab 'summary'
  on IACUCProceduresSummary do |page|
    page.expand_all
    [:type, :room, :name, :description].each { |field| expect(page.summary_locations).to include get("@procedures#{procedure[count]}").location[field].to_s}
  end
end

Then /^the expiration date is set for the Protocol$/ do
  expect(on(KCProtocol).expiration_date).to_not equal ''
  expect(on(KCProtocol).expiration_date).to_not equal nil
end

Then /^the (.*)Organization that was added should display on the IACUC Protocol$/ do |count|
  on IACUCProtocolOverview do |page|
    index = { '' => 1, 'first ' => 1, 'second ' => 2 }
    expect(page.added_organization_id_with_name(index[count])).to include @iacuc_protocol.organization.organization_id
  end
end

And /^the added Organization information should display on the inquiry page$/ do
  on(IACUCProtocolOverview).direct_inquiry(@iacuc_protocol.organization.organization_id)
  on OrganizationInquiry do |page|
    expect(page.organization_id).to eq @iacuc_protocol.organization.organization_id
    expect(page.address).to eq @iacuc_protocol.organization.organization_address
    expect(page.organization_name).to eq @iacuc_protocol.organization.organization_name
  end
end

Then /^on the IACUC Protocol the contact information for the added Organization is reverted$/ do
  on IACUCProtocolOverview do |page|
    page.expand_all
    expect(page.contact_address(@iacuc_protocol.organization.organization_id)).to eq @iacuc_protocol.organization.old_organization_address
  end
end

Then /^the group name, species, pain category, count type, species count should match the modified values$/ do
  line_item = 0
  on SpeciesGroups do |page|
    expect(page.group_added_value(line_item)).to eq @species.group
    expect(page.count_added_value(line_item)).to eq @species.count.to_s
    expect(page.species_added_value(line_item)).to eq @species.species
    expect(page.pain_category_added_value(line_item)).to eq @species.pain_category
    expect(page.count_type_added_value(line_item)).to eq @species.count_type
  end
end

Then /^the (.*) Species added should be the only Species on the IACUC Protocol$/ do |count|
  on SpeciesGroups do |page|
    index = {'second' => 0}
    if count == 'second'
      expect(page.group_added(index[count]).value).to_not eq @species.group
      expect(page.group_added(index[count]).value).to eq @species2.group
    else
      pending "Need to handle validation for #{count} Species"
    end
  end
end

Then /^(\d+ |the )?personnel members? added to the IACUC Protocol (is|are) present$/ do |count, isare|
  count == 'the ' ? counts = 1 : counts = count.to_i
  on ProtocolPersonnel do |page|
    while counts > 1
      expect(page.added_personnel_name((get("@personnel#{counts.to_s}")).full_name, get("@personnel#{counts.to_s}").protocol_role)).to exist
      counts -= 1
    end
    # Handle for '1' or 'the'
      expect(page.added_personnel_name(@personnel.full_name, @personnel.protocol_role)).to exist if counts <= 1
  end
end

Then /^the three principles should have the edited values after saving the IACUC Protocol$/ do
  on TheThreeRs do |page|
    page.save
    page.refresh
    @iacuc_protocol.view "The Three R's"
    principle = ['reduction', 'refinement', 'replacement']
    principle.each {|prince| expect(page.send(prince).value).to eq @iacuc_protocol.principles[prince.to_sym] }
    page.save

    principle.each do |prince|
      page.send("#{prince}_expand")
      page.continue_button.wait_until_present
      expect(page.send(prince).value).to eq @iacuc_protocol.principles[prince.to_sym]
      page.continue
    end
  end
end

Then /(first |second |)Special Review should (not |)be displayed on the IACUC Protocol$/ do |count, to_be_or_not_to_be|
  index = {'' => [0,''], 'first ' => [0,''], 'second ' => [1,'2'] }
  on SpecialReview do |page|
    page.reload
    on(Confirmation).yes if on(Confirmation).yes_button.present?
    if to_be_or_not_to_be == 'not '
      expect(page.type_added(index[count][0]).selected_options.first.text).to_not eq get("@special_review#{index[count][1]}").type
      expect(page.approval_status_added(index[count][0]).selected_options.first.text).to_not eq get("@special_review#{index[count][1]}").approval_status
    else
      expect(page.type_added(index[count][0]).selected_options.first.text).to eq get("@special_review#{index[count][1]}").type
      expect(page.approval_status_added(index[count][0]).selected_options.first.text).to eq get("@special_review#{index[count][1]}").approval_status
    end
  end
end

And /^the (first |)edited Special Review should display on the IACUC Protocol$/ do |count|
  index = {'' => 0, 'first ' => 0}
  on SpecialReview do |page|
    page.reload
    on(Confirmation).yes if on(Confirmation).yes_button.present?
    expect(page.type_added(index[count]).selected_options.first.text).to eq @special_review_edit.type
    expect(page.approval_status_added(index[count]).selected_options.first.text).to eq @special_review_edit.approval_status
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
    page.view_qualification(@personnel.full_name)
    expect(page.qualification_dialog).to include @procedures.qualifications
  end
end