class IACUCAmendmentObject < DataFactory

  include StringFactory

  attr_reader

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        summary: random_alphanums_plus,
        sections: [['General Info', 'Funding Source', 'Protocol References and Other Identifiers',
                    'Protocol Organizations', 'Questionnaire', 'General Info',
                    'Areas of Research', 'Special Review', 'Protocol Personnel', 'Others'].sample]
    }

    set_options(defaults.merge(opts))

  end

  def create
    # Navigation currently in the Protocol object's #add_amendent method.
    on CreateAmendment do |page|
      page.expand_all
      page.summary.set @summary
      @sections.each do |sect|
        page.amend(sect).set
      end
      page.create
    end
    confirmation('yes')
    on(NotificationEditor).send_it if on(NotificationEditor).send_button.present?
    on(CreateAmendment).save
    #Amendment has a different header with 9 fields instead of the normal 6 fields
    gather_document_info
    @amendment[:protocol_number] = @doc[:protocol_number]
    @amendment[:document_id] = @doc[:document_id]

    @document_id = on(IACUCProtocolActions).document_id
    on(IACUCProtocolOverview).send_it if on(IACUCProtocolOverview).send_button.present? #send notification
  end

  # For Amendment document with 9 header area fields
  def gather_document_info
    keys=[]
    values=[]
    @doc={}

    on IACUCProtocolOverview do |page|
      # collecting the keys from the header table
      page.frm.div(id: 'headerarea').ths.each {|k| keys << damballa(k.text) }
      # collecting the values from the header table
      page.frm.div(id: 'headerarea').tds.each {|v| values << v.text }
    end
    # turning the two arrays into a usable hash
    @doc = Hash[[keys, values].transpose]
    #removing empty key value pairs
    @doc.delete_if {|k,v| v.nil? or k==:"" }
  end

end