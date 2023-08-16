# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Publishers::FormComponent, type: :component do
  it "renders a form in a modal to create a new publisher" do
    render_inline described_class.new(Publisher.new, namespace: :admin)

    expect(page).to have_selector(".modal form") do |form|
      aggregate_failures do
        expect(form).to have_html_attribute("action").with_value("/admin/editeurs")

        expect(form).to have_field("Nom de l'éditeur")
        expect(form).to have_field("Numéro SIREN de l'éditeur")
        expect(form).to have_field("Prénom du contact")
        expect(form).to have_field("Nom du contact")
        expect(form).to have_field("Adresse mail de contact")
        expect(form).to have_field("Numéro de téléphone")
        expect(form).to have_unchecked_field("Autoriser l'email comme méthode d'authentification en 2 étapes")
      end
    end
  end

  it "renders a form in a modal to update an existing publisher" do
    publisher = build_stubbed(:publisher)
    render_inline described_class.new(publisher, namespace: :admin)

    expect(page).to have_selector(".modal form") do |form|
      aggregate_failures do
        expect(form).to have_html_attribute("action").with_value("/admin/editeurs/#{publisher.id}")

        expect(form).to have_field("Nom de l'éditeur",          with: publisher.name)
        expect(form).to have_field("Numéro SIREN de l'éditeur", with: publisher.siren)
      end
    end
  end
end
