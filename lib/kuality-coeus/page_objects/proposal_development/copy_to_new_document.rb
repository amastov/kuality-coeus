class CopyToNewDocument < BasePage

  element(:lead_unit) { |b| b.select(name: 'proposalCopyCriteria.leadUnitNumber') }

  action(:copy) { |b| b.button(text: 'Copy...').click; b.loading }

end