# frozen_string_literal: true

require "rails_helper"

RSpec.describe TemplateStatus::Gone::Component, type: :component do
  before do
    # Set the current time to midday to simplify calculation of expected delays
    Timecop.travel(Time.zone.local(2023, 6, 2, 10, 0))
  end

  it "renders a status template for a discarded record" do
    publisher = build_stubbed(:publisher, :discarded)

    render_inline described_class.new(publisher)

    aggregate_failures do
      expect(page).to have_selector(".card > .card__content > .card__header") do |node|
        expect(node).to have_selector("h1.card__title", text: "La page que vous recherchez n'est pas disponible.")
      end

      expect(page).to have_selector(".card > .card__content > .card__body") do |node|
        aggregate_failures do
          expect(node).to have_text("Cet éditeur est en cours de suppression.")
          expect(node).to have_text("Sa suppression sera effective dans 30 jours.")
        end
      end
    end
  end

  it "renders a custom message when record will be deleted next day" do
    user = build_stubbed(:user, :discarded)

    render_inline described_class.new(user)

    expect(page).to have_selector(".card > .card__content > .card__body") do |node|
      aggregate_failures do
        expect(node).to have_text("Cet utilisateur est en cours de suppression.")
        expect(node).to have_text("Sa suppression sera effective dans 1 jour.")
      end
    end
  end

  it "renders a custom message when record will be deleted in less than 24 hours" do
    user = build_stubbed(:user, :discarded, discarded_at: Time.zone.local(2023, 6, 1, 16, 0))
    Timecop.travel(Time.zone.local(2023, 6, 2, 4, 0))

    render_inline described_class.new(user)

    expect(page).to have_selector(".card > .card__content > .card__body") do |node|
      aggregate_failures do
        expect(node).to have_text("Cet utilisateur est en cours de suppression.")
        expect(node).to have_text("Sa suppression sera effective dans moins de 24 heures.")
      end
    end
  end

  it "renders a custom message when record will be deleted by the end of the day" do
    user = build_stubbed(:user, :discarded, discarded_at: Time.zone.local(2023, 6, 1, 16, 0))
    Timecop.travel(Time.zone.local(2023, 6, 2, 16, 0))

    render_inline described_class.new(user)

    expect(page).to have_selector(".card > .card__content > .card__body") do |node|
      aggregate_failures do
        expect(node).to have_text("Cet utilisateur est en cours de suppression.")
        expect(node).to have_text("Sa suppression sera effective ce soir vers minuit.")
      end
    end
  end

  it "renders a custom message with a record which have its parent discarded" do
    publisher = build_stubbed(:publisher, :discarded)
    user      = build_stubbed(:user, organization: publisher)

    render_inline described_class.new(publisher, user)

    expect(page).to have_selector(".card > .card__content > .card__body") do |node|
      aggregate_failures do
        expect(node).to have_text("L'organisation de cet utilisateur est en cours de suppression.")
        expect(node).to have_text("Sa suppression sera effective dans 30 jours.")
      end
    end
  end

  it "renders a status template with an action to undiscard record" do
    user = build_stubbed(:user, :discarded)

    render_inline described_class.new(user) do |template|
      template.with_action("Annuler")
    end

    expect(page).to have_selector(".card > .card__content > .card__actions") do |node|
      expect(node).to have_button("Annuler")
    end
  end

  it "renders a status template in a modal when requested" do
    user = build_stubbed(:user, :discarded)
    vc_test_controller.request.variant = :modal

    render_inline described_class.new(user, referrer: "/background/path") do |template|
      template.with_action("Annuler")
    end

    aggregate_failures do
      expect(page).to     have_selector("main.content > turbo-frame[src='/background/path']")
      expect(page).to     have_selector(".modal")
      expect(page).not_to have_selector(".card")
    end

    aggregate_failures do
      expect(page).to have_selector(".modal > .modal__content > .modal__header", text: "La page que vous recherchez n'est pas disponible.")
      expect(page).to have_selector(".modal > .modal__content > .modal__body") do |node|
        aggregate_failures do
          expect(node).to have_text("Cet utilisateur est en cours de suppression.")
          expect(node).to have_text("Sa suppression sera effective dans 1 jour.")
        end
      end

      expect(page).to have_selector(".modal > .modal__content > .modal__actions") do |node|
        expect(node).to have_button("Annuler")
      end
    end
  end
end
