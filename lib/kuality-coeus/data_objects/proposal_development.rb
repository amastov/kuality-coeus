class ProposalDevelopmentObject

  include Foundry
  include DataFactory
  include StringFactory
  include DateFactory
  include Navigation
  
  attr_accessor :description, :type, :lead_unit, :activity_type, :project_title,
                :sponsor_code, :start_date, :end_date, :explanation, :id, :status,
                :initiator, :created, :sponsor_deadline_date, :key_personnel,
                :special_review, :budget_versions, :permissions
  
  def initialize(browser, opts={})
    @browser = browser
    defaults = {
      description: random_alphanums,
      type: "New",
      lead_unit: :random,
      activity_type: :random,
      project_title: random_alphanums,
      sponsor_code: "000500",
      start_date: next_week[:date_w_slashes],
      end_date: next_year[:date_w_slashes],
      sponsor_deadline_date: next_week[:date_w_slashes],
      key_personnel: [],
      special_review: [],
      budget_versions: []
    }
    set_options(defaults.merge(opts))
  end
    
  def create
    visit(Researcher).create_proposal
    on Proposal do |doc|
      @id=doc.document_id
      @status=doc.status
      @initiator=doc.initiator
      @created=doc.created
      doc.expand_all
      doc.description.set @description
      doc.sponsor_code.set @sponsor_code
      @type=doc.proposal_type.pick @type
      @activity_type=doc.activity_type.pick @activity_type
      @lead_unit=doc.lead_unit.pick @lead_unit
      doc.project_title.set @project_title
      doc.project_start_date.set @start_date
      doc.project_end_date.set @end_date
      doc.explanation.set @explanation
      doc.sponsor_deadline_date.set @sponsor_deadline_date
      doc.save
    end
    person = make KeyPersonnelObject, document_id: @id
    person.create
    @key_personnel << person
    spec_review = make SpecialReviewObject, document_id: @id
    spec_review.create
    @special_review << spec_review
    budget = make BudgetVersionsObject, document_id: @id
    budget.create
    @budget_versions << budget
    @permissions = make PermissionsObject, document_id: @id, roles: { 'Aggregator'=>@initiator, 'approver'=>'lralph' }
  end
    
  def edit opts={}
    
    set_options(opts)
  end
    
  def view
    
  end
    
  def delete
    
  end
  
end
    
      