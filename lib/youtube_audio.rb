class YoutubeAudio < Goliath::API
  require 'youtube_audio/url'

  class AudioCoder < EventMachine::Connection
    def initialize(env)
      super()
      @env = env
    end

    def self.cmd(url)
      "sh -c \"curl '#{url}' 2>/dev/null | ffmpeg -i - -vn -c:a copy -f webm - 2> /dev/null\""
    end

    def receive_data(data)
      @env.stream_send(data)
    end

    def unbind
      @env.stream_close
    end
  end

  use Goliath::Rack::Params

  def on_close(env)
    env['decoder'].try(:unbind) rescue nil
  end

  def response(env)
    video_url = Url.new(params['v']).video_url
    logger.info "Fetching video=#{params['v']}"
    logger.debug "link: #{video_url}"

    decoder = EventMachine.popen(AudioCoder.cmd(video_url), AudioCoder, env)
    env[ASYNC_CLOSE] = proc do
      unless env['closed']
        env['closed'] = true
        decoder.close_connection
      end
    end

    [200, {}, Goliath::Response::STREAMING]
  end
end
