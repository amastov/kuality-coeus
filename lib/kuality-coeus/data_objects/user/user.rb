# This is the UserObject collection class, stored in $users.
class Users < Array

  include Singleton

  def user(username)
    self.find { |user| user.user_name == username }
  end

  def type(type)
    self.find { |user| user.type == type }
  end

  def all_with_role(role_name)
    self.find_all { |user| user.roles.name(role_name) }
  end

  def with_role(role_name)
    self.find { |user| user.roles.name(role_name) }
  end

  def with_role_in_unit(role_name, unit)
    roles = self.map{ |user| user.roles }
    begin
      self.user(roles.flatten!.find { |role| role.name==role_name && role.qualifiers.detect{ |q| q[:unit]==unit } }.user_name)
    rescue NoMethodError
      nil
    end
  end

  def admin
    self.user('admin')
  end

  def grants_gov_pi
    self.find { |user|
                  !user.primary_department_code.nil? &&
                  !user.phones.find{|phone| phone[:type]=='Work'}.nil? &&
                  !user.emails.find{|email| email[:type]=='Work'}.nil? &&
                  !user.era_commons_user_name.nil?
    }
  end

  def full_names
    self.collect { |user| user.full_name }
  end

end # Users

# This is a special collection class that inherits from Array and contains
# the user information listed in the users.yml file.
class UserYamlCollection < Array

  def user(user_name)
    self.find { |user| user[:user_name]==user_name }
  end

  # Returns an array of all users with the specified role. Takes the role name as a string.
  # The array is shuffled so that #have_role('role name')[0] will be a random selection
  # from the list of matching users.
  def have_role(role)
    users = have_rolez.find_all{|user|
      user[:rolez].detect{|r| r[:name]==role}
        }.shuffle
    raise "No users have the role #{role}. Please add one or fix your parameter." if users.empty?
    users
  end

  # Returns an array of all users with the specified role in the specified unit. Takes
  # the role and unit names as strings.
  # The array is shuffled so that #have_role_in_unit('role name', 'unit name')[0]
  # will be a random selection from the list of matching users.
  def have_role_in_unit(role, unit)
    users = have_rolez.find_all{ |user|
                            user[:rolez].detect{ |r|
                                                     r[:name]==role &&
                                                     r[:qualifiers].detect{ |q|
                                                                             q[:unit]==unit }
                                                  }
                         }.shuffle
    raise "No users have the role #{role} in the unit #{unit}. Please add one or fix your parameter(s)." if users.empty?
    users
  end

  # TODO: Does this need the third parameter?  Maybe we just look for "yes" and make another method for "no"...
  def have_hierarchical_role_in_unit(role, unit, hier)
    users = have_rolez.find_all{ |user|
      user[:rolez].find{ |r| r[:name]==role && r[:qualifiers].detect{ |q| q[:unit]==unit && q[:descends_hierarchy]==hier } }
    }.shuffle
    raise "No users have a hierarchical role #{role} in the unit #{unit}. Please add one or fix your parameter(s)." if users.empty?
    users
  end

  # Returns an array of all users with the specified campus code. Takes the code as a string.
  # The array is shuffled so that #with_campus_code('code')[0] will be a random selection
  # from the list of matching users.
  def with_campus_code(code)
    self.find_all{|user| user[:campus_code]==code }.shuffle
  end

  # Returns an array of all users with the specified affiliation type. Takes the type name as a string.
  # The array is shuffled so that #with_affiliation_type('type name')[0] will be a random selection
  # from the list of matching users.
  def with_affiliation_type(type)
    self.find_all{|user| user[:affiliation_type]==type }.shuffle
  end

  def with_employee_type(type)
    self.find_all{|user| user[:employee_type]==type }.shuffle
  end

  def with_primary_dept_code(code)
    self.find_all{|user| user[:primary_dept_code]==code }.shuffle
  end

  def with_appointment_type(type)
    self.find_all{|user|
      !user[:appointmentz].nil? &&
      !(user[:appointmentz].find { |app| app[:type]==type }).nil?
    }.shuffle
  end

  # Note: This method returns the username of a matching user record. It does NOT
  # return an array of all matching users.
  def grants_gov_pi
    self.find_all { |user| !user[:primary_department_code].nil? &&
                           !user[:phones].find{|phone| phone[:type]=='Work'}.nil? &&
                           !user[:emails].find{|email| email[:type]=='Work'}.nil? &&
                           !user[:era_commons_user_name].nil?
    }.shuffle[:user_name]
  end

  def have_rolez
    self.find_all { |u| u[:rolez] != nil }
  end

end # UserYamlCollection

class UserObject < DataFactory

  include StringFactory

  attr_reader :user_name, :principal_id,
              :first_name, :last_name, :full_name, :middle_name,
              :description, :affiliation_type, :campus_code,
              :employee_id, :employee_status, :employee_type, :base_salary, :primary_department_code,
              :groups, :roles, :role_qualifiers, :addresses, :phones, :emails,
              :primary_title, :directory_title, :citizenship_type, :role,
              :era_commons_user_name, :graduate_student_count, :billing_element,
              :directory_department, :appointments,
              :type

  USERS = UserYamlCollection[YAML.load_file("#{File.dirname(__FILE__)}/users.yml").map{ |item| item[1] }].flatten!

  def initialize(browser, opts={})
    @browser =      browser
    @roles =        collection('UserRoles')
    @groups =       collection('UserGroups')
    @appointments = collection('Appointments')

    defaults={
        description:      random_alphanums,
        affiliation_type: 'Student',
        campus_code:      'UN - UNIVERSITY',
        first_name:       random_alphanums,
        last_name:        random_alphanums,
        addresses:        [{type:   'Work',
                            line_1:  '1375 N Scottsdale Rd',
                            city:    'scottsdale',
                            state:   'ARIZONA',
                            country: 'United States',
                            zip:     '85257',
                            default: :set }],
        phones:           [{type:   'Work',
                            number:  '602-840-7300',
                            default: :set }],
        groups:           collection('UserGroups')
    }
    defaults.merge!(opts)
    if opts.empty? # then we want to make the admin user...
      options = {user_name: 'admin', first_name: 'admin', last_name: 'admin'}
    else # if we're passing options then we want to make a particular user...
      @user_name=case
                 when opts.key?(:user)
                   opts[:user]
                 when opts.key?(:unit)
                   USERS.have_role_in_unit(opts[:role], opts[:unit]).first[:user_name]
                   when opts.key?(:role)
                   USERS.have_role(opts[:role]).first[:user_name]
                 else
                   :nil
                 end
      options = USERS.user(@user_name).nil? ? defaults : USERS.user(@user_name).merge(opts)
    end

    set_options options

    @user_name=random_letters(16) if @user_name==:nil
    @rolez.each { |role| @roles << make(UserRoleObject, role) } unless @rolez.nil? || @rolez[0][:name].nil?
    @appointmentz.each { |appt| @appointments << make(AppointmentObject, appt) } unless @appointmentz.nil?
    @appointmentz=nil
    @rolez=nil
    @full_name = "#{@first_name} #{@last_name}"
  end

  # It's important to note that this method will work
  # regardless of who is logged in--because if the current user
  # is not capable of creating a new user, they will be logged out
  # and the Admin user will log in. It's probably a good idea to
  # revisit this approach in the future. For now, though, it
  # makes the Cucumber scenarios a bit cleaner and simpler.
  def create
    visit(SystemAdmin).person
    begin
      on(PersonLookup).create
    rescue Watir::Exception::UnknownObjectException
      $users.admin.log_in
      visit(SystemAdmin).person
      on(PersonLookup).create
    end
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
      add.add_name
      add.add_affiliation
      # TODO: Another thing that will need to be changed if ever there's a need to test multiple
      # lines of employment:
      unless @employee_id.nil?
        fill_out add, :employee_id, :employee_status, :employee_type, :base_salary,
                 :primary_department_code
        add.primary_employment.set
        add.add_employment_information
      end
      @roles.each { |role| role.create }
      # TODO: Support groups creation here. For now, use the add_group method.
      unless @addresses.nil?
        @addresses.each do |address|
          add.address_type.fit address[:type]
          add.line_1.fit address[:line_1]
          add.city.fit address[:city]
          add.state.pick! address[:state]
          add.country.pick! address[:country]
          add.zip.fit address[:zip]
          add.address_default.fit address[:default]
          add.add_address
        end
      end
      unless @phones.nil?
        @phones.each do |phone|
          add.phone_type.fit phone[:type]
          add.phone_number.fit phone[:number]
          add.phone_default.fit phone[:default]
          add.add_phone
        end
      end
      unless @emails.nil?
        @emails.each do |email|
          add.email.fit email[:email]
          add.email_type.pick! email[:type]
          add.email_default.fit email[:default]
          add.add_email
        end
      end
      # A breaking of the design pattern, but there's no other
      # way to obtain this number:
      @principal_id = add.principal_id
      add.blanket_approve
    end
    unless extended_attributes.compact.length==0
      visit(SystemAdmin).person_extended_attributes
      on(PersonExtendedAttributesLookup).create
      on PersonExtendedAttributes do |page|
        page.expand_all
        fill_out page, :description, :primary_title, :directory_title, :citizenship_type,
                 :era_commons_user_name, #:graduate_student_count, :billing_element,
                 :principal_id, :directory_department
        page.blanket_approve
      end
    end

  end # create

  def edit opts={}
    navigate
    on Person do |edit|
      edit.description.set random_alphanums
      # TODO: Add more here, as necessary
    end
    update_options(opts)
  end

  def add_role opts={}
    opts.merge!({user_name: @user_name})
    navigate
    @roles.add opts
    on Person do |add|
      add.description.set random_alphanums
      add.blanket_approve
    end
  end

  def add_group opts={}
    opts.merge!({user_name: @user_name})
    navigate
    @groups.add opts
    on Person do |add|
      add.description.set random_alphanums
      add.blanket_approve
    end
  end

  # Keep in mind...
  # - If some other user is logged in, they
  #   will be automatically logged out
  def sign_in
    unless $current_user==self
      $current_user.sign_out if $current_user
      begin
        visit(Login).username.present?
      rescue Selenium::WebDriver::Error::UnhandledAlertError
        warn 'Modal dialog appeared...'
        puts @browser.alert.text
        @browser.alert.close
        sleep 5
      rescue Watir::Exception::UnknownObjectException
        warn 'Blank screen, maybe?'
        @browser.goto 'www.google.com'
      end
      visit Login do |log_in|
        log_in.username.set @user_name
        log_in.login
      end
      on(Header).doc_search_link.wait_until_present

      $current_user=self
    end
  end
  alias_method :log_in, :sign_in

  def sign_out
    on(BasePage).close_extra_windows
    visit Logout
    $current_user=nil
  end
  alias_method :log_out, :sign_out

  def exist?
    $users.admin.log_in if $current_user==nil
    visit SystemAdmin do |page|
      page.person
    end
    on PersonLookup do |search|
      search.principal_name.set @user_name
      search.search
      begin
        search.results_table.wait_until_present(2)
        if search.item_row(@user_name).present?
          # TODO!
          # This is a coding abomination to include
          # this here, but it's here until I can come
          # up with a better solution...
          @principal_id = search.item_row(@user_name).link(title: /Person Principal ID=\d+/).text
          return true
        else
          return false
        end
      rescue
        return false
      end
    end
  end
  alias_method :exists?, :exist?

  # TODO: This method needs a logic revamp in order to
  # ensure it does not enter an infinite loop.
  def logged_in?
    # Are we on the login page already?
    if username_field.present?
      # Yes! So, we're not logged in...
      false
    # No, the Kuali header is showing...
    elsif login_info_div.present?
      # So, is the user currently listed as logged in?
      return login_info_div.text.include? @user_name
    else # We're on some page that has no Kuali header, so...
      begin
        # We'll assume that the portal window exists, and go to it.
        on(BasePage).return_to_portal
      # Oops. Apparently there's no portal window, so...
      rescue
        # We'll close any extra tabs/windows
        on(BasePage).close_children if @browser.windows.size > 1
        # And make sure that we're using the "parent" window
        @browser.windows[0].use
      end
      # Now that things are hopefully in a clean state, we'll start
      # the process again...
      logged_in?
    end
  end

  def logged_out?
    !logged_in?
  end

  #========
  private
  #========

  def login_info_div
    @browser.div(id: 'login-info')
  end

  def username_field
    Login.new(@browser).username
  end

  def extended_attributes
    [@primary_title, @directory_title, @citizenship_type,
     @era_commons_user_name, @graduate_student_count, @billing_element,
     @directory_department]
  end

  def navigate
    on(BasePage).close_extra_windows
    visit(SystemAdmin).person
    on PersonLookup do |look|
      fill_out look, :principal_id
      look.search
      look.edit_person @user_name
    end
    on(Person).expand_all
  end

end # UserObject