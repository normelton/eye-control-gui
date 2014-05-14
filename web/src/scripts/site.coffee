$(document).ready =>
  window.App = {}

  App.Processes = {}

  App.Functions = {
    init: =>
      App.Functions.initWebSocket()
      App.Functions.initCallbacks()

    initWebSocket: =>
      App.websocket = new WebSocket("ws://" + window.location.host)

      # console.log "Using bogus websocket servername, fix this!"
      # App.websocket = new WebSocket("ws://localhost:8080")

      App.websocket.onmessage = App.Functions.onMessage

      App.websocket.onopen = =>
        $("div.header").addClass("connected")

      App.websocket.onclose = =>
        $("div.header").removeClass("connected")
        setTimeout((=> App.Functions.initWebSocket()), 2000)

    initCallbacks: =>
      $("body").on("click", "label.process input[type='checkbox']", App.Functions.toggleProcess)
      $("div.actions").on("click", "a.start", App.Functions.startProcess)
      $("div.actions").on("click", "a.stop", App.Functions.stopProcess)
      $("div.actions").on("click", "a.restart", App.Functions.restartProcess)
      $(window).bind("scroll", App.Functions.scroll)
      $("body").on("click", "ul.topology", App.Functions.toggleGroup)

    scroll: (evt) =>
      $("div.actions").toggleClass("floating", $(window).scrollTop() > 101)
      $("div.dummy").toggleClass("hidden", $(window).scrollTop() <= 101)

    toggleProcess: (evt) =>
      process_count = $("label.process input:checked").length

      if process_count > 0
        $("div.actions").removeClass("disabled")
      else
        $("div.actions").addClass("disabled")

      $("div.actions span.count").text("#{process_count} selected process#{if process_count > 1 then 'es' else ''}")

    toggleGroup: (evt) =>
      el_checkboxes = $(evt.currentTarget).closest("div.group").find("input[type='checkbox']")

      if el_checkboxes.not(":checked").length > 0
        el_checkboxes.prop("checked", true)
      else
        el_checkboxes.prop("checked", false)

      App.Functions.toggleProcess()

    startProcess: (evt) =>
      App.Functions.selectedProcesses().each (i, el) =>
        process = $(el).data("process")
        evt = _.extend({event: "process:start"}, process)
        App.websocket.send(JSON.stringify(evt))

    stopProcess: (evt) =>
      App.Functions.selectedProcesses().each (i, el) =>
        process = $(el).data("process")
        evt = _.extend({event: "process:stop"}, process)
        App.websocket.send(JSON.stringify(evt))

    restartProcess: (evt) =>
      App.Functions.selectedProcesses().each (i, el) =>
        process = $(el).data("process")
        evt = _.extend({event: "process:restart"}, process)
        App.websocket.send(JSON.stringify(evt))

    selectedProcesses: =>
      $("label.process").filter((i, el) => $(el).find("input[type='checkbox']").is(":checked"))

    onMessage: (msg) =>
      evt = JSON.parse(msg.data)

      if evt.event == "state:refresh"
        App.Processes = {}

        _.each evt.processes, (process) =>
          key = App.Functions.processKey(process)
          App.Processes[key] = process

        App.Functions.renderAll()

      else
        key = App.Functions.processKey(evt.process)
        App.Processes[key] = evt.process

        App.Functions.renderProcess(evt.process)

    processKey: (process) =>
      [process.host, process.application, process.group, process.name].join(":")

    renderAll: =>
      _.each App.Processes, App.Functions.renderProcess

    renderProcess: (process) =>
      el_process = App.Functions.getProcessElement(process)

      el_status = el_process.find("i.status")
      el_status.removeClass("fa-circle fa-spinner fa-spin fa-question green red orange")

      if process.state == "up"
        el_process.find("i.status").addClass("fa-circle green")

      else if process.state == "down"
        el_process.find("i.status").addClass("fa-circle red")

      else if process.state == "starting" || process.state == "restarting"
        el_process.find("i.status").addClass("fa-spinner fa-spin green")

      else if process.state == "stopping"
        el_process.find("i.status").addClass("fa-spinner fa-spin red")

      else if process.state == "unmonitored"
        el_process.find("i.status").addClass("fa-question-circle orange")

      else
        console.log process.state

      state_time = new Date(process.state_changed_at * 1000).toLocaleString()

      if process.state == "up" || process.state == "down"
        el_process.find("span.caption").text("since #{state_time}")
      else
        el_process.find("span.caption").text("#{process.state_reason}, #{state_time}")

      el_process.find("input[type=checkbox]").prop("disabled", process.control == "readonly")

      el_status = el_process.find("i.status")

    getProcessElement: (process) =>
      el_group = App.Functions.getGroupElement(process)

      el_process = el_group.find("label.process").filter((i, e) => $(e).data("name") == process.name)

      if el_process.length == 0
        el_process = $("<label>").addClass("process").data("name", process.name).data("process", process)
        el_process.append $("<input>").attr("type", "checkbox")
        el_process.append $("<i>").addClass("status fa fa-fw fa-circle green")
        el_process.append $("<span>").addClass("name").text(process.name)
        el_process.append $("<span>").addClass("caption")

        el_process.appendTo el_group
        el_group.find("label.process").sortElements((a, b) => if $(a).data("name") > $(b).data("name") then 1 else -1)

      return el_process

    getGroupElement: (process) =>
      el_host = App.Functions.getHostElement(process)

      el_group = el_host.find("div.group").filter((i, e) => $(e).data("host") == process.host && $(e).data("application") == process.application && $(e).data("group") == process.group)

      if el_group.length == 0
        topology = []
        topology.push process.application
        topology.push process.group unless process.group == "__default__"

        el_group = $("<div>").addClass("group").data("topology", topology).data("host", process.host).data("application", process.application).data("group", process.group)

        el_topology = $("<ul>").addClass("topology")
        el_topology.append $("<li>").text(name) for name in topology
        el_topology.appendTo el_group

        el_group.appendTo el_host
        el_host.find("div.group").sortElements((a, b) => if $(a).data("topology") > $(b).data("topology") then 1 else -1)

      return el_group

    getHostElement: (process) =>
      el_host = $("div.host").filter((i, e) => $(e).data("host") == process.host)

      if el_host.length == 0
        el_host = $("<div>").data("host", process.host).addClass("host")
        el_host.append $("<p>").addClass("name").text(process.host)

        el_host.appendTo("body")
        $("body").find("div.host").sortElements((a, b) => if $(a).data("host") > $(b).data("host") then 1 else -1)

      return el_host
  }

  $(document).ready => App.Functions.init()




