module DEBUG

  class << self

    def message(text='We got here!')
      puts text
    end

    def pause(seconds=30)
      puts "Pausing #{seconds} seconds..."
      sleep seconds - 3
      puts 'Three...'
      sleep 1
      puts 'Two...'
      sleep 1
      puts 'One...'
      sleep 1
      puts 'Resuming...'
    end

    def do message='Performing debug code block...', &block
      puts message
      yield block
      puts 'Successfully completed debug code!'
      puts 'Now back to your regularly scheduled program...'
    end

    def inspect_watir_element(element)
      puts "Visible: #{element.visible?}"
      puts 'Style:'
      puts element.style
      puts 'Tag name:'
      puts element.tag_name
      puts 'Parent:'
      puts element.parent
      puts 'HTML:'
      puts element.outer_html
    end
    alias_method :watir_element_inspect, :inspect_watir_element
    alias_method :element_inspect, :inspect_watir_element
    alias_method :inspect_element, :inspect_watir_element

    def inspect object
      puts
      puts "Inspection of #{object.class}..."
      puts object.pretty_inspect
    end

    def inspects *objects
      objects.each { |o| inspect o }
    end

    def snap(b, png='debug_capture')
      b.screenshot.save "#{png}.png"
    end

  end

  PageFactory.p_element(:define_elements) { |b|
    b.frm.text_fields.each { |t|
      puts 'element(:' + t.name.to_s.gsub(/([a-z])([A-Z])/ , '\1_\2').downcase + ') { |b| b.frm.text_field(name: \'' + t.name.to_s + '\') }'
    }

  }

end