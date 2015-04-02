# coding: UTF-8
class SupplementalInfoObject < DataFactory

  include StringFactory, Navigation

  attr_reader :graduate_student_count, :billing_element

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        graduate_student_count: rand(50).to_s,
        billing_element:        random_alphanums_plus(40)
    }
    set_options(defaults.merge(opts))
    requires :navigate
  end

  def create
    view
    on SupplementalInfo do |create|
      create.asdf if create.asdf_link.present?
      fill_out create, :billing_element
      create.personnel_items_for_review
      fill_out create, :graduate_student_count
      #TODO: Other fields...
      create.save
    end
  end

  def view
    @navigate.call
    on(ProposalSidebar).supplemental_information unless on(SupplementalInfo).header_span.present?
  end

end