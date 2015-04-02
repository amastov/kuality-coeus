class UserRoleObject < DataFactory

  include StringFactory

  attr_reader :id, :namespace, :name, :type, :qualifiers

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        name:       'unassigned',
        qualifiers: [{:unit=>'000001'}]
    }
    set_options defaults.merge(opts)

    @id = RoleObject::ROLES[@name]
    raise "Can't find role ID based on the name given (#{@name}). Is the ROLES constant in RoleObject updated?" if @id.nil?
    # Need to groom the nil(s) from the @qualifiers array
    @qualifiers = @qualifiers.compact
  end

  # All navigation is done in the parent, UserObject.
  # IMPORTANT: This includes saving the changes!
  def create
    on Person do |create|
      create.description.set random_alphanums
      create.role_id.set @id
      create.add_role
      @qualifiers.each do |unit|
        create.unit_number(@id).fit unit[:unit]
        create.descends_hierarchy(@id).fit unit[:descends_hierarchy]
        create.add_role_qualifier(@id) unless unit[:unit].nil?
      end
    end
  end

end

class UserRolesCollection < CollectionsFactory

  contains UserRoleObject

  def name role_name
    self.find { |role| role.name==role_name }
  end

end