class KCProtocol < BasePage

  document_header_elements
  tab_buttons
  global_buttons
  error_messages

  buttons_frame 'Protocol', 'Personnel', 'Questionnaire', 'Custom Data', 'Special Review',
          'Permissions', 'Notes & Attachments', 'Medusa', 'Online Review',
          "The Three R's", 'Species/Groups', 'Procedures', 'Protocol Exception', 'IACUC Protocol Actions', 'Protocol Actions'

  element(:application) { |b| b.frm.div(id: 'Uif-Application') }

  # This removes the methods created in the BasePage, because
  # the Protocol child classes need their own specialized versions...
  undefine :submit, :committee_id

  class << self
    def protocol_common
      # Required Fields
      element(:protocol_type) { |b| b.frm.select(name: 'document.protocolList[0].protocolTypeCode') }
      element(:title) { |b| b.frm.textarea(name: 'document.protocolList[0].title') }
      action(:pi_employee_search) { |b| b.frm.button(name: 'methodToCall.performLookup.(!!org.kuali.kra.bo.KcPerson!!).(((personId:protocolHelper.personId,fullName:protocolHelper.principalInvestigatorName,unit.unitNumber:protocolHelper.lookupUnitNumber,unit.unitName:protocolHelper.lookupUnitName))).((``)).((<>)).(([])).((**)).((^^)).((&&)).((//)).((~~)).(::::;;::::).anchor').click }
      element(:lead_unit) { |b| b.frm.text_field(name: 'protocolHelper.leadUnitNumber') }
      action(:find_lead_unit) { |b| b.frm.button(name: 'methodToCall.performLookup.(!!org.kuali.kra.bo.Unit!!).(((unitNumber:protocolHelper.leadUnitNumber,unitName:protocolHelper.leadUnitName))).((``)).((<>)).(([])).((**)).((^^)).((&&)).((//)).((~~)).(::::;;::::).anchor').click }

      # Additional Information
      action(:add_area_of_research) { |b| b.frm.button(name: 'methodToCall.performLookup.(!!org.kuali.kra.irb.ResearchArea!!).((``)).(:;protocolResearchAreas;:).((%true%)).((~~)).anchorAdditionalInformation').click }
      element(:fda_number) { |b| b.frm.text_field(name: 'document.protocolList[0].fdaApplicationNumber') }

      # Other Identifiers
      action(:identifier_type) { |b| b.frm.select(name: 'newProtocolReferenceBean.protocolReferenceTypeCode') }
      element(:identifier) { |b| b.frm.text_field(name: 'newProtocolReferenceBean.referenceKey') }
      element(:identifier_application_date) { |b| b.frm.text_field(name: 'newProtocolReferenceBean.applicationDate') }
      element(:identifier_approval_date) { |b| b.frm.text_field(name: 'newProtocolReferenceBean.approvalDate') }
      element(:identifier_comment) { |b| b.frm.textarea(name: 'newProtocolReferenceBean.comments') }
      action(:identifier_add) { |b| b.frm.button(name: 'methodToCall.addProtocolReferenceBean.anchorAdditionalInformation').click }

      # Organizations
      element(:organization_id) { |b| b.frm.text_field(name: 'protocolHelper.newProtocolLocation.organizationId') }
      action(:organization_lookup) { |b| b.frm.text_field(id: 'protocolHelper.newProtocolLocation.organizationId').parent.button(alt: 'Search ').click; b.loading }
      action(:organization_type) { |b| b.frm.select(name: 'protocolHelper.newProtocolLocation.protocolOrganizationTypeCode') }
      action(:add_organization) { |b| b.frm.button(name: 'methodToCall.addProtocolLocation.anchorOrganizations').click; b.loading }

      p_value(:contact_address) { |org_id, b| b.frm.div(align: 'left', text: /^#{org_id}/).parent.parent.td(index: 2).text }
      p_action(:clear_contact) { |org_id, b| b. frm.div(align: 'left', text: /^#{org_id}/).parent.parent.button(title: 'Clear organization address').click; b.loading }
      p_action(:add_contact) {|org_id, b| b.frm.div(align: 'left', text: /^#{org_id}/).parent.parent.td(index: 2).div.button(title: 'Search ').click; b.loading }

      p_element(:direct_inquiry_button) { |org_id,b| b.frm.div(align: 'left', text: /^#{org_id}/).button(alt: 'Direct Inquiry') }
      p_action(:direct_inquiry) { |org_id,b| b.direct_inquiry_button(org_id).click; b.use_new_tab}

      value(:organization_ids) { |b| b.noko.table(id: 'location-table').tbody(index: 2).hiddens(name: /organizationId/).map { |h| h.value } }

      #TODO: Create table options so that we can deal with the 'clear contact' and 'delete org' options.

      # Funding Sources
      element(:funding_type) { |b| b.frm.select(name: 'protocolHelper.newFundingSource.fundingSourceTypeCode') }
      element(:funding_number) { |b| b.frm.text_field(name: 'protocolHelper.newFundingSource.fundingSourceNumber') }
      action(:funding_number_lookup) { |b| b.frm.button(name: 'methodToCall.performFundingSourceLookup.(!!!!).((())).((``)).((<>)).(([])).((**)).((^^)).((&&)).((//)).((~~)).anchor28') }
      action(:add_funding_source) { |b| b.frm.button(name: 'methodToCall.addProtocolFundingSource.anchorFundingSources').click }
    end
  end  #self

end #KCProtocol