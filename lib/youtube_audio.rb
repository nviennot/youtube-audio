class YoutubeAudio < Goliath::API
  require 'youtube_audio/url'

  class AudioCoder < EventMachine::Connection
    def initialize(env)
      super()
      @env = env
    end

    def self.cmd(url)
      "sh -c \"curl '#{url}' | ffmpeg -i - -vn -c:a copy -f webm - 2> /dev/null\""
    end

    def receive_data(data)
      @env.stream_send(data)
    end

    def unbind
      @env.stream_close
    end
  end

  def response(env)
    EventMachine.popen(AudioCoder.cmd(Url.new), AudioCoder, env)
    [200, {}, Goliath::Response::STREAMING]
  end
end
