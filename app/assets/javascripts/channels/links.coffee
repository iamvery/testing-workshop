App.links = App.cable.subscriptions.create "LinksChannel",
  connected: ->
    # Called when the subscription is ready for use on the server
    console.log("connected")

  disconnected: ->
    # Called when the subscription has been terminated by the server
    console.log("disconnected")

  received: (data) ->
    # Called when there's incoming data on the websocket for this channel
    console.log("received")
    @process(data)

  process: (data) ->
    switch data.action
      when "create" then @addLink(data.link)
      when "destroy" then @removeLink(data.link)

  addLink: (link) ->
    $("ul").append(link.rendered)

  removeLink: (link) ->
    $("[data-link-id=#{link.id}]").remove()
