class ReviewObject < DataFactory

  include StringFactory, DateFactory

  attr_reader :submission_type, :submission_review_type, :type_qualifier,
              :committee, :expedited_checklist, :schedule_date, :requested_date,
              :determination_recommendation, :attachments, :comments, :primary_reviewers,
              :secondary_reviewers, :max_protocol_confirm

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        submission_type: '::random::',
        submission_review_type:  ['Full', 'Limited/Single Use', 'FYI', 'Response'].sample,
        type_qualifier: '::random::',
        committee: '::random::',
        expedited_checklist: '::random::',
        requested_date: right_now[:date_w_slashes],
        primary_reviewers: [],
        secondary_reviewers: [],
        comments: [],
        attachments: [] ,
        press: 'submit'
    }

    set_options(defaults.merge(opts))
  end

  def create
    # NOTE: Navigation is accomplished in the parent Protocol object!
    on SubmitForReview do |page|
      page.expand_all
      fill_out page, :submission_type, :submission_review_type, :type_qualifier,
               :committee
      # If the test doesn't specify a particular schedule date then
      # we want to pick the first selectable item
      # so as to make it most likely that there
      # will be active committee members available...
      # TODO: This is still buggy because sometimes the schedule dates
      # fall outside of the selectable range. FIXME!!!
      (@schedule_date ||= page.schedule_date.options[1].text) if page.schedule_date.options[1].exists?
      page.schedule_date.pick! @schedule_date

      if @submission_review_type == 'Expedited' && @expedited_checklist == '::random::'
        @expedited_checklist = EXPEDITED_CHECKLIST.keys.sample
        page.expedited_checklist(EXPEDITED_CHECKLIST.fetch(@expedited_checklist)).set
      end
      if @submission_review_type == 'Exempt' && @expedited_checklist == '::random::'
        #TODO:: @submission_review_type == 'Exempt' checklist needs to be created
        warn 'Exempt expedited checklist type needs to be created'
      end

      page.send(@press) unless @press.nil?
    end
  end

  def modify opts={}
    on ModifySubmissionRequest do |page|
      page.expand_all
      # TODO!
      page.submit
    end
  end

  def add_comment_for(reviewer, opts={})
    defaults = {
        reviewer: reviewer,
        comment:  random_multiline(200, 10),
        private:  'No',
        final:    'No'
    }
    comment = defaults.merge(opts)
    # Navigation done by the Protocol Object and/or step definition
    on OnlineReview do |page|
      page.expand_all
      page.new_review_comment(reviewer).set comment[:comment]
      page.add_comment(reviewer)
      page.save_review_of(reviewer)
    end
    @comments << comment
  end

  def comments_of reviewer
    @comments.find_all { |c| c[:reviewer]==reviewer }
  end

  def add_attachment opts={}

  end

  def approve_review_of reviewer
    on(OnlineReview).approve_review_of reviewer
  end

  def accept_comments_of reviewer
    on(OnlineReview).accept_review_comments_of reviewer
  end

  def mark_comments_private_for reviewer
    on(OnlineReview).expand_all
    @comments.find_all{ |com| com[:reviewer]==reviewer }.each do |comment|
      comment[:private]= 'Yes'
      on(OnlineReview).comment_final(comment[:comment]).fit comment[:private]
    end
    on(OnlineReview).save_review_of reviewer
  end

  def mark_comments_final_for reviewer
    on(OnlineReview).expand_all
    @comments.find_all{ |com| com[:reviewer]==reviewer }.each do |comment|
      comment[:final]= 'Yes'
      on(OnlineReview).comment_final(comment[:comment]).fit comment[:final]
    end
    on(OnlineReview).save_review_of reviewer
  end

  def assign_primary_reviewers *reviewers
    assign_reviewers 'primary', reviewers
  end

  def assign_secondary_reviewers *reviewers
    assign_reviewers 'secondary', reviewers
  end

  private
  def assign_reviewers type, reviewers
    rev = { 'primary' => @primary_reviewers, 'secondary' => @secondary_reviewers }
    existing_reviewers = @primary_reviewers + @secondary_reviewers
    on AssignReviewers do |page|
      page.expand_all
      page.submit_button.wait_until_present

      if reviewers==[]
        unselected_reviewers = (page.reviewers - existing_reviewers).shuffle
        # We want to randomize the number of reviewers selected when there
        # are several to choose from, but we don't want to select all of them
        # if we can avoid it...
        count = case(unselected_reviewers.size)
                  when 0
                    0
                  when 1, 2
                    1
                  else
                    # Needed to add 1 otherwise zero will skip adding a reviewer,
                    # Changed to take only half of the available reviewers to leave room for adding secondary reviewers
                    rand((unselected_reviewers.size/2.0).ceil)+1
                end
        count.times do |x|
          page.reviewer_type(unselected_reviewers[x]).select type
          rev[type] << unselected_reviewers[x]
        end
      else
        # Note: This code is written with the assumption
        # that the reviewer being passed is selectable and
        # isn't already a reviewer...
        reviewers.each do |reviewer|
          page.reviewer_type(reviewer).select type
          rev[type] << reviewer
        end
      end
      page.submit
    end
  end

  EXPEDITED_CHECKLIST = { 'Clinical studies of drugs and medical devices'=>0, 'Continuing review of approved IRB limited to data analysis'=>1,
                          'Continuing review of research not conducted'=>2, 'Collection of blood samples'=>3, 'Prospective collection of biological specimens'=>4,
                          'Collection of data through noninvasie procedures'=>5, 'Research involving materials'=>6, 'Collection of data from voice'=>7, 'Research on individual or group'=>8,
                          'Continuing review of approved IRB permanently closed to enrollment'=>9, 'Continuing review of research previously approved'=>10 }


end # ReviewObject