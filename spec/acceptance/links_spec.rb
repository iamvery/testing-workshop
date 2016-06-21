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

  describe "creating link" do
    it "adds the link to the index" do
      visit links_path

      fill_in "Url", with: "http://iamvery.com"
      click_on "Create Link"

      expect(page).to have_content("iamvery.com")
    end
  end

  describe "deleting link" do
    it "removes the link from the index" do
      Link.create!(url: "http://iamvery.com")

      visit links_path

      click_on "×"

      expect(page).not_to have_content("iamvery.com")
    end
  end
end
