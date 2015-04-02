class ParameterLookup < Lookups

  expected_element :parameter_name

  url_info 'Parameter', 'rice.coreservice.impl.parameter.ParameterBo'

  element(:parameter_name) { |b| b.frm.text_field(id: 'name') }

end