class SpecialReviewObject < DataFactory

  include StringFactory, Utilities

  attr_reader :type, :approval_status, :document_id, :protocol_number,
              :application_date, :approval_date, :expiration_date,
              :exemption_number, :doc_type, :index

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        # Subset of drop-down selection, excluding Human Subjects and Animal Usage,
        # because those options require special handling.
        type:            ['Recombinant DNA', 'Radioactive Isotopes', 'Biohazard Materials',
                          'International Programs', 'Intellectual Property/Tech Transfer',
                          'Foundation Relations', 'Other'].sample,
        approval_status: '::random::',
        press: 'save'
    }

    set_options(defaults.merge(opts))
    requires :navigate, :index
  end

  def create
    view
    on SpecialReview do |add|
      add.add_type.pick! @type
      add.add_approval_status.pick! @approval_status
      add.add_protocol_number.fit @protocol_number
      add.add_application_date.fit @application_date
      add.add_approval_date.fit @approval_date
      add.add_expiration_date.fit @expiration_date
      add.add_exemption_number.pick! @exemption_number
      add.add
      add.send(@press) unless @press.nil?
    end
  end

  def edit opts={}
    view
    on SpecialReview do |edit|
      opts[:type] = (edit.type_list - ['select', 'Human Subjects', 'Animal Usage', @type]).sample if opts[:type]=='::random::'
      opts[:approval_status] = (edit.approval_status_list - [@approval_status]).sample if opts[:approval_status]=='::random::'
      edit.type_added(@index).pick! opts[:type]
      edit.approval_status_added(@index).pick! opts[:approval_status]
      edit.exemption_number_added(@index).pick! opts[:exemption_number]
      edit.protocol_number_added(@index).fit opts[:protocol_number]
      edit.application_date_added(@index).fit opts[:application_date]
      edit.approval_date_added(@index).fit opts[:approval_date]
      edit.expiration_date_added(@index).fit opts[:expiration_date]
      update_options(opts)
      edit.send(@press) unless @press.nil?
    end
  end

  def view
    @navigate.call
    on(Proposal).special_review unless on_page?(on(SpecialReview).add_type)
  end

  def delete(line_index)
    index = {'first' => 0, 'second' => 1}
    on(SpecialReview).delete(index[line_index])
  end

  def update_from_parent(navigation_lambda)
    @navigate=navigation_lambda
  end

end # SpecialReviewObject

class SpecialReviewCollection < CollectionsFactory

  contains SpecialReviewObject

  def types
    self.collect { |s_r| s_r.type }
  end

  def statuses
    self.collect { |s_r| s_r.approval_status }
  end

  # A warning about this method:
  # it's going to return the FIRST match in the collection,
  # under the assumption that there won't be multiple
  # Special Review items of the same type.
  def type(srtype)
    self.find { |s_r| s_r.type==srtype}
  end

end # SpecialReviewCollection