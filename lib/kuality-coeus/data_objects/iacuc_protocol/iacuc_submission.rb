class IACUCSubmissionObject < DataFactory

  attr_reader :submission_type, :review_type, :type_qualifier, :committee,
              :schedule_date, :billable, :primary_reviewers, :secondary_reviewers,
              :determination_due_date

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        submission_type: '::random::',
        review_type: '::random::',
        type_qualifier: '::random::'
    }
    set_options(defaults.merge(opts))
  end

  def create
    # Navigation done in Protocol Object
    on IACUCSubmitForReview do |page|
      page.expand_all
      fill_out page, :submission_type, :review_type, :type_qualifier
      page.submit
    end
  end

  def edit opts={}
    defaults = {
        committee: 'KC IACUC 1',
        primary_reviewers: [],
        secondary_reviewers: [],
        schedule_date: '::random::',
        billable: 'Yes'
    }
    options = defaults.merge(opts)
    on IACUCModifySubmissionRequest do |page|
      page.expand_all
      page.committee.select options[:committee]
      page.committee.fire_event('onchange')
      if options[:schedule_date]=='::random::'
        options[:schedule_date] = page.schedule_date_list.sample
      end
      edit_fields options, page, :schedule_date, :submission_type,
                  :review_type, :billable, :type_qualifier,
                  :determination_due_date
      committee_members = page.reviewers.shuffle
      if options[:primary_reviewers].empty?
        options[:primary_reviewers] << committee_members[0]
      end
      if options[:secondary_reviewers].empty?
        options[:secondary_reviewers] << (committee_members - options[:primary_reviewers])[0]
      end
      options[:primary_reviewers].each { |r| page.reviewer_type(r).select 'primary' }
      options[:secondary_reviewers].each { |r| page.reviewer_type(r).select 'secondary' }
      page.submit
    end
    set_options(options)
  end

end