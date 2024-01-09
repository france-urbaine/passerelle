# frozen_string_literal: true

require "rails_helper"

RSpec.describe Layout::StatusPage::NotFoundComponent, type: :component do
  it "renders a status template for a missing record" do
    render_inline described_class.new("User")

    expect(page).to have_selector(".card > .card__content > .card__header") do |node|
      expect(node).to have_selector("h1.card__title", text: "La page que vous recherchez n'est pas disponible.")
    end

    expect(page).to have_selector(".card > .card__content > .card__body") do |node|
      expect(node).to have_text("Cet utilisateur n'a pas été trouvé ou n'existe plus.")
    end
  end

  it "renders a status template with an action to undiscard record" do
    render_inline described_class.new("User") do |template|
      template.with_action("Annuler")
    end

    expect(page).to have_selector(".card > .card__content > .card__actions") do |node|
      expect(node).to have_button("Annuler")
    end
  end

  it "renders a status template in a modal when requested" do
    with_variant :modal do
      render_inline described_class.new("User", referrer: "/background/path") do |template|
        template.with_action("Annuler")
      end
    end

    expect(page).to have_selector("main.content > turbo-frame[src='/background/path']")
    expect(page).to have_selector(".modal")
    expect(page).to have_no_selector(".card")

    expect(page).to have_selector(".modal > .modal__content > .modal__header", text: "La page que vous recherchez n'est pas disponible.")
    expect(page).to have_selector(".modal > .modal__content > .modal__body", text: "Cet utilisateur n'a pas été trouvé ou n'existe plus.")
    expect(page).to have_selector(".modal > .modal__content > .modal__actions") do |node|
      expect(node).to have_button("Annuler")
    end
  end
end
