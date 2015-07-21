class ExceptionObject < DataFactory

  include StringFactory

  attr_reader :exception, :species

  def initialize(browser, opts={})
    @browser = browser
    defaults = {
        exception: '::random::',
        species: '::random::',
        justification: random_alphanums
    }
    set_options(defaults.merge(opts))
    requires :index
  end

  def create
    on ProtocolException do |page|
      page.expand_all
      @exception = page.exception_list.sample if @exception == '::random::'
      fill_out page, :exception, :species, :justification
      page.add
    end
  end

end

class ExceptionsCollection < CollectionFactory

  contains ExceptionObject

  def add opts = {}
    defaults = {index: self.size}
    exception = ExceptionObject.new @browser, defaults.merge(opts)
    exception.create
    self << exception
  end

end