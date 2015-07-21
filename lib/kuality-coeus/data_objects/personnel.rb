# coding: UTF-8
# Contains methods useful across various Personnel classes.
module Personnel

  include Utilities

  CERTIFICATION_QUESTIONS = [
                             :understand_coi_obligation,
                             :agree_with_sponsor_terms
  ]

  def role_value
    {
        'Principal Investigator' => 'PI',
        'PI/Contact' => 'PI',
        'Co-Investigator' => 'COI',
        'Key Person' => 'KP'
    }
  end

  def lookup_page
    Kernel.const_get({
                      employee:     'KcPersonLookup',
                      non_employee: 'NonOrgAddressBookLookup',
                      to_be_named:  'ToBeNamedPersonsLookup'
                     }[@type.to_sym])
  end

  def get_person
    on(AddPersonnel) do |page|
      page.send(@type).set
      if @last_name.nil?
        if @type=='non_employee'
          until page.results_table.present? do
            page.state.pick '::random::'
            page.continue
          end
        else
          page.last_name.set("*#{%w{b c g h k l p r w}.sample}*")
          page.continue
        end
        # We need to exclude the set of test users from the list
        # of names we'll randomly select from...
        names = page.returned_full_names - $users.full_names
        name = 'William Lloyd Garrison'
        while name.scan(' ').size != 1
          name = names.sample
        end
        @first_name = name[/^\w+/]
        @last_name = name[/\w+$/]
        @full_name = @type=='employee' ? "#{@first_name} #{@last_name}" : "#{@last_name}, #{@first_name}"
      else
        fill_out page, :first_name, :last_name
        page.continue
      end
      item = @type=='employee' ? @full_name : "#{@first_name} #{@last_name}"
      page.select_person item
      page.continue
    end
  end

  def delete_units
    on page_class do |units|
      @units.each do |unit|
        units.delete_unit(@full_name, unit[:number])
      end
      units.save
    end
    @units=[]
  end

  # This method requires a parameter that is an Array
  # of Hashes. Though it defaults to the person object's
  # @units variable.
  #
  # Example:
  # [{:number=>"UNIT NUMBER", :responsibility=>"33.33"}]
  def update_unit_credit_splits(units=@units)
    units.each do |unit|
      on CreditAllocation do |update|
        update.unit_responsibility(@full_name, unit[:number]).fit unit[:responsibility]
        update.unit_financial(@full_name, unit[:number]).fit unit[:financial]
      end
      # This updates the @units variable, in case
      # it was not the passed parameter...
      DocumentUtilities::CREDIT_SPLITS.keys.each do |split|
        unless unit[split]==nil
          @units[@units.find_index{|u| u[:number]==unit[:number]}][split]=unit[split]
        end
      end
    end
    on(CreditAllocation).save
  end

  def log_in
    $current_user.sign_out unless $current_user==nil || $current_user==self
    visit($cas ? CASLogin : Login)do |log_in|
      log_in.username.set @user_name
      log_in.login
    end
    $current_user=self
  end
  alias :sign_in :log_in

  def log_out
    on(Header).log_out
    $current_user=nil
  end
  alias :sign_out :log_out

end # Personnel

# Contains methods useful in Personnel Collection classes
module People

  def names
    self.collect { |person| person.full_name }
  end
  alias :full_names :names

  def roles
    self.collect{ |person| person.role }.uniq
  end

  def unit_names
    units.collect{ |unit| unit[:name] }.uniq
  end

  def unit_numbers
    units.collect{ |unit| unit[:number] }.uniq
  end

  def units
    self.collect{ |person| person.units }.flatten
  end

  def person(full_name)
    self.find { |person| person.full_name==full_name }
  end

  # returns an array of KeyPersonObjects who have associated
  # units
  def with_units
    self.find_all { |person| person.units.size > 0 }
  end

  def principal_investigator
    self.find { |person| person.role=='Principal Investigator' || person.role=='PI/Contact' }
  end

  def co_investigator
    self.find { |person| person.role=='Co-Investigator' }
  end

  def key_person(role)
    self.find { |person| person.key_person_role==role }
  end

  # IMPORTANT: This method returns a KeyPersonObject--meaning that if there
  # are multiple key persons in the collection that match this search only
  # the first one will be returned.  If you need a collection of multiple persons
  # write the method for that.
  def uncertified_person(role)
    self.find { |person| person.certified==false && person.role==role }
  end

end # People