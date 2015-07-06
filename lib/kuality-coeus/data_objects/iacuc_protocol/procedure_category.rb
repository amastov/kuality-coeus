class ProcedureCategoryObject < DataFactory

  attr_reader :name, :groups_species

  def initialize(browser, opts={})
    @browser = browser
    defaults = {
      name: IACUCProcedures::CATEGORIES.sample,
      groups_species: [{}] # Idea here is to have hashes for the :name and :count of the added items.
    }
    set_options(defaults.merge(opts))
  end

  def create
    # Parent Procedures object does navigation
    on IACUCProcedures do |page|
      page.category(@name).set
      @groups_species[0][:name] ||= page.species_list_for_category(@name).sample
      page.select_species_for_category(@name).select @groups_species[0][:name]
      page.add_species_to_category(@name)

      # TODO: Get :count for @group_species hash

    end
  end

end

class ProcedureCategoriesCollection < CollectionsFactory

  contains ProcedureCategoryObject

end