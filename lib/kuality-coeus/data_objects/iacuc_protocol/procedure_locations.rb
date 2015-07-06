class ProcedureLocationObject < DataFactory

  include StringFactory, Utilities

  attr_reader :description, :type, :index, :name, :room, :index

  def initialize(browser, opts={})
    @browser = browser
    defaults ={
        description: random_alphanums,
        type: 'Performance Site',
        name: '::random::',
        #Room Number required for setting the procedure to location
        room: rand(101..999).to_s,
        procedures_at_location: ['All']
    }
    set_options(defaults.merge(opts))
    requires :navigate, :index
  end

  def create
    # Navigation performed by parent Procedures object
    on IACUCProceduresLocation do |page|
      #noko to speed up select list
      @type = page.type_list.sample if @type=='::random::'
      # Need this separated out because it determines what's in the
      # Name field...
      page.type.select @type
      fill_out page, :room, :description, :name
      page.add_location
      page.edit_procedures(@index)
    end
    # Select the specific species checkbox if provided otherwise select the ALL option.
    on IACUCProceduresPersonnelDialogue do |page|
      if @procedures_at_location[0]=='All'
        if page.all_group.present?
          page.all_group.set
        else
          page.all_procedures.set
        end
      else
        @procedures_at_location.each{ |p| page.procedure(p).set }
      end
      page.save
    end
    on(IACUCProceduresLocation).save
  end

  def view
    @navigate.call
    on(IACUCProcedures) do |page|
      page.procedures
      page.expand_all
      page.select_procedure_tab 'location'
    end
  end

  def edit opts={}
    view
    on IACUCProceduresLocation do |page|
      page.edit_type(@index).pick! opts[:type]
      page.edit_name(@index).pick! opts[:name]
      page.edit_room(@index).fit opts[:room]
      page.edit_description(@index).fit opts[:description]

      unless opts[:procedures_at_location].nil?
        page.edit_procedures(@index)
        # First we clear out all selections, to have a blank slate...
        if page.all_group.present?
          page.all_group.set
          page.all_group.clear
        else
          page.all_procedures.set
          page.all_procedures.clear
        end
        # Now we can check the items that need to be checked...
        opts[:procedures_at_location].each do |pal|
          page.procedure(pal).set
        end
      end

      page.save
      update_options(opts)
    end
  end

  def delete
    view
    on IACUCProcedures do |page|
      page.expand_all
      page.select_procedure_tab 'location'
    end
    on IACUCProceduresLocation do |page|
      page.delete(@index)
      confirmation
      page.save
    end
  end

end  # ProcedureLocationObject

class ProcedureLocationsCollection < CollectionsFactory

  contains ProcedureLocationObject

  def names
    self.map { |l| l.name }
  end

  # TODO: Add an indexing function here so that locations will
  # remain properly identifiable after one or more get deleted...

end