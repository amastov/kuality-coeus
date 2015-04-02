class ProtocolPersonnelObject < DataFactory

  include StringFactory, Personnel

  attr_reader :first_name, :last_name, :full_name, :user_name,
              :role

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        type: 'employee'
    }

    set_options(defaults.merge(opts))
    requires :role
  end

  def create
    #adds a person to the protocol
    on ProtocolPersonnel do |page|
      page.employee_search if @type == 'employee'
      page.non_employee_search if @type == 'non-employee'
    end

    on KcPersonLookup do |lookup|
        lookup.last_name.fit @last_name
        lookup.first_name.fit @first_name
        lookup.user_name.fit @user_name
        lookup.search

        lookup.return_value(@full_name)
    end

    on ProtocolPersonnel do |page|
      page.protocol_role.fit @role
      page.add_person
      page.save
    end
  end

  private

  def page_class
    ProtocolPersonnel
  end

end

class ProtocolPersonnelCollection < CollectionsFactory

  contains ProtocolPersonnelObject

  include People

end