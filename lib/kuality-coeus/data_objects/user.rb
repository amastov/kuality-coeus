class UserObject

  include Foundry
  include DataFactory
  include Navigation

  attr_accessor :user_name,
                :first_name, :last_name,
                :description, :affiliation_type, :campus_code,
                :employee_id, :employee_status, :employee_type, :base_salary,
                :groups, :roles, :role_qualifiers

  DEFAULT_USERS = YAML.load_file("#{File.dirname(__FILE__)}/users.yml")

  def initialize(browser, opts={:user=>'admin'})
    @browser = browser
    @user_name=opts[:user]
    defaults = DEFAULT_USERS[@user_name]
    set_options defaults
  end

  def create
    visit(SystemAdmin).person unless PersonLookup.new(@browser).principal_id.present?
    on(PersonLookup).create
    on Person do |add|
      add.expand_all
      add.principal_name.set @user_name
      fill_out add, :description, :affiliation_type, :campus_code, :first_name, :last_name
      # TODO: These "default" checkboxes will need to be reworked if and when
      # a test is going to require multiple affiliations, names, addresses, etc.
      # Until then, there's no need to do anything other than set the necessary single values
      # as "default"...
      add.affiliation_default.set
      add.name_default.set
      add.add_affiliation
      fill_out add, :employee_id, :employee_status, :employee_type, :base_salary
      add.add_employment_information
      add.add_name
      unless @roles==nil
        @roles.each do |role|
          add.role_id.set role
          add.add_role
        end
      end
      unless @role_qualifiers==nil
        puts @role_qualifiers.inspect
        @role_qualifiers.each do |role, unit|
          add.unit_number(role).set unit
          add.add_role_qualifier
        end
      end
      unless @groups==nil
        @groups.each do |group|
          add.group_id.set group
          add.add_group
        end
      end
      add.blanket_approve
    end
  end

  def sign_in
    unless logged_in?
      if username_field.present?
        mthd = :on
      else
        mthd = :visit
      end
      send(mthd, Login) { |log_in|
        log_in.username.set @user_name
        log_in.login
      }
    end
  end
  alias_method :log_in, :sign_in

  def sign_out
  # This _might_ cause an infinite loop, but I'm
  # hoping not...
    on(Researcher) do |page|
      page.return_to_portal
      page.close_children
    end
    if s_o.present?
      s_o.click
    else
      visit Login do |page|
        if page.username.present?
          # do nothing because we're already logged out...
        else
          sign_out
        end
      end
    end
  end
  alias_method :log_out, :sign_out

  def exist?
    visit(SystemAdmin).person
    on PersonLookup do |search|
      search.principal_name.set @user_name
      search.search
      return search.results_table.present?
    end
  end
  alias_method :exists?, :exist?

  #========
  private
  #========

  def logged_in?
    if username_field.present?
      false
    elsif login_info_div.present?
      login_info_div.text.include? @user_name ? true : false
    else
      begin
        on(Researcher).return_to_portal
      rescue
        visit(Login).close_children
        @browser.windows[0].use
      end
      logged_in?
    end
  end

  def s_o
    @browser.button(value: 'Logout')
  end

  def login_info_div
    @browser.div(id: 'login-info')
  end

  def username_field
    Login.new(@browser).username
  end

end