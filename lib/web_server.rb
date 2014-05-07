class EyeControl::WebServer < Reel::Server::HTTP
  include Celluloid::Logger

  RESOURCES = {
    "/"                                       => File.read("web/build/index.html"),
    "/stylesheets/vendor/normalize.css"       => File.read("web/build/stylesheets/vendor/normalize.css"),
    "/stylesheets/site.css"                   => File.read("web/build/stylesheets/site.css"),
    "/scripts/vendor/modernizr-2.6.2.min.js"  => File.read("web/build/scripts/vendor/modernizr-2.6.2.min.js"),
    "/scripts/vendor/jquery-1.11.0.min.js"    => File.read("web/build/scripts/vendor/jquery-1.11.0.min.js"),
    "/scripts/vendor/underscore-1.6.0.min.js" => File.read("web/build/scripts/vendor/underscore-1.6.0.min.js"),
    "/scripts/vendor/jquery-sortElements.js"  => File.read("web/build/scripts/vendor/jquery-sortElements.js"),
    "/scripts/site.js"                        => File.read("web/build/scripts/site.js"),
    "/images/server.png"                      => File.read("web/build/images/server.png")
  }

  def initialize args = {}
    args[:host] ||= "127.0.0.1"
    args[:port] ||= 8080

    info "Web server starting on #{args[:host]}:#{args[:port]}"
    super(args[:host], args[:port], &method(:on_connection))
  end

  def on_connection(connection)
    while request = connection.request
      if request.websocket?
        info "Received a WebSocket connection"

        route_websocket request.websocket
        return
      else
        route_request connection, request
      end
    end
  end

  def route_request(connection, request)
    if response = RESOURCES[request.url]
      info "200 OK: /"
      connection.respond :ok, response
    else
      info "404 Not Found: #{request.path}"
      connection.respond :not_found, "Not found"
    end
  end

  def route_websocket(socket)
    if socket.url == "/"
      EyeControl::WebsocketWriter.new(socket)
      EyeControl::WebsocketReader.new(socket)
    else
      socket.close
    end
  end
end