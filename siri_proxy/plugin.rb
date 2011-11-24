class SiriProxy::Plugin
  attr_accessor :plugin_manager, :connection

  class << self

    def listen_for(regex, &block)
      default_listeners[regex] = block
    end

    def default_listeners
      @default_listeners ||= {}
    end

  end

  def default_listeners
    self.class.default_listeners
  end

  def say(text)
    log "Say: #{text}"
    connection.inject_object_to_output_stream(generate_siri_utterance(connection.last_ref_id, text))
  end

  # Old plugin stuff
  def initialize(pluginConfig)

  end

  def object_from_guzzoni(object, connection)

    object
  end


  #Don't forget to return the object!
  def object_from_client(object, connection)

    object
  end


  def unknown_command(object, connection, command)

    object
  end

  def speech_recognized(object, connection, phrase)

    object
  end

  private

  def log(text)
    $stderr.puts(text)
  end

end
