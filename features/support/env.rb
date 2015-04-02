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

kuality = Kuality.new basic[:browser]

Before do
  @browser = kuality.browser
  # clear browser cache for when multiple scenarios are run and pages fail to load correctly
  @browser.cookies.clear
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
  @browser.cookies.clear
end

at_exit { kuality.browser.close }
