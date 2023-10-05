# frozen_string_literal: true

require "system_helper"

RSpec.describe "API Documentation" do
  it "visits homepage" do
    visit api_documentation_path

    # Homepage should be "A propos"
    #
    expect(page).to have_selector("h1", text: "A propos")

    # There should be a navbar
    #
    navbar = find(".navbar")

    expect(navbar).to have_link("A propos")
    expect(navbar).to have_link("Authentification")

    click_on "Authentification"

    # The browser should visit the Authentification page
    #
    expect(page).to have_current_path(api_documentation_path("guides/authentification"))
    expect(page).to have_selector("h1", text: "Authentification")
  end

  it "visits a missing page" do
    visit api_documentation_path("guides/jenexistepas")
    expect(page).to have_selector("h1", text: "La page que vous recherchez n'est pas disponible.")

    visit api_documentation_path("jenexistepas")
    expect(page).to have_selector("h1", text: "La page que vous recherchez n'est pas disponible.")
  end

  it "visits A Propos" do
    visit api_documentation_path("guides/a_propos")
    expect(page).to have_selector("h1", text: "A propos")
  end

  it "visits Authentification" do
    visit api_documentation_path("guides/authentification")
    expect(page).to have_selector("h1", text: "Authentification")
  end
end
