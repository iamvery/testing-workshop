require "rails_helper"

RSpec.describe "Links", type: :feature do
  describe "viewing links" do
    it "displays all links" do
      Link.create!(url: "http://iamvery.com")
      Link.create!(url: "http://google.com")

      visit links_path

      expect(page).to have_content("iamvery.com")
      expect(page).to have_content("google.com")
    end
  end
end
