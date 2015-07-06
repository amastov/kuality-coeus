class OrganizationObject < DataFactory

  include StringFactory, Protocol

  attr_reader  :organization_id, :organization_type, :clear_contact, :add_contact_info,
               :old_organization_address, :organization_address, :organization_name

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        organization_id: '::random::',
        organization_type: '::random::',
        press: 'save'
    }
    set_options(defaults.merge(opts))
  end

  def create
    # NOTE: Navigation is accomplished in the parent Protocol object!
    on IACUCProtocolOverview do |page|
      page.expand_all

      if @organization_id == '::random::'
        page.organization_lookup
        on OrganizationLookup do |lookup|
          lookup.search
          return_random_organization
        end
        @organization_id = page.organization_id.value.strip
      else
        page.organization_id.fit @organization_id
      end

      page.organization_type.pick! @organization_type
      page.add_organization
      page.send(@press) unless @press.nil?
    end
  end

  def return_random_organization
    on OrganizationLookup do |lookup|
    the_row = rand(lookup.return_value_links.length)
    #need to capture the organization data that will be selected
    @organization_id = lookup.return_value_links[the_row].parent.parent.td(index: 1).text.strip
    @organization_name = lookup.return_value_links[the_row].parent.parent.td(index: 2).text
    @organization_address = lookup.return_value_links[the_row].parent.parent.td(index: 3).text
    @federal_employer_id =  lookup.return_value_links[the_row].parent.parent.td(index: 4).text
    @congressional_district =  lookup.return_value_links[the_row].parent.parent.td(index: 5).text
    @contact_address_id =  lookup.return_value_links[the_row].parent.parent.td(index: 6).text
    lookup.return_value_links[the_row].click
    end
  end

  def clear_contact
    on IACUCProtocolOverview do |page|
      @old_organization_address = page.contact_address(@organization_id)
      page.clear_contact(@organization_id)
    end
  end

  def add_contact_info
    on(IACUCProtocolOverview).add_contact(@organization_id)
    on AddressBookLookup do |search|
      search.search
      search.return_random
    end

    on IACUCProtocolOverview do |page|
      @organization_address = page.contact_address(@organization_id)
    end
  end

end # OrganizationObject

class OrganizationCollection < CollectionsFactory

  contains OrganizationObject

end