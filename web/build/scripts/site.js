(function() {
  $(document).ready((function(_this) {
    return function() {
      window.App = {};
      App.Processes = {};
      App.Functions = {
        init: function() {
          App.Functions.initWebSocket();
          return App.Functions.initCallbacks();
        },
        initWebSocket: function() {
          App.websocket = new WebSocket("ws://" + window.location.host);
          App.websocket.onmessage = App.Functions.onMessage;
          App.websocket.onopen = function() {
            return $("div.header").addClass("connected");
          };
          return App.websocket.onclose = function() {
            $("div.header").removeClass("connected");
            return setTimeout((function() {
              return App.Functions.initWebSocket();
            }), 2000);
          };
        },
        initCallbacks: function() {
          $("body").on("click", "label.process input[type='checkbox']", App.Functions.toggleProcess);
          $("div.actions").on("click", "a.start", App.Functions.startProcess);
          $("div.actions").on("click", "a.stop", App.Functions.stopProcess);
          $("div.actions").on("click", "a.restart", App.Functions.restartProcess);
          return $("body").on("click", "ul.topology", App.Functions.toggleGroup);
        },
        toggleProcess: function(evt) {
          if ($("label.process input:checked").length > 0) {
            return $("div.actions").removeClass("disabled");
          } else {
            return $("div.actions").addClass("disabled");
          }
        },
        toggleGroup: function(evt) {
          var el_checkboxes;
          el_checkboxes = $(evt.currentTarget).closest("div.group").find("input[type='checkbox']");
          if (el_checkboxes.not(":checked").length > 0) {
            el_checkboxes.prop("checked", true);
          } else {
            el_checkboxes.prop("checked", false);
          }
          return App.Functions.toggleProcess();
        },
        startProcess: function(evt) {
          return App.Functions.selectedProcesses().each(function(i, el) {
            var process;
            process = $(el).data("process");
            evt = _.extend({
              event: "process:start"
            }, process);
            return App.websocket.send(JSON.stringify(evt));
          });
        },
        stopProcess: function(evt) {
          return App.Functions.selectedProcesses().each(function(i, el) {
            var process;
            process = $(el).data("process");
            evt = _.extend({
              event: "process:stop"
            }, process);
            return App.websocket.send(JSON.stringify(evt));
          });
        },
        restartProcess: function(evt) {
          return App.Functions.selectedProcesses().each(function(i, el) {
            var process;
            process = $(el).data("process");
            evt = _.extend({
              event: "process:restart"
            }, process);
            return App.websocket.send(JSON.stringify(evt));
          });
        },
        selectedProcesses: function() {
          return $("label.process").filter(function(i, el) {
            return $(el).find("input[type='checkbox']").is(":checked");
          });
        },
        onMessage: function(msg) {
          var evt, key;
          evt = JSON.parse(msg.data);
          if (evt.event === "state:refresh") {
            App.Processes = {};
            _.each(evt.processes, function(process) {
              var key;
              key = App.Functions.processKey(process);
              return App.Processes[key] = process;
            });
            return App.Functions.renderAll();
          } else {
            key = App.Functions.processKey(evt.process);
            App.Processes[key] = evt.process;
            return App.Functions.renderProcess(evt.process);
          }
        },
        processKey: function(process) {
          return [process.host, process.application, process.group, process.name].join(":");
        },
        renderAll: function() {
          return _.each(App.Processes, App.Functions.renderProcess);
        },
        renderProcess: function(process) {
          var el_process, el_status, state_time;
          el_process = App.Functions.getProcessElement(process);
          el_status = el_process.find("i.status");
          el_status.removeClass("fa-circle fa-spinner fa-spin fa-question green red orange");
          if (process.state === "up") {
            el_process.find("i.status").addClass("fa-circle green");
          } else if (process.state === "down") {
            el_process.find("i.status").addClass("fa-circle red");
          } else if (process.state === "starting" || process.state === "restarting") {
            el_process.find("i.status").addClass("fa-spinner fa-spin green");
          } else if (process.state === "stopping") {
            el_process.find("i.status").addClass("fa-spinner fa-spin red");
          } else if (process.state === "unmonitored") {
            el_process.find("i.status").addClass("fa-question-circle orange");
          } else {
            console.log(process.state);
          }
          state_time = new Date(process.state_changed_at * 1000).toLocaleString();
          if (process.state === "up" || process.state === "down") {
            el_process.find("span.caption").text("since " + state_time);
          } else {
            el_process.find("span.caption").text("" + process.state_reason + ", " + state_time);
          }
          el_process.find("input[type=checkbox]").prop("disabled", process.control === "readonly");
          return el_status = el_process.find("i.status");
        },
        getProcessElement: function(process) {
          var el_group, el_process;
          el_group = App.Functions.getGroupElement(process);
          el_process = el_group.find("label.process").filter(function(i, e) {
            return $(e).data("name") === process.name;
          });
          if (el_process.length === 0) {
            el_process = $("<label>").addClass("process").data("name", process.name).data("process", process);
            el_process.append($("<input>").attr("type", "checkbox"));
            el_process.append($("<i>").addClass("status fa fa-fw fa-circle green"));
            el_process.append($("<span>").addClass("name").text(process.name));
            el_process.append($("<span>").addClass("caption"));
            el_process.appendTo(el_group);
            el_group.find("label.process").sortElements(function(a, b) {
              if ($(a).data("name") > $(b).data("name")) {
                return 1;
              } else {
                return -1;
              }
            });
          }
          return el_process;
        },
        getGroupElement: function(process) {
          var el_group, el_host, el_topology, name, topology, _i, _len;
          el_host = App.Functions.getHostElement(process);
          el_group = el_host.find("div.group").filter(function(i, e) {
            return $(e).data("host") === process.host && $(e).data("application") === process.application && $(e).data("group") === process.group;
          });
          if (el_group.length === 0) {
            topology = [];
            topology.push(process.application);
            if (process.group !== "__default__") {
              topology.push(process.group);
            }
            el_group = $("<div>").addClass("group").data("topology", topology).data("host", process.host).data("application", process.application).data("group", process.group);
            el_topology = $("<ul>").addClass("topology");
            for (_i = 0, _len = topology.length; _i < _len; _i++) {
              name = topology[_i];
              el_topology.append($("<li>").text(name));
            }
            el_topology.appendTo(el_group);
            el_group.appendTo(el_host);
            el_host.find("div.group").sortElements(function(a, b) {
              if ($(a).data("topology") > $(b).data("topology")) {
                return 1;
              } else {
                return -1;
              }
            });
          }
          return el_group;
        },
        getHostElement: function(process) {
          var el_host;
          el_host = $("div.host").filter(function(i, e) {
            return $(e).data("host") === process.host;
          });
          if (el_host.length === 0) {
            el_host = $("<div>").data("host", process.host).addClass("host");
            el_host.append($("<p>").addClass("name").text(process.host));
            el_host.appendTo("body");
            $("body").find("div.host").sortElements(function(a, b) {
              if ($(a).data("host") > $(b).data("host")) {
                return 1;
              } else {
                return -1;
              }
            });
          }
          return el_host;
        }
      };
      return $(document).ready(function() {
        return App.Functions.init();
      });
    };
  })(this));

}).call(this);
