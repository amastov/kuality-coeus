module DocumentUtilities

  CREDIT_SPLITS = { recognition: 'Recognition',
                    responsibility: 'Responsibility',
                    space: 'Space',
                    financial: 'Financial' }

  # This method simply sets all the credit splits to
  # equal values based on how many persons and units
  # are attached to the Proposal. If more complicated
  # credit splits are needed, these will have to be
  # coded in the step def, accessing the key person
  # objects directly.
  def set_valid_credit_splits
    # calculate a "person" split value that will work
    # based on the number of people attached...
    split = (100.0/@key_personnel.with_units.size).round(2)

    # Now make a hash to use for editing the person's splits...
    splits = {}
    CREDIT_SPLITS.keys.each{ |cs| splits.store(cs, split) }

    # Now we update the KeyPersonObjects' instance variables
    # for their own splits as well as for their units
    @key_personnel.with_units.each do |person|
      person.update_splits splits
    #  units_split = (100.0/person.units.size).round(2)
      # Make a temp container for the units we're updating...
    #  units = []
    #  person.units.each { |unit| units << {:number=>unit[:number]} }
      # Iterate through the units, updating their credit splits with the
      # valid split amount...
    #  units.each do |unit|
    #    CREDIT_SPLITS.keys.each { |item| unit[item]=units_split }
    #  end
    # person.update_unit_credit_splits units
    end
  end

end