class QuestionnaireObject < DataFactory

  include StringFactory

  attr_reader :inventor, :rights, :non_university_investigators, :position_0

  def initialize(browser, opts={})
    @browser = browser
    defaults = {
        inventor: 'Y',
        rights:   'Y',
        non_university_investigators: 'N',
        position_0: random_alphanums_plus
    }
    set_options(defaults.merge(opts))
    requires :navigate
  end

  def create
    view
    on Questions do |cq|
      ordered_fill cq, :inventor, :rights, :non_university_investigators, :position_0
      # TODO: Add more position fields...
      cq.save_and_continue
    end
  end

  def view
    @navigate.call
    on(ProposalSidebar).questionnaire unless on(Questions).header_span.present?
  end

end