class ProtocolException < KCProtocol

  element(:exception) { |b| b.frm.select(name: 'iacucProtocolExceptionHelper.newIacucProtocolException.exceptionCategoryCode') }
  element(:species) { |b| b.frm.select(name: 'iacucProtocolExceptionHelper.newIacucProtocolException.speciesCode') }
  element(:justification) { |b| b.frm.textarea(name: 'iacucProtocolExceptionHelper.newIacucProtocolException.exceptionDescription') }

  action(:add_exception) { |b| b.frm.button(name: 'methodToCall.addProtocolException.anchorProtocolExceptions').click; b.loading }

end