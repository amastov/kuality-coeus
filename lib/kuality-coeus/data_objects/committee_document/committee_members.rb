class CommitteeMemberObject < DataFactory

  include DateFactory

  attr_reader :document_id, :name, :user_name, :membership_type, :paid_member, :term_start_date, :term_end_date,
              :roles, :expertise

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        name:            '::random::',
        membership_type: '::random::',
        term_start_date: right_now[:date_w_slashes],
        term_end_date:   hours_from_now(50000)[:date_w_slashes],
        paid_member:     [:clear, :set].sample,
        roles:           [{role: ACTIVE_ROLES.sample, start_date: right_now[:date_w_slashes], end_date: hours_from_now(50000)[:date_w_slashes]}],
        expertise:       []
    }

    set_options(defaults.merge(opts))
    requires :document_id
  end

  def create
    # Navigation done by CommitteeDocument object
    # TODO: Support non-employee searching
    existing_members = []
    on Members do |page|
      existing_members = page.existing_members
      page.employee_search
    end
    if @name=='::random::'
      on KcPersonLookup do |page|
        letter = %w{l s r o h e t b g j f}.sample
        page.first_name.set "*#{letter}*"
        page.search
        # This code removes names that contain 3 words, which
        # can screw things up elsewhere...
        @name = 'William Lloyd Garrison'
        while name.scan(' ').size > 1
          @name = (page.returned_full_names - existing_members - $users.full_names).sample
        end
        @user_name = page.user_name_of @name
        page.return_value @name
      end
      on(Members).add_member
    else
      # TODO: Write code for when we know the name
    end
    on Members do |page|
      page.expand_all
      page.membership_type(@name).pick! @membership_type
      page.paid_member(@name).fit @paid_member
      page.term_start_date(@name).fit @term_start_date
      page.term_end_date(@name).fit @term_end_date
      @roles.each { |role|
        page.add_role_type(@name).pick! role[:role]
        page.add_role_start_date(@name).fit role[:start_date]
        page.add_role_end_date(@name).fit role[:end_date]
        page.add_role(@name)
      }
    end
    if @expertise.empty?
      add_expertise
    else
      @expertise.each do |area|
        # TODO: Write this code
      end
    end
    on(Members).save
  end

  def sign_in
    $current_user.sign_out unless $current_user==nil || $current_user==self
    sign_out
    visit($cas ? CASLogin : Login) do |log_in|
      log_in.username.set @user_name
      log_in.login
    end
    $current_user=self
  end

  def sign_out
    @browser.goto "#{$base_url}#{$context}logout.do"
    $current_user=nil
  end

  private

  def add_expertise(item=nil)
    on Members do |page|
      page.expand_all
      page.lookup_expertise(@name)
    end
    if item
      # TODO: Write this code
    else
      on ResearchAreasLookup do |page|
        until page.results_table.present?
          page.research_area_code.set "*#{rand(99)}*"
          page.search
          sleep 0.2
        end
        research_description = page.research_descriptions.sample
        page.check_item(research_description)
        page.return_selected
        @expertise << research_description
      end
    end
  end

  ACTIVE_ROLES = ['Chair', 'Expedited/Exempt Reviewer', 'Alternate',
                  'IRB Administrator',
                  'Member - Scientist', 'Member - Non Scientist',
                  'Member', 'Community Member',
                  'Prisoner Representative', 'Vice Chair', 'Additional Committee Member'
                   ]

end # CommitteeMemberObject

class CommitteeMemberCollection < CollectionsFactory

  contains CommitteeMemberObject

  def member(full_name)
    self.find { |member| member.name==full_name }
  end

  def full_names
    self.collect { |member| member.name }
  end

  def voting_members
    self.find_all { |member| member.membership_type=='Voting member' }
  end

end # CommitteeMemberCollection