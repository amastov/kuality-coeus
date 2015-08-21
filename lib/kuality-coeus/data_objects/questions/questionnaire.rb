class QuestionnaireObject < DataFactory

  include StringFactory

  attr_reader :name, :questions, :module, :module_sub_item_code, :rule_id,
              :mandatory, :label, :version, :id

  def initialize(browser, opts={})
    @browser = browser
    # TODO: Make this more flexible
    # Currently it's only designed to work with existing Questionnaires.
    # It will need to be tweaked to allow for the creation of a new questionnaire.
        opts[:questions] = collection('Questions')
        opts[:qs].each { |q| opts[:questions] << make(QuestionsObject, q) }
        opts.tap { |o| o.delete(:qs) }
        set_options(opts)
        @page_class = Object.const_get(@page_class)
  end

  def create
    # TODO
  end

  def answer_for(person, answer)
    @questions.each { |q|
        q.answer(person, answer, @page_class) unless q.responses.keys.include? person
      }
    on(@page_class).save
  end

  def add_question(opts={})
    defaults = {
       category: QUESTION_CATEGORY[@module_sub_item_code]
    }
    @questions.add defaults.merge(opts)
    view
    on Questionnaire do |page|
      page.description.set random_alphanums
      page.add_question
    end
    on QuestionLookup do |page|
      page.question_id.set @questions.last.question_id
      page.search
      page.check_item @questions.last.question_id
      page.return_selected
    end
    # FIXME: Figure out why this needs to be here:
    sleep 3
    # FIXME: We probably eventually don't want to have a blanket approve here...
    on(Questionnaire).blanket_approve
  end

  def view
    visit Landing
    on Header do |page|
      page.system_admin_portal
      page.use_new_tab
      page.close_parents
    end
    on(Maintenance).questionnaire
    on QuestionnaireLookup do |page|
      page.questionnaire_id.set @id
      page.search
      page.edit_first_item
    end
    on(Questionnaire).expand_all
  end

  # TODO: support the hierarchy feature...
  def clean
    case(@name)
      when 'Proposal Person Certification'
        default_questions = YAML.load_file("#{File.dirname(__FILE__)}/../questions/questionnaires.yml")[:proposal_person_cert][:qs]
        ppc_questions = default_questions.map { |dq| dq[:question] }
        view
        on Questionnaire do |page|
          page.description.set random_alphanums
          if @questions.size > default_questions.size
            @questions[2..-1].each do |question|
              page.expand_question(question.question)
              page.remove_question(question.question)
            end
          end
          if page.questions.size > default_questions.size
            page.questions.each do |question|
              page.expand_question(question)
              page.remove_question(question) unless ppc_questions.include? question
            end
          end
          # TODO: Need to add logic here that replaces questions if they are lost...
          page.blanket_approve
        end
      else
        raise 'Not a cleanable Questionnaire. Your scenario needs fixing'
    end
  end

  QUESTION_CATEGORY = {
      'Proposal Person Certification' => 'Certifications for Proposal Development'
  }

end