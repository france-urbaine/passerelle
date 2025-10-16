# frozen_string_literal: true

require "rails_helper"

RSpec.describe Layout::StatusPage::Forbidden::Component do
  it "renders a status template" do
    render_inline described_class.new(nil)

    expect(page).to have_selector(".card > .card__content > .card__header") do |node|
      expect(node).to have_selector("h1.card__title", text: "L'accès à cette page n'est pas autorisé.")
    end

    expect(page).to have_selector(".card > .card__content > .card__body") do |node|
      expect(node).to have_text("Vous n'avez pas les droits suffisants pour accéder à la page demandée.")
    end
  end

  it "renders a status template if forbidden because of policy" do
    render_inline described_class.new(ActionPolicy::Unauthorized.new(ReportPolicy, "index", {}))

    expect(page).to have_selector(".card > .card__content > .card__header") do |node|
      expect(node).to have_selector("h1.card__title", text: "L'accès à cette page n'est pas autorisé.")
    end

    expect(page).to have_selector(".card > .card__content > .card__body") do |node|
      expect(node).to have_text("Vous n'avez pas les droits suffisants pour accéder à la page demandée.")
    end
  end

  it "renders a specific status template if forbidden because of IP" do
    render_inline described_class.new(ControllerVerifyIp::UnauthorizedIp.new("users", "index"))

    expect(page).to have_selector(".card > .card__content > .card__header") do |node|
      expect(node).to have_selector("h1.card__title", text: "Adresse IP non autorisée")
    end

    expect(page).to have_selector(".card > .card__content > .card__body") do |node|
      expect(node).to have_text <<~TEXT
        Pour des raisons de sécurité l'accès à Passerelle est restreint à une liste d'adresses IP pré-approuvées par votre administrateur.


        Votre adresse IP actuelle ne fait pas partie cette liste.


        Contactez votre administrateur pour plus d'informations.
      TEXT
    end
  end
end
