require 'em-synchrony/em-http'

require 'capybara'
require 'capybara/dsl'
require 'headless'

Capybara.javascript_driver = :selenium
Capybara.current_driver = :selenium
Capybara.app_host = 'http://www.youtube.com'
Capybara.default_selector = :css

class YoutubeAudio::Url
  include Capybara::DSL

  def initialize(id)
    @id = id
  end

  @@headless_started = nil
  def ensure_headless
    return if @@headless_started
    headless = Headless.new(:display => Process.pid, :reuse => true)
    headless.start
    @@headless_started = true
  end

  def video_url
    ensure_headless
    visit "/html5"
    page.find('#html5-join-link a').click
    sleep 0.1 until page.find('#html5-join-link a').text =~ /Leave/
    visit "/watch?v=#{@id}"
    url = page.find('video')['src']
    page.driver.reset!
    url
  end
end
