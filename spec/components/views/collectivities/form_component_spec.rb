# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Collectivities::FormComponent, type: :component do
  let!(:publishers) { build_stubbed_list(:publisher, 3) }

  before do
    allow(Publisher).to receive(:pluck)
      .with(:name, :id)
      .and_return(publishers.map { |o| [o.name, o.id] })
  end

  it "renders a form in a modal to create a new collectivity" do
    render_inline described_class.new(Collectivity.new, namespace: :admin)

    expect(page).to have_selector(".modal form") do |form|
      aggregate_failures do
        expect(form).to have_html_attribute("action").with_value("/admin/collectivites")

        expect(form).to have_select("Éditeur")
        expect(form).to have_field("Territoire de la collectivité")
        expect(form).to have_field("Nom de la collectivité")
        expect(form).to have_field("Numéro SIREN de la collectivité")
        expect(form).to have_field("Prénom du contact")
        expect(form).to have_field("Nom du contact")
        expect(form).to have_field("Adresse mail de contact")
        expect(form).to have_field("Numéro de téléphone")
        expect(form).to have_unchecked_field("Autoriser l'email comme méthode d'authentification en 2 étapes")
      end
    end
  end

  it "renders a form in a modal to create a new collectivity belonging to a given publisher" do
    publisher = build_stubbed(:publisher)
    render_inline described_class.new(Collectivity.new, namespace: :admin, publisher: publisher)

    expect(page).to have_selector(".modal form") do |form|
      aggregate_failures do
        expect(form).to have_html_attribute("action").with_value("/admin/editeurs/#{publisher.id}/collectivites")

        expect(form).not_to have_select("Éditeur")
        expect(form).to have_field("Territoire de la collectivité")
        expect(form).to have_field("Nom de la collectivité")
        expect(form).to have_field("Numéro SIREN de la collectivité")
      end
    end
  end

  it "renders a form in a modal to create a new collectivity belonging to the current organization" do
    render_inline described_class.new(Collectivity.new, namespace: :organization)

    expect(page).to have_selector(".modal form") do |form|
      aggregate_failures do
        expect(form).to have_html_attribute("action").with_value("/organisation/collectivites")

        expect(form).not_to have_select("Éditeur")
        expect(form).to have_field("Territoire de la collectivité")
        expect(form).to have_field("Nom de la collectivité")
        expect(form).to have_field("Numéro SIREN de la collectivité")
        expect(form).to have_field("Prénom du contact")
        expect(form).to have_field("Nom du contact")
        expect(form).to have_field("Adresse mail de contact")
        expect(form).to have_field("Numéro de téléphone")
        expect(form).to have_unchecked_field("Autoriser l'email comme méthode d'authentification en 2 étapes")
      end
    end
  end

  it "renders a form in a modal to update an existing collectivity" do
    publisher = publishers.sample
    collectivity = build_stubbed(:collectivity, :epci, publisher: publisher)

    render_inline described_class.new(collectivity, namespace: :admin)

    expect(page).to have_selector(".modal form") do |form|
      aggregate_failures do
        expect(form).to have_html_attribute("action").with_value("/admin/collectivites/#{collectivity.id}")

        expect(form).to have_select("Éditeur", selected: publisher.name)
        expect(form).to have_field("Territoire de la collectivité",   with: collectivity.territory.name)
        expect(form).to have_field("Nom de la collectivité",          with: collectivity.name)
        expect(form).to have_field("Numéro SIREN de la collectivité", with: collectivity.siren)
      end
    end
  end

  it "renders a form in a modal to update an existing collectivity belonging to the current organization" do
    publisher = publishers.sample
    collectivity = build_stubbed(:collectivity, :epci, publisher: publisher)

    render_inline described_class.new(collectivity, namespace: :organization)

    expect(page).to have_selector(".modal form") do |form|
      aggregate_failures do
        expect(form).to have_html_attribute("action").with_value("/organisation/collectivites/#{collectivity.id}")

        expect(form).not_to have_select("Éditeur")
        expect(form).to have_field("Territoire de la collectivité",   with: collectivity.territory.name)
        expect(form).to have_field("Nom de la collectivité",          with: collectivity.name)
        expect(form).to have_field("Numéro SIREN de la collectivité", with: collectivity.siren)
      end
    end
  end
end
