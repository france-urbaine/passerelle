# frozen_string_literal: true

require "system_helper"

RSpec.describe "API Documentation" do
  fixtures :publishers, :users

  before { sign_in(users(:marc)) }

  it "visits homepage" do
    visit api_documentation_url

    # Homepage should be "A propos"
    #
    expect(page).to have_selector("h1", text: "A propos")

    # There should be a navbar
    #
    within ".navbar" do |navbar|
      expect(navbar).to have_link("A propos")
      expect(navbar).to have_link("Authentification")
    end

    click_on "Authentification"

    # The browser should visit the Authentification page
    #
    expect(page).to have_current_path(api_documentation_path("guides/authentification"))
    expect(page).to have_selector("h1", text: "Authentification")
  end

  it "visits a missing page" do
    visit api_documentation_url("guides/jenexistepas")
    expect(page).to have_selector("h1", text: "La page que vous recherchez n'est pas disponible.")

    visit api_documentation_url("jenexistepas")
    expect(page).to have_selector("h1", text: "La page que vous recherchez n'est pas disponible.")
  end

  it "visits « A Propos » page" do
    visit api_documentation_url("guides/a_propos")
    expect(page).to have_selector("h1", text: "A propos")
  end

  it "visits « Authentification » page" do
    visit api_documentation_url("guides/authentification")
    expect(page).to have_selector("h1", text: "Authentification")
  end

  it "visits « Sandbox » page" do
    visit api_documentation_url("guides/sandbox")
    expect(page).to have_selector("h1", text: "Mode « Bac à sable »")
  end

  it "visits « Transmettre des signalements » page" do
    visit api_documentation_url("guides/transmettre_des_signalements")
    expect(page).to have_selector("h1", text: "Transmettre des signalements")
  end

  it "visits « Transmettre des pièces jointes » page" do
    visit api_documentation_url("guides/transmettre_des_pieces_jointes")
    expect(page).to have_selector("h1", text: "Transmettre des pièces jointes")
  end

  it "visits « Formulaires de signalement » page" do
    visit api_documentation_url("guides/formulaires")

    expect(page).to have_selector("h1", text: "Formulaires de signalement")

    click_on "Evaluation d'un local d'habitation"

    expect(page).to have_selector("h1", text: "Evaluation d'un local d'habitation")

    go_back
    click_on "Evaluation d'un local professionnel"

    expect(page).to have_selector("h1", text: "Evaluation d'un local professionnel")

    go_back
    click_on "Création d'un local professionnel"

    expect(page).to have_selector("h1", text: "Création d'un local professionnel")

    go_back
    click_on "Création d'un local professionnel"

    expect(page).to have_selector("h1", text: "Création d'un local professionnel")

    go_back
    click_on "Occupation d'un local professionnel"

    expect(page).to have_selector("h1", text: "Occupation d'un local professionnel")

    go_back
    click_on "Occupation d'un local professionnel"

    expect(page).to have_selector("h1", text: "Occupation d'un local professionnel")
  end
end
