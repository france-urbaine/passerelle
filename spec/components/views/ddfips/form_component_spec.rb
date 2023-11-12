# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::DDFIPs::FormComponent, type: :component do
  it "renders a form in a modal to create a new DDFIP" do
    render_inline described_class.new(DDFIP.new, namespace: :admin)

    expect(page).to have_selector(".modal form") do |form|
      expect(form).to have_html_attribute("action").with_value("/admin/ddfips")

      expect(form).to have_field("Nom de la DDFIP")
      expect(form).to have_field("Département")
      expect(form).to have_field("Prénom du contact")
      expect(form).to have_field("Nom du contact")
      expect(form).to have_field("Adresse mail de contact")
      expect(form).to have_field("Numéro de téléphone")
      expect(form).to have_unchecked_field("Autoriser l'email comme méthode d'authentification en 2 étapes")
    end
  end

  it "renders a form in a modal to update an existing DDFIP" do
    ddfip = build_stubbed(:ddfip)
    render_inline described_class.new(ddfip, namespace: :admin)

    expect(page).to have_selector(".modal form") do |form|
      expect(form).to have_html_attribute("action").with_value("/admin/ddfips/#{ddfip.id}")

      expect(form).to have_field("Nom de la DDFIP", with: ddfip.name)
      expect(form).to have_field("Département",     with: ddfip.departement.qualified_name)
    end
  end
end
