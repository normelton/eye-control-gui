Eye Control GUI
===

A GUI for monitoring servers running [Eye](http://github.com/kostya/eye).

![Screenshot](https://raw.github.com/normelton/eye-control-gui/master/web/src/images/screenshot.png)

### Eye Configuration

A plugin gem, located at http://github.com/normelton/eye-control, must be loaded and configured in your Eye configuration file.

### Eye Control Server

Start the Eye Control by running `./bin/eye-control`. The web GUI is accessible on port 8080. The server hosts static files and handles WebSocket requests. There is no dynamic HTML generation on the server.

### Security

Right now, there are no security measures in place. Ensure that only legitimate clients can connect to your Eye Control and Redis server.

### Tweaking the GUI

The HTML / CSS / Javascript files are generated from HAML / SCSS / CoffeeScript files located in `web/src`. A `gulpfile.js` is provided to help build the output.