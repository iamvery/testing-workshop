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
    @addLink(data.link)

  addLink: (link) ->
    $("ul").append(link.rendered)
