class ProtocolException < KCProtocol

  element(:exception) { |b| b.frm.select(name: 'iacucProtocolExceptionHelper.newIacucProtocolException.exceptionCategoryCode') }
  value(:exception_list) { |b| b.noko.select(name: 'iacucProtocolExceptionHelper.newIacucProtocolException.exceptionCategoryCode').options.map {|opt| opt.text }.tap(&:shift) }
  element(:species) { |b| b.frm.select(name: 'iacucProtocolExceptionHelper.newIacucProtocolException.speciesCode') }
  element(:justification) { |b| b.frm.textarea(name: 'iacucProtocolExceptionHelper.newIacucProtocolException.exceptionDescription') }

  action(:add_exception) { |b| b.frm.button(name: 'methodToCall.addProtocolException.anchorProtocolExceptions').click; b.loading }

end