class AwardCustomDataObject < DataFactory

include DateFactory, StringFactory, DocumentUtilities

attr_accessor :graduate_student_count, :billing_element


def initialize(browser, opts={})
    @browser = browser

    defaults = {
        graduate_student_count: rand(1..999),
        billing_element:        random_alphanums
    }
    set_options(defaults.merge(opts))
end

def create
    view 'Custom Data'
    on AwardCustomData do |page|
        page.expand_all
        fill_out page, :graduate_student_count, :billing_element
        page.save
    end

end #create

def view(tab)
    unless on(Award).send(StringFactory.damballa("#{tab}_element")).parent.class_name=~/tabcurrent$/
        on(Award).send(StringFactory.damballa(tab.to_s))
    end
end

end
