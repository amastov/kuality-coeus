class IACUCPersonnelObject <  DataFactory

  include StringFactory, DateFactory, Protocol

  attr_reader  :protocol_role, :kcperson_id, :full_name, :user_name, :email_address

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        protocol_role: ['Co-Investigator', 'Study Personnel', 'Correspondents'].sample
    }
    set_options(defaults.merge(opts))
  end

  def create
    view 'Personnel'
    on ProtocolPersonnel do |page|
      page.expand_all
      @added_people = page.added_people
      page.employee_search
    end
    on KcPersonLookup do |lookup|
      lookup.kcperson_id.fit @kcperson_id
      lookup.search
      if @kcperson_id
        # There should only be one item returned, so click it...
        lookup.return_value_links[0].click
      else
        return_random_person
      end
    end
    on ProtocolPersonnel do |page|
      page.protocol_role.pick @protocol_role
      page.add_person
      page.save
    end
  end

  def view(tab)
    raise 'Please pass a string for the Protocol\'s view method.' unless tab.kind_of? String
    on(KCProtocol).send(damballa(tab))
  end

  def return_random_person
    on KcPersonLookup do |lookup|
      the_row = lookup.return_value_links.to_a.sample.parent.parent
      while @added_people.include? the_row.tds[2].text
        the_row = lookup.return_value_links.to_a.sample.parent.parent
      end
      #need to capture the randomly select person data for validation and future use
      @kcperson_id = the_row.tds[1].text
      @full_name =the_row.tds[2].text
      @user_name = the_row.tds[3].text
      @email_address = the_row.tds[4].text
      lookup.return_value(@full_name)
    end
  end

end #IACUCPersonnel

class IACUCPersonnelCollection < CollectionsFactory

  contains IACUCPersonnelObject

  include People

end