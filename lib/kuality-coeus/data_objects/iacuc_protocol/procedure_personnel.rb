class ProcedurePerson < DataFactory

  attr_reader :full_name, :assigned_procedures, :qualifications

  def initialize(browser, opts={})
    @browser = browser
    defaults = {
        assigned_procedures: []
    }
    set_options(defaults.merge(opts))
  end

  def add_procedure(procedure)
    # TODO: Add navigation
    on(IACUCProceduresPersonnel).edit_procedures(@full_name)
    on IACUCProceduresPersonnelDialogue do |page|
      #TODO: Support all groups, not just procedures...
      if procedure=='ALL'
        page.all_procedures
      else
        page.procedure(procedure).set
      end
      page.save
    end
    assigned_procedures << procedure
  end

  def remove_procedure(procedure)
    # TODO: Add navigation
    # TODO...
    assigned_procedures.delete(procedure)
  end

  def update_qualifications(text)
    # TODO: Add navigation
    on(IACUCProceduresPersonnel).edit_procedures(@full_name)
    on IACUCProceduresPersonnelDialogue do |page|
      page.qualifications.set text
      page.save
    end
    @qualifications=text
  end

end

class ProcedurePersonnelCollection < CollectionFactory

  contains ProcedurePerson

end