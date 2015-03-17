class Rates < BasePage

  buttons 'Sync All Rates', 'Refresh All Rates'
  links 'Research F & A', 'Fringe Benefits', 'Inflation', 'Vacation', 'Lab Allocation - Salaries', 'Lab Allocation - Other', 'Other'

  p_element(:applicable_rate) { |desc, on_camp, f_yr, b| b.visible_table.tr(text: /^#{desc}.+#{on_camp}.+#{f_yr}/m).text_field(name: /applicableRate$/) }

  # Rates
  value(:rates) { |b|
    hash = {}
    InstituteRateObject::RATE_CLASS_TYPES.each { |code, name|
      hash.store(name, extractor(b.noko_tbody code))
    }
    hash
  }

  private

  element(:visible_table) { |b| b.tables(class: 'table table-condensed table-bordered uif-tableCollectionLayout dataTable').find { |table| table.visible? } }

  p_value(:noko_tbody) { |id, b| b.no_frame_noko.table(id: /_#{id}$/).tbody }

  def self.extractor(tbody)
    array = []

    if tbody.exist?
      tbody.trs.each { |tr|
        unless tr.id==''
          @rate_class_code=tr.text
          next
        end
        array << { rate_class_code: @rate_class_code,
                   description:     tr.td(index: 0).text,
                   on_campus:       tr.td(index: 1).text,
                   fiscal_year:     tr.td(index: 2).text,
                   start_date:      Utilities.datify(tr.td(index: 3).text),
                   institute_rate:  tr.td(index: 4).text.to_f,
                   applicable_rate: tr.text_field(name: /applicableRate/).value.to_f }
      }
    end
    array
  end

end