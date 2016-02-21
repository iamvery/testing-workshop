class LinksController < ApplicationController
  def index
    @links = Link.all
  end

  def create
    Link.create!(link_params)
    redirect_to links_path
  end

  def destroy
    link = Link.find(link_id)
    link.destroy!
    redirect_to links_path
  end

  private

  def link_id
    params.fetch(:id)
  end

  def link_params
    params.require(:link).permit(:url)
  end
end
