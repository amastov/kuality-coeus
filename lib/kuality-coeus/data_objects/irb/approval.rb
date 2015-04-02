class ApprovalObject < DataFactory

  include StringFactory, DateFactory, Navigation

  attr_reader :approval_date, :expiration_date, :action_date, :comments,
              :risk_level

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        comments: random_alphanums_plus(25),
        risk_level: []
    }
    set_options(defaults.merge(opts))
  end

  def create
    # NOTE: Navigation is accomplished in the parent Protocol object!
    on ApproveAction do |page|
      page.expand_all
      fill_out page, :comments
      if @approval_date
        #There is a PROBLEM when entering text in Approval Date. A popup appears saying wrong format.
        #entering text into a clear Approval Date field does not produce a popup
        page.approval_date.clear
        page.alert.ok if page.alert.exists?
        fill_out page, :approval_date
      else
        @approval_date = page.approval_date.value
      end
      if @expiration_date
        fill_out page, :expiration_date
      else
        @expiration_date = page.expiration_date.value
      end
      if @action_date
        fill_out page, :action_date
      else
        @action_date = page.action_date.value
      end

      page.submit
    end
  end

  def add_risk_level opts={}
    level = { risk_level: '::random::', date_assigned: right_now[:date_w_slashes] }
    level.merge!(opts)
    on ApproveAction do |page|
      page.expand_all
      page.new_risk_level.fit level[:risk_level]
      page.new_date_assigned.fit level[:date_assigned]
      page.add_risk_level
      page.submit
    end
    @risk_level << level
  end

end
