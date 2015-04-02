class SpecialReviewObject < DataFactory

  include StringFactory, Navigation

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
        approval_status: '::random::',
        press: 'save'
    }

    set_options(defaults.merge(opts))
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
      the_type_array =[]
      edit.add_type.options.each { |optns| the_type_array << optns.text }
      the_approval_status_array = []
      edit.approval_status_options.each { |stat| the_approval_status_array << stat.text }
      #need to remove the current type from array to ensure the proper edit
      current_type = edit.type_added(opts[:index]).selected_options.first.text
      opts[:type] = (the_type_array - ['select', 'Human Subjects', 'Animal Usage', current_type ]).sample if opts[:edit_type] == true

      #need to remove the current status from array to ensure the proper edit
      current_status = edit.approval_status_added(opts[:index]).selected_options.first.text
      opts[:approval_status] = (the_approval_status_array - ['select', current_status]).sample if opts[:edit_approval_status] == true

      edit.type_added(opts[:index]).pick! opts[:type]
      edit.approval_status_added(opts[:index]).pick! opts[:approval_status]
      edit.exemption_number_added(opts[:index]).pick! opts[:exemption_number]
      edit.protocol_number_added(opts[:index]).fit opts[:protocol_number]
      edit.application_date_added(opts[:index]).fit opts[:application_date]
      edit.approval_date_added(opts[:index]).fit opts[:approval_date]
      edit.expiration_date_added(opts[:index]).fit opts[:expiration_date]
      edit.send(opts[:press]) unless opts[:press].nil?
    end
    update_options(opts)
  end

  def view
    # Navigation assumes already on the document
    on(Proposal).special_review unless on_page?(on(SpecialReview).add_type)
  end

  def delete(line_index)
    index = {'first' => 0, 'second' => 1}
    on(SpecialReview).delete(index[line_index])
  end

  def update_from_parent(id)
    @document_id=id
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