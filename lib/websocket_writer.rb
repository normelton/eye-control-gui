class EyeControl::WebsocketWriter
  include Celluloid
  include Celluloid::Notifications
  include Celluloid::Logger

  def initialize(websocket)
    @socket = websocket
    subscribe("state_change", :broadcast_state_change)
    async.broadcast_all_states
  end

  def broadcast_all_states
    state = Celluloid::Actor[:redis].future.get_processes.value
    transmit_message ({:event => "state:refresh", :processes => state}).to_json
  end

  def broadcast_state_change(topic, state)
    transmit_message ({:event => "state:change", :process => state}).to_json
  end

  def transmit_message msg
    info "Transmitting #{msg}"
    @socket << msg
  rescue Reel::SocketError
    info "WebsocketWriter client disconnected"
    terminate
  end
end