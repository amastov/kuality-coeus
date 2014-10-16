class ComplianceObject < DataFactory

  include StringFactory

  attr_reader :type, :approval_status, :document_id, :protocol_number,
              :application_date, :approval_date, :expiration_date,
              :exemption_number, :doc_type

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
                      # Subset of drop-down selection, excluding Human Subjects and Animal Usage,
                      # because those options require special handling.
      type:            ['Recombinant DNA','Biohazard Materials','International Programs','Space Change',
                        'TLO Review - No conflict (A)','TLO review - Reviewed, no conflict (B1)',
                        'TLO Review - Potential Conflict (B2)','TLO PR-Previously Reviewed','Foundation Relations'
                        ].sample,
      approval_status: '::random::'
    }

    set_options(defaults.merge(opts))
  end

  def create
    view
    on(Compliance).add_compliance_entry
    on AddNewProtocol do |add|
      fill_out add, :type, :approval_status, :protocol_number,
               :application_date, :approval_date, :expiration_date

      # TODO: add.add_exemption_number.fit @exemption_number

      add.add_entry
    end
    on(Compliance).save
  end

  def edit opts={}
    view
    # TODO
    set_options(opts)
  end

  def view
    @navigate.call
    on(ProposalSidebar).compliance unless on(Compliance).add_compliance_entry_element.present?
  end

  def update_from_parent(id)
    @document_id=id
  end

end # ComplianceObject

class ComplianceCollection < CollectionsFactory

  contains ComplianceObject

  def types
    self.collect { |s_r| s_r.type }
  end

  def statuses
    self.collect { |s_r| s_r.approval_status }
  end

  # A warning about this method:
  # it's going to return the FIRST match in the collection,
  # under the assumption that there won't be multiple
  # Compliance items of the same type.
  def type(srtype)
    self.find { |s_r| s_r.type==srtype}
  end

end # ComplianceCollection