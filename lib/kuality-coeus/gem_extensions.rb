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