class LinksController < ApplicationController
  def index
    @links = Link.all
  end

  def create
    link = Link.create!(link_params)
    broadcast_create(link)
    redirect_to links_path
  end

  def destroy
    link = Link.find(link_id)
    link.destroy!
    broadcast_destroy(link)
    redirect_to links_path
  end

  private

  def link_id
    params.fetch(:id)
  end

  def link_params
    params.require(:link).permit(:url)
  end

  def broadcast_create(link)
    # TODO extract job object
    rendered_link = ApplicationController.render(partial: "links/link", locals: { link: link })
    ActionCable.server.broadcast(LinksChannel::STREAM, action: :create, link: { rendered: rendered_link })
  end

  def broadcast_destroy(link)
    ActionCable.server.broadcast(LinksChannel::STREAM, action: :destroy, link: link)
  end
end
