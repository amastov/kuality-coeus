class AwardTermsObject < DataFactory

  attr_reader :equipment_approval, :invention, :prior_approval, :property,
              :publication, :referenced_document, :rights_in_data,
              :subaward_approval, :travel_restrictions,
              :random_terms

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        equipment_approval:  [([1, 3, 4, 6, 7, 10] + (12..26).to_a + [28]).sample],
        invention:           [([1, 3, 6] + (7..13).to_a + (15..20).to_a).sample],
        random_terms: '::random::',
        prior_approval:      [rand(1..58)],
        property:            [([1] + (3..11).to_a + (14..21).to_a + [23] + (25..27).to_a).sample],
        publication:         [([1] + (3..15).to_a).sample],
        referenced_document: [([1] + (3..5).to_a + (8..10).to_a + (14..18).to_a + (20..21).to_a + [29, 34, 40, 42, 43, 49, 64, 69, 70]).sample],
        rights_in_data:      [([1] + (7..13).to_a + [15, 16] + (22..27).to_a + [29, 31, 32, 35, 36]).sample],
        subaward_approval:   [([1] + (3..7).to_a + [9] + (11..17).to_a + (19..24).to_a).sample],
        travel_restrictions: [([1] + (3..10).to_a + (13..25).to_a).sample]
    }
    set_options(defaults.merge(opts))
  end

  def create
    on PaymentReportsTerms do |page|
      page.expand_all
      if @random_terms == '::random::'
        # the_terms = ['EquipmentApproval', 'Invention','Property', 'Publication',
        #              'ReferencedDocument', 'RightsInData' 'SubawardApproval', 'TravelRestrictions']

        the_terms = ['Equipment Approval', 'Invention', 'Prior Approval', 'Property', 'Publication',
              'Referenced Document', 'Rights In Data', 'Subaward Approval', 'Travel Restrictions']

        the_terms.each do |randy|
          page.send("search_#{randy.downcase.gsub(' ', '_')}_term")
          on SponsorTermLookup do |lookup|
            lookup.search
            lookup.return_random_term
          end
        end

      else
        @equipment_approval.each { |ea| page.equipment_approval_code.fit ea; page.add_equipment_approval_term }
        @invention.each {|inv| page.invention_code.fit inv; page.add_invention_term }
        @prior_approval.each { |pa| page.prior_approval_code.fit pa; page.add_prior_approval_term }
        @property.each { |prop| page.property_code.fit prop; page.add_property_term }
        @publication.each { |pub| page.publication_code.fit pub; page.add_publication_term }
        @referenced_document.each { |ref| page.referenced_document_code.fit ref; page.add_referenced_document_term }
        @rights_in_data.each { |rid| page.rights_in_data_code.fit rid; page.add_rights_in_data_term }
        @subaward_approval.each { |sa| page.subaward_approval_code.fit sa; page.add_subaward_approval_term }
        @travel_restrictions.each { |tr| page.travel_restrictions_code.fit tr; page.add_travel_restrictions_term }
      end
      page.save
    end
  end

end