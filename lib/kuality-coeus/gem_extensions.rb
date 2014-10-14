module Watir
  module Container
    def frm
      case
        when div(id: 'embedded').exists?
          iframe(id: /easyXDM_default\d+_provider/).iframe(id: 'iframeportlet')
        when div(id: 'Uif-ViewContentWrapper').exists?
          iframe(class: 'uif-iFrame uif-boxLayoutVerticalItem pull-left clearfix')
        else
          self
      end
    end
  end
end

class DataFactory

  private

  # This overrides the method in the TestFactory.
  # We need this here because of the special way that
  # KC defines radio buttons. See below...
  def parse_fields(opts, name, page, *fields)
    watir_methods=[ lambda{|n, p, f, v| p.send(*[f, n].compact).fit(v) }, # Text & Checkbox
                    lambda{|n, p, f, v| p.send(*[f, n].compact).pick!(v) }, # Select
                    lambda{|n, p, f, v| p.send(*[f, n].compact, v) } # Radio
    ]
    fields.each do |field|
      # This rescue is here because the radio button
      # "element" definitions are *actions* that
      # require a parameter, so just sending the method to the page
      # is not going to work.
      begin
        x = page.send(*[field, name].compact).class.to_s=='Watir::Select' ? 1 : 0
      rescue NoMethodError
        x = 2
      end
      val = opts.nil? ? instance_variable_get("@#{field}") : opts[field]
      watir_methods[x].call(name, page, field, val)
    end
  end

end