class EyeControl::WebsocketReader
  include Celluloid
  include Celluloid::Notifications
  include Celluloid::Logger

  def initialize(websocket)
    @socket = websocket
    async.handle_incoming_messages
  end

  def handle_incoming_messages
    info "Waiting for messages"

    while msg = @socket.read
      begin
        evt = JSON.parse msg
        Celluloid::Actor[:redis].broadcast evt
      rescue
        error "WebsocketReader could not parse incoming message"
      end
      info "GOT MESSAGE #{msg}"
    end

  rescue Reel::SocketError, IOError
    info "WebsocketReader client disconnected"
    terminate
  end
end