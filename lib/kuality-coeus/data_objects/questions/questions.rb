class QuestionsObject < DataFactory

  include StringFactory

  attr_reader :question, :category, :response_type, :answer_count, :possible_answers,
      :lookup_class, :lookup_field, :max_characters, :document_id, :question_id, :responses

  def initialize(browser, opts={})
    @browser = browser
    defaults = {
        question: random_alphanums(25),
        category: '::random::',
        response_type: 'Yes/No',
        responses: {},
        save_type: :blanket_approve
    }
    set_options(defaults.merge(opts))
  end

  def create
    on Header do |page|
      page.system_admin_portal
      page.use_new_tab
      page.close_parents
    end
    on(Maintenance).question
    on(QuestionLookup).create
    on Question do |page|
      page.description.set random_alphanums
      ordered_fill page, :question, :category, :response_type, :answer_count,
                   :max_characters, :possible_answers
      page.send(@save_type)
    end
    # We need to get the Question ID so it can be added to the Questionnaire
    on(Maintenance).question
    on QuestionLookup do |page|
      fill_out page, :question
      page.search
      @question_id = page.target_question_id
    end
  end

  def answer(name, response, page_class)
    case(@response_type)
      when 'Yes/No'
        on page_class do |page|
          page.answer(name, @question, response).set
        end
    end
    responses.store(name, response)
  end

end

class QuestionsCollection < CollectionsFactory

  contains QuestionsObject

end