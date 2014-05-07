require 'rubygems'
require 'bundler/setup'
require 'reel'
require "celluloid/redis"
require 'celluloid/autostart'

module EyeControl
  ROOT = File.expand_path(File.dirname(__FILE__))

  autoload :RedisManager,         "#{ROOT}/redis_manager"
  autoload :WebsocketWriter,      "#{ROOT}/websocket_writer"
  autoload :WebsocketReader,      "#{ROOT}/websocket_reader"
  autoload :WebServer,            "#{ROOT}/web_server"
end