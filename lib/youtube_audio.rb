class YoutubeAudio < Goliath::API
  require 'youtube_audio/url'

  class AudioCoder < EventMachine::Connection
    def initialize(env)
      super
      @env = env
    end

    def self.cmd(url)
      #"sh -c \"curl -s '#{url}' -H 'Connection: keep-alive' -H 'Cache-Control: no-cache' | ffmpeg -i - -vn -f mp3 - \""

      #runs video crazy fast
      #"sh -c \"curl -s '#{url}' -H 'Connection: keep-alive' -H 'Cache-Control: no-cache' \""

      #what is this stream data type anyway? (text/plain on youtube)

      #ffmpeg is converting this data to mp3
      #-vn means disable video recording
      "sh -c \"echo test\""
    end

    #EM#receive_data - Generally called by the event loop whenever data has been received by the network connection, but since we are using popen, it will be called whenever data is received by the process
    def receive_data(data)
      #Goliath - stream send gives us direct access to the underlying connection
      @env.stream_send(data)
    end

    #EM#unbind - Called when the client is fully disconnected
    def unbind
      @env.stream_close
    end
  end

  use Goliath::Rack::Params

  def on_close(env)

    #why not just put env.stream_close in here?
    #how does env['decoder'] get set? (this may be a bug, and thus the reason for the rescue nil)
    #shouldn't unbind only get called by the framework, not the user?

    #when the connection is closed, call unbind in the EM class
    env['decoder'].try(:unbind) rescue nil
  end

  def response(env)
    @i ||= 0
    @i += 1
    puts "request #{@i}"
    #puts "Fetching video=#{params['v']}"
    video_url = Url.new(params['v']).video_url
    #puts "link: #{video_url}"
    #puts AudioCoder.cmd(video_url)
    #for some reason this causes several requests to be made

    #EventMachine.defer is used for integrating blocking operations into EventMachine's control flow.
    #http://futurechimp.org/2010/1/17/ruby-procs-and-eventmachine-callbacks
    #so why not use that here?
    #decoder = EventMachine.popen(AudioCoder.cmd(video_url), AudioCoder, env)

    pt = EM.add_periodic_timer(1) do
      env.stream_send("test")
    end

    EM.add_timer(10) do
      pt.cancel
      env.stream_send("YEA!")
      env.stream_close
    end

    #Doesn't this perform the same function ass 'on_close' above?
    #env[ASYNC_CLOSE] = proc do
      #unless env['closed']
        #env['closed'] = true
        #decoder.close_connection
      #end
    #end

    [200, {}, Goliath::Response::STREAMING]
  #rescue
    #[500, {}, 'we oopsed']
  end
end
