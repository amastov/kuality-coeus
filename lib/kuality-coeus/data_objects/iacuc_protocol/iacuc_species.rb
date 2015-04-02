class SpeciesObject < DataFactory

  include StringFactory #, Navigation, DateFactory, Protocol

  attr_reader :group, :species, :pain_category, :count_type, :count,
              :strain, :usda_covered, :procedure_summary, :index

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        group: random_alphanums_plus(10, 'Species '),
        species: '::random::',
        pain_category: '::random::',
        count_type: '::random::',
        count: rand(1..21),
        press: 'save', index: 0

    }
    set_options(defaults.merge(opts))
  end

  def create
    view 'Species Groups'
    on SpeciesGroups do |page|
      page.expand_all
      fill_out page, :group, :count, :species, :pain_category, :count_type

      #non-required, non-defaults
      fill_out page, :strain, :usda_covered, :procedure_summary

      page.add_species
      page.send(@press) unless @press.nil?
    end
  end

  def edit opts={}
    view 'Species Groups'
    on SpeciesGroups do |edit|
      edit.expand_all

      #neeed to set options here to capture the changes to these new fields.
      set_options(opts)

      edit.group_added(@index).fit @group
      edit.count_added(@index).fit @count

      edit.strain_added(@index).fit @strain
      edit.usda_covered_added(@index).fit @usda_covered
      edit.procedure_summary_added(@index).fit @procedure_summary

      edit.species_added(@index).pick! @species
      edit.pain_category_added(@index).pick! @pain_category
      edit.count_type_added(@index).pick! @count_type

      edit.send(@press) unless @press.nil?
    end
  end

  def view(tab)
    on(IACUCProtocolOverview).send(damballa(tab))
  end

end #SpeciesObject
