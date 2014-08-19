class Lookups < BasePage

  tiny_buttons
  search_results_table

  def self.url_info(title, class_name)
    riceify = class_name[/^rice/] && $base_url[/kuali/] ? $context : $context
    url = %|#{$base_url+$context
                  }portal.do?channelTitle=#{
                title
                  }&channelUrl=#{
                $base_url[/.*(?=\/$)/]+':'+$port+'/'+riceify
                  }kr/lookup.do?methodToCall=start&businessObjectClassName=org.kuali.#{
                class_name
                  }&docFormKey=88888888&includeCustomActionUrls=true&returnLocation=#{
                $base_url[/.*(?=\/$)/]+':'+$port+'/'+$context
                  }portal.do&hideReturnLink=true|
    page_url url
  end

  element(:last_name) { |b| b.frm.text_field(id: 'lastName') }
  element(:first_name) { |b| b.frm.text_field(id: 'firstName') }
  element(:full_name) { |b| b.frm.text_field(id: 'fullName') }
  element(:user_name) { |b| b.frm.text_field(id: 'userName') }
  element(:state) { |b| b.frm.select(id: 'state') }
  element(:create_button) { |b| b.frm.link(title: 'Create a new record') }
  action(:create_new) { |b| b.create_button.click; b.loading }
  alias_method :create, :create_new

end