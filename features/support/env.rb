require 'yaml'
require 'watir-webdriver'

$base_url = ENV['URL']
$context = ENV['CONTEXT']
$port = ENV['PORT'].to_s
$file_folder = "#{File.dirname(__FILE__)}/../../lib/resources/"
$cas = ENV['CAS']
$cas_context = $cas? ENV['CAS_CONTEXT'] : ''

if ENV['HEADLESS']
  require 'headless'
  #display = Time.now.to_i
  #Headless.new(display: display).start
  Headless.new.start
end

require "#{File.dirname(__FILE__)}/../../lib/kuality-coeus"
require 'rspec/matchers'

World Foundry
World StringFactory
World DateFactory
World Utilities

kuality = Kuality.new ENV['BROWSER'].to_sym

# Hooks...

Before do
  @browser = kuality.browser

  if @browser.windows.size > 1
    DEBUG.message 'closing extra windows...'
    @browser.windows[1..-1].each { |w| w.close }
    @browser.windows[0].use
  end

  # clear browser cache for when multiple scenarios are run and pages fail to load correctly
  @browser.cookies.clear

  x = false
  i = 0
  until x
    raise 'Unable to open the login page.' if i == 20
    i += 1
    visit Login do |page|
      x = page.username.present?
    end
  end

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
    # DEBUG
    DEBUG.message "#{Time.now} Failed on #{@browser.url}"
    @browser.goto 'https://www.google.com'
    # DEBUG - Remove this if possible:
    sleep 30
    @browser.goto $base_url+$context
  end
  @browser.cookies.clear
end
