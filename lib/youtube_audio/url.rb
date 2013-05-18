require 'em-synchrony/em-http'

require 'capybara'
require 'capybara/dsl'
require 'capybara/poltergeist'

Capybara.javascript_driver = :poltergeist
Capybara.current_driver = :poltergeist
Capybara.app_host = 'http://www.youtube.com'
Capybara.default_selector = :css

class YoutubeAudio::Url
  include Capybara::DSL

  def initialize(id)
    @id = id
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
