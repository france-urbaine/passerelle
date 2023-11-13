# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Territories::UpdateComponent, type: :component do
  it "renders a form in a modal" do
    render_inline described_class.new

    expect(page).to have_selector(".modal form") do |form|
      expect(form).to have_html_attribute("action").with_value("/territoires/mise-a-jour")

      expect(form).to have_field("Fichier de découpage communal", with: "fr/statistiques/fichier/2028028/table-appartenance-geo-communes-23.zip")
      expect(form).to have_field("Fichier des intercommunalités", with: "fr/statistiques/fichier/2510634/Intercommunalite_Metropole_au_01-01-2023.zip")
    end
  end

  it "renders a form in a modal with custom values" do
    render_inline described_class.new({
      communes_url: "path/to/communes.zip",
      epcis_url:    "path/to/epcis.zip"
    })

    expect(page).to have_selector(".modal form") do |form|
      expect(form).to have_html_attribute("action").with_value("/territoires/mise-a-jour")

      expect(form).to have_field("Fichier de découpage communal", with: "path/to/communes.zip")
      expect(form).to have_field("Fichier des intercommunalités", with: "path/to/epcis.zip")
    end
  end

  it "renders a form in a modal with values from params" do
    params = ActionController::Parameters.new({
      communes_url: "path/to/communes.zip",
      epcis_url:    "path/to/epcis.zip"
    })

    render_inline described_class.new(params)

    expect(page).to have_selector(".modal form") do |form|
      expect(form).to have_html_attribute("action").with_value("/territoires/mise-a-jour")

      expect(form).to have_field("Fichier de découpage communal", with: "path/to/communes.zip")
      expect(form).to have_field("Fichier des intercommunalités", with: "path/to/epcis.zip")
    end
  end

  it "renders a form in a modal with values from params and validation result from a service" do
    params = ActionController::Parameters.new({
      communes_url: "",
      epcis_url:    "path/to/epcis"
    })
    service = Territories::UpdateService.new(params.permit!)
    result  = service.validate

    render_inline described_class.new(params, result)

    expect(page).to have_selector(".modal form") do |form|
      expect(form).to have_html_attribute("action").with_value("/territoires/mise-a-jour")

      expect(form).to have_selector(".form-block", text: "Fichier de découpage communal") do |block|
        expect(block).to have_field(with: "")
        expect(block).to have_selector(".form-block__errors", text: "Une URL est requise")
      end

      expect(form).to have_selector(".form-block", text: "Fichier des intercommunalités") do |block|
        expect(block).to have_field(with: "path/to/epcis")
        expect(block).to have_selector(".form-block__errors", text: "Le fichier cible doit être un fichier ZIP")
      end
    end
  end
end
