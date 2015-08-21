# coding: UTF-8
class BasePage < PageFactory

  action(:use_new_tab) { |b| b.windows.last.use }
  action(:return_to_portal_window) { |b| b.portal_window.use }
  action(:close_extra_windows) { |b| b.close_children if b.windows.length > 1 }
  action(:close_children) { |b| b.windows[0].use; b.windows[1..-1].each{ |w| w.close} }
  action(:close_parents) { |b| b.windows[0..-2].each{ |w| w.close} }
  action(:loading_old) { |b| b.frm.image(alt: 'working...').wait_while_present }
  action(:loading) { |b| b.image(alt: 'Loading...').wait_while_present }
  element(:return_to_portal_button) { |b| b.frm.button(title: 'Return to Portal') }
  action(:awaiting_doc) { |b| b.return_to_portal_button.wait_while_present }
  action(:processing_document) { |b| b.frm.div(text: /The document is being processed. You will be returned to the document once processing is complete./ ).wait_while_present }

  element(:logout_button) { |b| b.button(value: 'Logout') }
  action(:logout) { |b| b.logout_button.click }

  element(:portal_window) { |b| b.windows(title: 'Kuali Portal Index')[0] }

  action(:form_tab) { |name, b| b.frm.h2(text: /#{name}/) }
  action(:form_status) { |name, b| b.form_tab(name).text[/(?<=\()\w+/] }
  element(:save_button) { |b| b.frm.button(name: 'methodToCall.save') }
  value(:notification) { |b| b.frm.div(class: 'left-errmsg').div.text }

  element(:workarea_div) { |b| b.frm.div(id: 'workarea') }
  element(:workarea_div_new) { |b| b.frm.div(id: 'Uif-Application') }

  value(:htm) { |b| b.frm.html }
  value(:noko) { |b| WatirNokogiri::Document.new(b.htm) }
  value(:no_frame_noko) { |b| WatirNokogiri::Document.new(b.html) }

  class << self

    # Overrides the method in PageFactory
    # The idea here is to see if we can improve test reliability
    # by retrying a page load when an expected element doesn't appear
    # the first time, or when a modal dialog is present...
    def expected_element element_name, timeout=30
      define_method 'expected_element' do
        begin
          self.send(element_name).wait_until_present timeout
        rescue
          sleep 10
          self.refresh
          self.send(element_name).wait_until_present timeout
        end
      end
    end

    def glbl(*titles)
      titles.each do |title|
        action(damballa(title)) { |b| b.frm.button(class: 'globalbuttons', title: title).click; b.loading }
      end
    end

    # New UI. Don't use in Page Classes for 5.x...
    def document_buttons
      action(:back) { |b| b.button(data_submit_data: '{"methodToCall":"navigate","actionParameters[navigateToPageId]":"PropDev-OrganizationLocationsPage"}').click }
      buttons 'Save', 'Save and Continue', 'Close', 'Cancel'
    end

    def document_header_elements
      value(:doc_title) { |b| b.headerarea.h1.text.gsub(/\W+$/,'') }
      value(:headerinfo_table) { |b| b.noko.div(id: 'headerarea').table(class: 'headerinfo') }
      value(:document_id) { |p| p.headerinfo_table[0].text[/\d{5}/] }
      alias_method :doc_nbr, :document_id
      value(:document_status) { |p| p.headerinfo_table[0][3].text[/(?<=:)?.+$/] }
      value(:initiator) { |p| p.headerinfo_table[1][1].text }
      alias_method :disposition, :initiator
      value(:last_updated) {|p| p.headerinfo_table[1][3].text }
      alias_method :created, :last_updated
      alias_method :submission_status, :last_updated
      value(:committee_id) { |p| p.headerinfo_table[2][1].text }
      alias_method :sponsor_name, :committee_id
      alias_method :budget_name, :committee_id
      alias_method :protocol_number, :committee_id
      value(:committee_name) { |p| p.headerinfo_table[2][3].text }
      alias_method :pi, :committee_name
      alias_method :expiration_date, :committee_name
      element(:headerarea) { |b| b.noko.div(id: 'headerarea') }
      value(:headerinfo_table_no_frame) { |b| b.headerarea.table(class: 'headerinfo') }

    end

    def new_doc_header
      element(:title_element) { |b| b.h1(id: /header/).span(class: 'uif-headerText-span') }
      value(:document_title) { |b| b.title_element.text }
      value(:section_header) { |b| b.no_frame_noko.h3.span(class: 'uif-headerText-span').text }
      action(:more) { |b| b.link(text: 'more...').click }
      value(:document_id) { |b| b.no_frame_noko.div(data_label: 'Doc Nbr').p.text }
      value(:document_status) { |b| b.no_frame_noko.div(data_label: 'Status').p.text }
      value(:created) { |b| b.no_frame_noko.div(data_label: 'Created').p.text }
      value(:initiator) { |b| b.no_frame_noko.div(data_label: 'Initiator').text }
      value(:proposal_number) { |b| b.no_frame_noko.div(data_label: 'Proposal Nbr').text }
    end

    # Included here because this is such a common field in KC
    def description_field
      element(:description) { |b| b.frm.text_field(name: 'document.documentHeader.documentDescription') }
      element(:description_no_frm) { |b| b.text_field(name: 'document.documentHeader.documentDescription') }
    end

    def global_buttons
      glbl 'Reject', 'blanket approve', 'close', 'cancel', 'reload',
           'Delete Proposal', 'disapprove',
           'Generate All Periods', 'Calculate All Periods', 'Default Periods',
           'Calculate Current Period', 'Send Notification'
      action(:save) { |b| b.save_button.when_present.click; b.loading }
      action(:submit){ |b| b.frm.button(title: 'submit').when_present.click; b.loading; b.awaiting_doc }
      action(:submit_button){ |b| b.frm.button(title: 'submit') }
      element(:approve_button) { |b| b.frm.button(name: 'methodToCall.approve') }
      action(:approve) { |b| b.approve_button.click; b.loading; b.awaiting_doc }
      # Explicitly defining the "recall" button to keep the method name at "recall" instead of "recall_current_document"...
      element(:recall_button) { |b| b.frm.button(class: 'globalbuttons', title: 'Recall current document') }
      action(:recall) { |b| b.recall_button.click; b.loading }
      action(:edit) { |b| b.edit_button.when_present(5).click; b.loading }
      element(:edit_button) { |b| b.frm.button(name: 'methodToCall.editOrVersion') }
      action(:delete_selected) { |b| b.frm.button(class: 'globalbuttons', name: 'methodToCall.deletePerson').click; b.loading }
      element(:send_button) { |b| b.frm.button(class: 'globalbuttons', name: 'methodToCall.sendNotification', title: 'send') }
      action(:send_it) { |b| b.send_button.click }
      action(:send_fyi) { |b| b.send_button.click; b.loading; b.awaiting_doc }
    end

    def tab_buttons                                                                        #DEBUG
      action(:expand_all) { |b| b.frm.button(name: 'methodToCall.showAllTabs').when_present(180).click; b.loading; b.loading_old }
      element(:expand_all_button) { |b| b.frm.button(name: 'methodToCall.showAllTabs') }
      element(:show_button) { |b| b.button(src: '/kc-dev/kr/static/images/tinybutton-show.gif') }
    end

    def tiny_buttons
      action(:search) { |b| b.frm.button(name: 'methodToCall.search', title: 'search').click; b.loading }
      action(:clear) { |b| b.frm.button(name: 'methodToCall.clearValues').click; b.loading }
      action(:cancel_button) { |b| b.frm.link(title: 'cancel').click; b.loading }
      action(:yes) { |b| b.frm.button(name: 'methodToCall.rejectYes').click; b.loading }
      action(:no) {|b| b.frm.button(name: 'methodToCall.rejectNo').click; b.loading }
      action(:add) { |b| b.frm.button(name: 'methodToCall.addNotificationRecipient.anchor').click; b.loading }
    end

    def results_multi_select
      action(:select_all_from_all_pages) { |b| b.frm.button(title: 'Select all rows from all pages').click }
      action(:select_all_from_this_page) { |b| b.frm.button(title: 'Select all rows from this page').click }
      action(:return_selected) { |b| b.frm.button(title: 'Return selected results').click; b.loading }
      p_action(:check_item) { |item, b| b.item_row(item).checkbox.set }
      action(:select_random_checkbox) { |b| b.frm.tbody.checkboxes.to_a.sample.set }
      action(:return_random_checkbox) { |b| b.select_random_checkbox; b.return_selected }
      p_action(:check_item_title) { |item, b| b.item_row_title(item).checkbox.set }
    end

    def budget_header_elements
      links 'Data Validation', 'Budget Settings', 'Summary', 'Budget Versions', 'Autocalculate Periods'
      buttons 'Recalculate with changes', 'Reset to period defaults', '« Return to proposal'
    end

    def budget_versions_elements
      element(:name) { |b| b.frm.text_field(name: 'newBudgetVersionName') }
      action(:add) { |b| b.frm.button(name: 'methodToCall.addBudgetVersion').click }
      action(:version) { |budget, p| p.budgetline(budget).td(class: 'tab-subhead', index: 2).text }
      action(:direct_cost) { |budget, p| p.budgetline(budget).td(class: 'tab-subhead', index: 3).text }
      action(:f_and_a) { |budget, p| p.budgetline(budget).td(class: 'tab-subhead', index: 4).text }
      action(:total) { |budget, p| p.budgetline(budget).td(class: 'tab-subhead', index: 5).text }
      # Called "budget status" to avoid method collision...
      action(:budget_status) { |budget, p| p.budgetline(budget).select(title: 'Budget Status') }
      action(:open) { |budget, p| p.budgetline(budget).button(alt: 'open budget').click }
      action(:copy) { |budget, p| p.budgetline(budget).button(alt: 'copy budget').click }
      action(:f_and_a_rate_type) { |budget, p| p.budget_table(budget)[0][3].text }
      action(:cost_sharing) { |budget, p| p.budget_table(budget)[1][1].text }
      action(:budget_last_updated) { |budget, p| p.budget_table(budget)[1][3].text }
      action(:unrecovered_f_and_a) { |budget, p| p.budget_table(budget)[2][1].text }
      action(:last_updated_by) { |budget, p| p.budget_table(budget)[2][3].text }
      action(:comments) { |budget, p| p.budget_table(budget)[3][1].text }

      private
      element(:b_v_table) { |b| b.frm.table(id: 'budget-versions-table') }
      action(:budgetline) { |budget, p| p.b_v_table.td(class: 'tab-subhead', text: budget).parent }
      action(:budget_table) { |budget, p| p.b_v_table.tbodys[p.target_index(budget)].table }
      action(:target_index) do |budget, p|
        i=p.b_v_table.tbodys.find_index { |tbody| tbody.td(class: 'tab-subhead', index: 1).text==budget }
        i+1
      end
    end

    def protocol_header_elements
      buttons_frame 'Proposal', 'S2S', 'Key Personnel', 'Special Review', 'Custom Data',
              'Abstracts and Attachments', 'Questions', 'Budget Versions', 'Permissions',
              'Proposal Summary', 'Proposal Actions', 'Medusa'

      element(:header_table) { |b| b.frm.table(class: 'headerinfo') }
    end

    def special_review
      element(:add_type) { |b| b.frm.select(id: 'specialReviewHelper.newSpecialReview.specialReviewTypeCode') }
      value(:type_list) { |b| b.noko.select(id: 'specialReviewHelper.newSpecialReview.specialReviewTypeCode').options.map {|opt| opt.text }[1..-1] }
      value(:approval_status_list) {|b| b.noko.select(id: 'specialReviewHelper.newSpecialReview.approvalTypeCode').options.map {|opt| opt.text }[1..-1] }
      element(:add_approval_status) { |b| b.frm.select(id: 'specialReviewHelper.newSpecialReview.approvalTypeCode') }
      element(:add_protocol_number) { |b| b.frm.text_field(id: 'specialReviewHelper.newSpecialReview.protocolNumber') }
      element(:add_application_date) { |b| b.frm.text_field(id: 'specialReviewHelper.newSpecialReview.applicationDate') }
      element(:add_approval_date) { |b| b.frm.text_field(id: 'specialReviewHelper.newSpecialReview.approvalDate') }
      element(:add_expiration_date) { |b| b.frm.text_field(id: 'specialReviewHelper.newSpecialReview.expirationDate') }
      element(:add_exemption_number) { |b| b.frm.select(id: 'specialReviewHelper.newSpecialReview.exemptionTypeCodes') }
      alias_method :add_exemption, :add_exemption_number
      action(:add) { |b| b.frm.button(name: 'methodToCall.addSpecialReview.anchorSpecialReview').click }

      p_element(:type_code) { |index, b| b.frm.select(id: /specialReviews\[#{index}\].specialReviewTypeCode/) }
      p_element(:approval_status)  { |index, b| b.frm.select(name: /specialReviews\[#{index}\].approvalTypeCode/) }

      value(:types) { |b| b.frm.selects(id: /specialReviewTypeCode/).map{ |field| field.selected_options[0].text }.delete_at(0) }

      #added lines
      p_element(:type_added) { |index, b| b.frm.select(name: "document.protocolList[0].specialReviews[#{index}].specialReviewTypeCode") }
      p_element(:approval_status_added) { |index, b| b.frm.select(name: "document.protocolList[0].specialReviews[#{index}].approvalTypeCode") }
      p_element(:protocol_number_added) { |index, b| b.frm.text_field(name: "document.protocolList[0].specialReviews[#{index}].protocolNumber") }
      p_element(:application_date_added) { |index, b| b.frm.text_field(name: "document.protocolList[0].specialReviews[#{index}].applicationDate") }
      p_element(:approval_date_added) { |index, b| b.frm.text_field(name: "document.protocolList[0].specialReviews[#{index}].approvalDate") }
      p_element(:expiration_date_added) { |index, b| b.frm.text_field(name: "document.protocolList[0].specialReviews[#{index}].expirationDate") }
      p_element(:exemption_number_added) { |index, b| b.frm.select(name: "document.protocolList[0].specialReviews[#{index}].exemptionTypeCodes") }
      alias_method :exemption_added, :exemption_number_added
      p_element(:comments_added) { |index, b| b.frm.textarea(name: "document.protocolList[0].specialReviews[#{index}].comments") }

      p_action(:delete) { |index, b| b.frm.button(name: "methodToCall.deleteSpecialReview.line#{index}.anchor0.validate0").click }
    end

    # TODO: Remove this, as it is old UI stuff...
    def custom_data
      element(:graduate_student_count) { |b| b.target_row('Graduate Student Count').text_field }
      element(:billing_element) { |b| b.target_row('Billing Element').text_field }
      element(:asdf_tab) { |b| b.frm.div(id: 'tab-asdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdf-div') }
      action(:target_row) { |text, b| b.frm.trs(class: 'datatable').find { |row| row.text.include? text } }
    end

    def route_log
      element(:route_log_iframe) { |b| b.frm.frame(name: 'routeLogIFrame') }
      element(:actions_taken_table) { |b| b.route_log_iframe.div(id: 'tab-ActionsTaken-div').table }
      value(:actions_taken) { |b| (b.actions_taken_table.rows.collect{ |row| row[1].text }.compact.uniq).reject{ |action| action==''} }
      element(:pnd_act_req_table) { |b| b.route_log_iframe.div(id: 'tab-PendingActionRequests-div').table }
      value(:action_requests) { |b| (b.pnd_act_req_table.rows.collect{ |row| row[1].text}).reject{ |action| action==''} }
      action(:show_future_action_requests) { |b| b.route_log_iframe.h2(text: 'Future Action Requests').parent.parent.image(title: 'show').click }
      element(:future_actions_table) { |b| b.route_log_iframe.div(id: 'tab-FutureActionRequests-div').table }
      action(:requested_action_for) { |name, b| b.future_actions_table.tr(text: /#{Regexp.escape(name)}/).td(index: 2).text }
    end

    # Gathers all errors on the page and puts them in an array called "errors"
    def error_messages
      value(:errors) do |b|
        errs = []
        b.left_errmsg_tabs.each do |div|
          if div.div.div.exist?
            errs << div.div.divs.collect{ |div| div.text }
          elsif div.li.exist?
            errs << div.lis.collect{ |li| li.text }
          end
        end
        b.left_errmsg.each do |div|
          if div.div.div.exist?
            errs << div.div.divs.collect{ |div| div.text }
          elsif div.li.exist?
            errs << div.lis.collect{ |li| li.text }
          end
        end
        errs.flatten
      end
      value(:left_errmsg_tabs) { |b| b.noko.divs(class: 'left-errmsg-tab') }
      value(:left_errmsg) { |b| b.noko.divs(class: 'left-errmsg') }
      value(:error_messages_div) { |b| b.noko.div(class: 'error') }
    end

    def new_error_messages
      value(:errors) { |b| b.error_lis.map { |li| li.text } }
      element(:error_lis) { |b| b.no_frame_noko.lis(class: 'uif-errorMessageItem') }
    end

    def validation_elements
      element(:validation_button) { |b| b.frm.button(name: 'methodToCall.activate') }
      action(:show_data_validation) { |b| b.frm.button(id: 'tab-DataValidation-imageToggle').click; b.validation_button.wait_until_present }
      action(:turn_on_validation) { |b| b.validation_button.click; b.loading; b.loading_old; b.turn_off_validation_button.wait_until_present }

      element(:turn_off_validation_button) { |b| b.frm.button(name: 'methodToCall.deactivate') }
      action(:turn_off_validation) { |b| b.turn_off_validation_button.click; b.turn_off_validation_button.wait_while_present; b.loading }

      element(:validation_errors_and_warnings) { |b| errs = []; b.validation_err_war_fields.each { |field| errs << onespace(field.html[/(?<=>).*(?=<)/]) }; errs }
      element(:validation_err_war_fields) { |b| b.frm.tds(width: '94%') }
    end

    def combined_credit_splits
      {
          'responsibility'=>1,
          'financial'=>2
      }.each do |key, value|
        # Makes methods for the person's 4 credit splits (doesn't have to take the full name of the person to work)
        # Example: page.responsibility('Joe Schmoe').set '100.00'
        action(key.to_sym) { |name, b| b.credit_split_div_table.row(text: /#{Regexp.escape(name)}/)[value].text_field }
        # Makes methods for the person's units' credit splits
        # Example: page.unit_financial('Jane Schmoe', 'Unit').set '50.0'
        action("unit_#{key}".to_sym) { |full_name, unit_name, p| p.target_unit_row(full_name, unit_name)[value].text_field }
      end
    end

    # ========
    private
    # ========

    # Don't use this with links that are contained in the iframes...
    # Also: Only use when there is no need to wait for the loading image...
    # TODO: Reconsider whether or not this needs to just use #elementate
    def links(*links_text)
      links_text.each { |link| elementize(:link, link) }
    end

    def buttons(*buttons_text)
      buttons_text.each { |button| elementate(:button, button) }
    end

    def buttons_frame(*buttons_text)
      # for buttons with a frame element
      buttons_text.each { |button| elementate(:button, button, true) }
    end
    # Use this to define methods to click on the green
    # buttons on the page, all of which can be identified
    # by the title tag. The method takes a hash, where the key
    # will become the method name, and the value is the string
    # that matches the green button's link title tag.
    def green_buttons(links={})
      links.each_pair do |name, title|
        action(name) { |b| b.frm.link(title: title).click; b.loading }
      end
    end

    def black_buttons(links={})
      links.each_pair do |name, title|
        name_create = 'create_'+name.to_s
        name_search = 'search_'+name.to_s
        #create button (+) , example: :proposal_log
        action(name_create.to_sym) { |b| b.p(text: title).parent.link(class: 'uif-actionLink uif-boxLayoutHorizontalItem icon-plus icon-plus').click; b.loading }
        #search button, example: :search_proposal_log
        action(name_search.to_sym) { |b| b.p(text: title).parent.link(class: 'uif-actionLink uif-boxLayoutHorizontalItem icon-search icon-search').click; b.loading }
      end
    end

    def elementate(type, text, frame=false)
      el_name=damballa("#{text}_element")
      act_name=damballa(text)

      if frame
        #for the old UI with a frame element (aka: Non-Krad)
        element(el_name) { |b| b.frm.send(type, text: text) }
        action(act_name) { |b| b.frm.send(type, text: text).click; b.loading }
      else
        element(el_name) { |b| b.send(type, text: text) }
        action(act_name) { |b| b.send(type, text: text).click; b.loading }
      end

    end

    # Used for getting rid of the space and comma in the full name
    def nsp(string)
      string.gsub(/[ ,]/, '')
    end
    alias_method :nospace, :nsp

    # Used to add an extra space in the full name (because some
    # elements have that, annoyingly!)
    def twospace(string)
      string.gsub(' ', '  ')
    end

    def onespace(string)
      string.gsub('  ', ' ')
    end

    # Used by the Lead Unit field in CreateProposal
    def select(method_name, attrib, value)
      element(method_name) { |b| b.execute_script(%{jQuery("select[#{attrib}|='#{value}']").show();}) unless b.select(attrib => value).visible?; b.select(attrib => value) }
    end

  end # self

end # BasePage