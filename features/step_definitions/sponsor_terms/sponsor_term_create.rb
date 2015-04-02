When /^the Application Administrator user submits a new Sponsor Term$/ do
  steps %{ * I log in with the Application Administrator user }
  @sponsor_term = create SponsorTermObject
end

When /^the Application Administrator user submits a new Sponsor Term with a missing required field$/ do
  steps %{ * I log in with the Application Administrator user }
  @required_field = ['Description', 'Sponsor Term Id', 'Sponsor Term Code',
                     'Sponsor Term Type Code', 'Sponsor Term Description'
  ].sample
  @required_field=~/(Type|Status)/ ? value='select' : value=' '
  field = damballa(@required_field)
  @sponsor_term = create SponsorTermObject, field=>value

  text = ' is a required field.'
  errors = {description: "Document Description (Description)#{text}",
            sponsor_term_id: "Sponsor Term Id (Sponsor Term Id)#{text}",
            sponsor_term_code: "Code (Sponsor Term Code)#{text}",
            sponsor_term_type_code: "Sponsor Term Type Code (Sponsor Term Type Code)#{text}",
            sponsor_term_description: "Description (Description)#{text}"
  }
  @required_field_error = errors[field]
end