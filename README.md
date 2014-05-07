Eye Control
===

A GUI for monitoring servers running [Eye](http://github.com/kostya/eye).

![Screenshot](https://raw.github.com/normelton/eye-control/master/web/src/images/screenshot.png)


### Eye Configuration

Each Eye server will report its state to a centralized [Redis](http://redis.io) Redis server. This must be configured on each Eye server:

```ruby
Eye.config do
  logger '/tmp/eye.log'
  control_server '192.168.1.5'
end
```

By default, the Eye process will also respond to start / stop / restart requests coming from Eye Control. This can be disabled by running in read-only mode:

```ruby
Eye.config do
  logger '/tmp/eye.log'
  control_server '192.168.1.5', :mode => :readonly
end
```

### Eye Control Server

Start the Eye Control by running `./bin/eye-control`. The web GUI is accessible on port 8080. The server hosts static files and handles WebSocket requests. There is no dynamic HTML generation on the server.

### Security

Right now, there are no security measures in place. Ensure that only legitimate clients can connect to your Eye Control and Redis server.

### Tweaking the GUI

The HTML / CSS / Javascript files are generated from HAML / SCSS / CoffeeScript files located in `web/src`. A `gulpfile.js` is provided to help build the output.