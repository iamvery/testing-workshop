# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class LinksChannel < ApplicationCable::Channel
  STREAM = "links".freeze

  def subscribed
    stream_from(STREAM)
  end

  def unsubscribed
    stop_all_streams
  end
end
