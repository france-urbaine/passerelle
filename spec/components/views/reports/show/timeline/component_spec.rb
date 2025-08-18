# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Reports::Show::Timeline::Component, type: :component do
  context "when current organization is a collectivity" do
    before { sign_in_as(organization: report.collectivity) }

    context "when report is draft" do
      let(:report) { create(:report) }

      it do
        render_inline described_class.new(report)
        expect(page).to have_selector(".timeline-step--current .timeline-step__title", text: "Complétion du formulaire")
        expect(page).to have_selector(".timeline-step__description", text: "En attente de la complétion du formulaire")

        expect(page).to have_selector(".timeline-step--pending .timeline-step__title", text: "Transmission du signalement")
        expect(page).to have_selector(".timeline-step__description", text: "Le signalement pourra être transmis à la DDFIP une fois le formulaire complété")

        expect(page).to have_selector(".timeline-step--pending .timeline-step__title", text: "Acceptation du signalement")
        expect(page).to have_selector(".timeline-step__description", text: "La DDFIP pourra accepter ou refuser de traiter le signalement lorsqu'il sera transmis")

        expect(page).to have_selector(".timeline-step--pending .timeline-step__title", text: "Réponse de la DDFIP")
        expect(page).to have_selector(".timeline-step__description", text: "La DDFIP n'a pas encore répondu à propos de ce signalement")
      end
    end

    context "when report is ready" do
      let(:report) { create(:report, :ready) }

      it do
        render_inline described_class.new(report)
        expect(page).to have_selector(".timeline-step--done .timeline-step__title", text: "Formulaire complété")
        expect(page).to have_selector(".timeline-step__description", text: "Le formulaire de signalement a été complété")

        expect(page).to have_selector(".timeline-step--current .timeline-step__title", text: "Transmission du signalement")
        expect(page).to have_selector(".timeline-step__description", text: "Le signalement est prêt à être transmis à la DDFIP")

        expect(page).to have_selector(".timeline-step--pending .timeline-step__title", text: "Acceptation du signalement")
        expect(page).to have_selector(".timeline-step__description", text: "La DDFIP pourra accepter ou refuser de traiter le signalement lorsqu'il sera transmis")

        expect(page).to have_selector(".timeline-step--pending .timeline-step__title", text: "Réponse de la DDFIP")
        expect(page).to have_selector(".timeline-step__description", text: "La DDFIP n'a pas encore répondu à propos de ce signalement")
      end
    end

    context "when report is in active transmission" do
      let(:report) { create(:report, :in_active_transmission) }

      it do
        render_inline described_class.new(report)
        expect(page).to have_selector(".timeline-step--done .timeline-step__title", text: "Formulaire complété")
        expect(page).to have_selector(".timeline-step__description", text: "Le formulaire de signalement a été complété")

        expect(page).to have_selector(".timeline-step--current .timeline-step__title", text: "Transmission du signalement")
        expect(page).to have_selector(".timeline-step__description", text: "La transmission du signalement est en attente")

        expect(page).to have_selector(".timeline-step--pending .timeline-step__title", text: "Acceptation du signalement")
        expect(page).to have_selector(".timeline-step__description", text: "La DDFIP pourra accepter ou refuser de traiter le signalement lorsqu'il sera transmis")

        expect(page).to have_selector(".timeline-step--pending .timeline-step__title", text: "Réponse de la DDFIP")
        expect(page).to have_selector(".timeline-step__description", text: "La DDFIP n'a pas encore répondu à propos de ce signalement")
      end
    end

    context "when report is transmitted or acknowledged" do
      let(:report) { create(:report, %i[transmitted acknowledged].sample) }

      it do
        render_inline described_class.new(report)
        expect(page).to have_selector(".timeline-step--done .timeline-step__title", text: "Formulaire complété")
        expect(page).to have_selector(".timeline-step__description", text: "Le formulaire de signalement a été complété")

        expect(page).to have_selector(".timeline-step--done .timeline-step__title", text: "Signalement transmis")
        expect(page).to have_selector(".timeline-step__description", text: "Le signalement a été transmis à la DDFIP")

        expect(page).to have_selector(".timeline-step--current .timeline-step__title", text: "Acceptation du signalement")
        expect(page).to have_selector(".timeline-step__description", text: "La DDFIP a reçu le signalement et va le traiter prochainement")

        expect(page).to have_selector(".timeline-step--pending .timeline-step__title", text: "Réponse de la DDFIP")
        expect(page).to have_selector(".timeline-step__description", text: "La DDFIP n'a pas encore répondu à propos de ce signalement")
      end
    end

    context "when report is accepted, assigned, applicable or inapplicable" do
      let(:report) { create(:report, %i[accepted assigned applicable inapplicable].sample) }

      it do
        render_inline described_class.new(report)
        expect(page).to have_selector(".timeline-step--done .timeline-step__title", text: "Formulaire complété")
        expect(page).to have_selector(".timeline-step__description", text: "Le formulaire de signalement a été complété")

        expect(page).to have_selector(".timeline-step--done .timeline-step__title", text: "Signalement transmis")
        expect(page).to have_selector(".timeline-step__description", text: "Le signalement a été transmis à la DDFIP")

        expect(page).to have_selector(".timeline-step--done .timeline-step__title", text: "Signalement accepté")
        expect(page).to have_selector(".timeline-step__description", text: "La DDFIP a reçu le signalement et accepté son traitement")

        expect(page).to have_selector(".timeline-step--current .timeline-step__title", text: "Réponse de la DDFIP")
        expect(page).to have_selector(".timeline-step__description", text: "La DDFIP n'a pas encore répondu à propos de ce signalement")
      end
    end

    context "when report is rejected" do
      let(:report) { create(:report, :rejected) }

      it do
        render_inline described_class.new(report)
        expect(page).to have_selector(".timeline-step--done .timeline-step__title", text: "Formulaire complété")
        expect(page).to have_selector(".timeline-step__description", text: "Le formulaire de signalement a été complété")

        expect(page).to have_selector(".timeline-step--done .timeline-step__title", text: "Signalement transmis")
        expect(page).to have_selector(".timeline-step__description", text: "Le signalement a été transmis à la DDFIP")

        expect(page).to have_selector(".timeline-step--failed .timeline-step__title", text: "Signalement rejeté")
        expect(page).to have_selector(".timeline-step__description", text: "La DDFIP a rejeté le traitement du signalement")

        expect(page).to have_selector(".timeline-step--failed .timeline-step__title", text: "Réponse de la DDFIP")
        expect(page).to have_selector(".timeline-step__description", text: "La DDFIP a rejeté le traitement du signalement")
      end
    end

    context "when report is approved" do
      let(:report) { create(:report, :approved) }

      it do
        render_inline described_class.new(report)
        expect(page).to have_selector(".timeline-step--done .timeline-step__title", text: "Formulaire complété")
        expect(page).to have_selector(".timeline-step__description", text: "Le formulaire de signalement a été complété")

        expect(page).to have_selector(".timeline-step--done .timeline-step__title", text: "Signalement transmis")
        expect(page).to have_selector(".timeline-step__description", text: "Le signalement a été transmis à la DDFIP")

        expect(page).to have_selector(".timeline-step--done .timeline-step__title", text: "Signalement accepté")
        expect(page).to have_selector(".timeline-step__description", text: "La DDFIP a reçu le signalement et accepté son traitement")

        expect(page).to have_selector(".timeline-step--done .timeline-step__title", text: "Réponse de la DDFIP")
        expect(page).to have_selector(".timeline-step__description", text: "La DDFIP a donné une réponse positive à ce signalement")
      end
    end

    context "when report is canceled" do
      let(:report) { create(:report, :canceled) }

      it do
        render_inline described_class.new(report)
        expect(page).to have_selector(".timeline-step--done .timeline-step__title", text: "Formulaire complété")
        expect(page).to have_selector(".timeline-step__description", text: "Le formulaire de signalement a été complété")

        expect(page).to have_selector(".timeline-step--done .timeline-step__title", text: "Signalement transmis")
        expect(page).to have_selector(".timeline-step__description", text: "Le signalement a été transmis à la DDFIP")

        expect(page).to have_selector(".timeline-step--done .timeline-step__title", text: "Signalement accepté")
        expect(page).to have_selector(".timeline-step__description", text: "La DDFIP a reçu le signalement et accepté son traitement")

        expect(page).to have_selector(".timeline-step--failed .timeline-step__title", text: "Réponse de la DDFIP")
        expect(page).to have_selector(".timeline-step__description", text: "La DDFIP a donné une réponse négative à ce signalement")
      end
    end
  end
end
