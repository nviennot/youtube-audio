require 'cgi'
require 'open-uri'

class YoutubeAudio::Url

  def initialize(id)
    @id = id
  end

  def video_url
    #todo - avoid hitting disk
    info = open(info_url).readline
    formats = CGI::parse(info)["adaptive_fmts"][0]
    first_url = CGI::parse(formats)["url"][0]
    first_url
  end

  private

  def info_url
    "http://www.youtube.com/get_video_info?video_id=#{@id}"
  end
end
