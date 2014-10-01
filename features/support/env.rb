# this is from /var/lib/jenkins/.rvm/gems/ruby-1.9.3-p448/gems/kuality-coeus-0.0.4/features/support/env.rb
require 'yaml'
require 'watir-webdriver'

config = YAML.load_file("#{File.dirname(__FILE__)}/config.yml")
basic = config[:basic]

$base_url = basic[:url]
$context = basic[:context]
$port = basic[:port].to_s
$file_folder = "#{File.dirname(__FILE__)}/../../lib/resources/"

$cas = config[:cas]
$cas_context = config[:cas_context]

if config[:headless]
  require 'headless'
  headless = Headless.new
  headless.start
end

require "#{File.dirname(__FILE__)}/../../lib/kuality-coeus"
require 'rspec/matchers'

World Foundry
World StringFactory
World DateFactory
World Utilities

# Uncomment when fix to logging in/out arrives
#kuality = Kuality.new basic[:browser]

Before do
  # Get the browser object

  # REMOVE when logging in/out is fixed!!!
  kuality = Kuality.new basic[:browser]

  @browser = kuality.browser
  # Clean out any users that might exist
  $users.clear
  $current_user=nil
  # Add the admin user to the Users...
  $users << UserObject.new(@browser)
end

After do |scenario|
  # Grab a screenshot
  if scenario.failed?
    @browser.screenshot.save 'screenshot.png'
    embed 'screenshot.png', 'image/png'
  end
  # Log out if not already
  # @browser.goto "#{$base_url+$context}logout.do"

  # A temp solution while the logout problem exists...
  @browser.close
end

# Uncomment when fix to logging in/out arrives
#at_exit { kuality.browser.close }