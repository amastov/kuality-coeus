class AwardReportsObject < DataFactory

  attr_reader :class, :type, :frequency,
              :frequency_base, :osp_file_copy,
              :due_date, :recipients, :details


  def initialize(browser, opts={})
    @browser = browser

    defaults = {
      class:          '::random::',
      type:           '::random::',
      frequency:      '::random::',
      frequency_base: '::random::',
      osp_file_copy:  '::random::',
      details:        collection('ReportTracking')
    }
    set_options(defaults.merge(opts))
  end

  def create
    on PaymentReportsTerms do |page|
      page.expand_all
      set_report_class
      set_report_type
      set_frequency
      page.add_frequency_base(@class).pick! @frequency_base
      page.add_osp_file_copy(@class).pick! @osp_file_copy
      page.add_due_date(@class).fit @due_date
      page.add_report(@class)



      DEBUG.do {
        DEBUG.message 'Saving Report...'
        begin
          page.save
        rescue
          DEBUG.message 'A screw up!'
          #DEBUG.pause 6090
        end
      }


    end
  end

  private

  def set_frequency
    if @frequency == '::random::'
      @frequency = 'None'
      # We can't have a frequency of 'None' due to bugs on this page, so we must
      # reject it as a randomized selection...
      while @frequency == 'None'
        @frequency = on(PaymentReportsTerms).add_frequency(@class).options.map(&:text).sample
      end
    end
    on PaymentReportsTerms do |page|
      page.add_frequency(@class).pick! @frequency
      page.refresh_selection_lists
    end
  end

  def set_report_type
    if @type == '::random::'
      @type = 'None'
      # We can't have a type of 'None' due to bugs on this page, so we must
      # reject it as a randomized selection...
      while @type == 'None'
        @type = on(PaymentReportsTerms).add_report_type(@class).options.map(&:text).sample
      end
    end
    on PaymentReportsTerms do |page|
      page.add_report_type(@class).pick! @type
      page.refresh_selection_lists
    end
  end

  def set_report_class
    if @class == '::random::'
      @class = on(PaymentReportsTerms).report_classes.sample
    end
  end

end # AwardReportsObject

class AwardReportsCollection < CollectionFactory

  contains AwardReportsObject

  def count_of(report_class)
    self.count{ |r_obj| r_obj.report==report_class }
  end

end