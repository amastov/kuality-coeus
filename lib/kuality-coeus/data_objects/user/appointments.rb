class AppointmentObject < DataFactory

  attr_reader :unit, :job_code, :type, :salary, :start_date,
              :job_title, :preferred_job_title

  def initialize(browser, opts={})
    @browser = browser

    defaults = {

    }
    set_options defaults.merge(opts)
  end

  def create
    # TODO
  end

end

class AppointmentsCollection < CollectionFactory

  contains AppointmentObject

  def type(type)
    self.find { |app| app.type==type }
  end

  def job_code(code)
    self.find { |app| app.job_code==code }
  end

end