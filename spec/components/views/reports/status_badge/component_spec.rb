# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Reports::StatusBadge::Component, type: :component do
  context "when showing a report to a collectivity" do
    before { sign_in_as(:collectivity) }

    it "renders a badge for a draft report" do
      report = build_stubbed(:report)
      render_inline described_class.new(report)

      expect(page).to have_selector(".badge.badge--yellow", text: "Formulaire incomplet")
    end

    it "renders a badge for a ready report" do
      report = build_stubbed(:report, :ready)
      render_inline described_class.new(report)

      expect(page).to have_selector(".badge.badge--lime", text: "Formulaire complété")
    end

    it "renders a badge for a report in active transmission" do
      report = build_stubbed(:report, :in_active_transmission)
      render_inline described_class.new(report)

      expect(page).to have_selector(".badge.badge--violet", text: "Transmission en attente")
    end

    it "renders a badge for a transmitted report" do
      report = build_stubbed(:report, :transmitted)
      render_inline described_class.new(report)

      expect(page).to have_selector(".badge.badge--blue", text: "Signalement transmis")
    end

    it "renders a badge for an acknowledged report" do
      report = build_stubbed(:report, :acknowledged)
      render_inline described_class.new(report)

      expect(page).to have_selector(".badge.badge--blue", text: "Signalement transmis")
    end

    it "renders a badge for an accepted report" do
      report = build_stubbed(:report, :accepted)
      render_inline described_class.new(report)

      expect(page).to have_selector(".badge.badge--sky", text: "Signalement accepté")
    end

    it "renders a badge for an assigned report" do
      report = build_stubbed(:report, :assigned)
      render_inline described_class.new(report)

      expect(page).to have_selector(".badge.badge--sky", text: "Signalement accepté")
    end

    it "renders a badge for an applicable report" do
      report = build_stubbed(:report, :applicable)
      render_inline described_class.new(report)

      expect(page).to have_selector(".badge.badge--sky", text: "Signalement accepté")
    end

    it "renders a badge for an inapplicable report" do
      report = build_stubbed(:report, :inapplicable)
      render_inline described_class.new(report)

      expect(page).to have_selector(".badge.badge--sky", text: "Signalement accepté")
    end

    it "renders a badge for an approved report" do
      report = build_stubbed(:report, :approved)
      render_inline described_class.new(report)

      expect(page).to have_selector(".badge.badge--green", text: "Réponse positive")
    end

    it "renders a badge for a canceled report" do
      report = build_stubbed(:report, :canceled)
      render_inline described_class.new(report)

      expect(page).to have_selector(".badge.badge--red", text: "Réponse négative")
    end

    it "renders a badge for a rejected report" do
      report = build_stubbed(:report, :rejected)
      render_inline described_class.new(report)

      expect(page).to have_selector(".badge.badge--red", text: "Signalement rejeté")
    end
  end

  context "when showing a report to a publisher" do
    before { sign_in_as(:publisher) }

    it "renders a badge for a draft report" do
      report = build_stubbed(:report)
      render_inline described_class.new(report)

      expect(page).to have_selector(".badge.badge--yellow", text: "Formulaire incomplet")
    end

    it "renders a badge for a ready report" do
      report = build_stubbed(:report, :ready)
      render_inline described_class.new(report)

      expect(page).to have_selector(".badge.badge--lime", text: "Formulaire complété")
    end

    it "renders a badge for a report in active transmission" do
      report = build_stubbed(:report, :in_active_transmission)
      render_inline described_class.new(report)

      expect(page).to have_selector(".badge.badge--violet", text: "Transmission en attente")
    end

    it "renders a badge for a transmitted report" do
      report = build_stubbed(:report, :transmitted)
      render_inline described_class.new(report)

      expect(page).to have_selector(".badge.badge--blue", text: "Signalement transmis")
    end

    it "renders a badge for an acknowledged report" do
      report = build_stubbed(:report, :acknowledged)
      render_inline described_class.new(report)

      expect(page).to have_selector(".badge.badge--blue", text: "Signalement transmis")
    end

    it "renders a badge for an accepted report" do
      report = build_stubbed(:report, :accepted)
      render_inline described_class.new(report)

      expect(page).to have_selector(".badge.badge--sky", text: "Signalement accepté")
    end

    it "renders a badge for an assigned report" do
      report = build_stubbed(:report, :assigned)
      render_inline described_class.new(report)

      expect(page).to have_selector(".badge.badge--sky", text: "Signalement accepté")
    end

    it "renders a badge for an applicable report" do
      report = build_stubbed(:report, :applicable)
      render_inline described_class.new(report)

      expect(page).to have_selector(".badge.badge--sky", text: "Signalement accepté")
    end

    it "renders a badge for an inapplicable report" do
      report = build_stubbed(:report, :inapplicable)
      render_inline described_class.new(report)

      expect(page).to have_selector(".badge.badge--sky", text: "Signalement accepté")
    end

    it "renders a badge for an approved report" do
      report = build_stubbed(:report, :approved)
      render_inline described_class.new(report)

      expect(page).to have_selector(".badge.badge--green", text: "Réponse positive")
    end

    it "renders a badge for a canceled report" do
      report = build_stubbed(:report, :canceled)
      render_inline described_class.new(report)

      expect(page).to have_selector(".badge.badge--red", text: "Réponse négative")
    end

    it "renders a badge for a rejected report" do
      report = build_stubbed(:report, :rejected)
      render_inline described_class.new(report)

      expect(page).to have_selector(".badge.badge--red", text: "Signalement rejeté")
    end
  end

  context "when showing a report to a DDFIP admin" do
    before { sign_in_as(:ddfip, :organization_admin) }

    it "renders a badge for a transmitted report" do
      report = build_stubbed(:report, :transmitted)
      render_inline described_class.new(report)

      expect(page).to have_selector(".badge.badge--yellow", text: "Nouveau signalement")
    end

    it "renders a badge for an acknowledged report" do
      report = build_stubbed(:report, :acknowledged)
      render_inline described_class.new(report)

      expect(page).to have_selector(".badge.badge--yellow", text: "Nouveau signalement")
    end

    it "renders a badge for an accepted report" do
      report = build_stubbed(:report, :accepted)
      render_inline described_class.new(report)

      expect(page).to have_selector(".badge.badge--yellow", text: "Signalement accepté")
    end

    it "renders a badge for an assigned report" do
      report = build_stubbed(:report, :assigned)
      render_inline described_class.new(report)

      expect(page).to have_selector(".badge.badge--blue", text: "Signalement assigné")
    end

    it "renders a badge for an applicable report" do
      report = build_stubbed(:report, :applicable)
      render_inline described_class.new(report)

      expect(page).to have_selector(".badge.badge--lime", text: "Traitement validé par le guichet")
    end

    it "renders a badge for an inapplicable report" do
      report = build_stubbed(:report, :inapplicable)
      render_inline described_class.new(report)

      expect(page).to have_selector(".badge.badge--orange", text: "Traitement annulé par le guichet")
    end

    it "renders a badge for an approved report" do
      report = build_stubbed(:report, :approved)
      render_inline described_class.new(report)

      expect(page).to have_selector(".badge.badge--green", text: "Réponse positive")
    end

    it "renders a badge for a canceled report" do
      report = build_stubbed(:report, :canceled)
      render_inline described_class.new(report)

      expect(page).to have_selector(".badge.badge--red", text: "Réponse négative")
    end

    it "renders a badge for a rejected report" do
      report = build_stubbed(:report, :rejected)
      render_inline described_class.new(report)

      expect(page).to have_selector(".badge.badge--red", text: "Signalement rejeté")
    end
  end

  context "when showing a report to a DDFIP user" do
    before { sign_in_as(:ddfip) }

    it "renders a badge for an assigned report" do
      report = build_stubbed(:report, :assigned)
      render_inline described_class.new(report)

      expect(page).to have_selector(".badge.badge--yellow", text: "Signalement à traiter")
    end

    it "renders a badge for an applicable report" do
      report = build_stubbed(:report, :applicable)
      render_inline described_class.new(report)

      expect(page).to have_selector(".badge.badge--lime", text: "Traitement validé")
    end

    it "renders a badge for an inapplicable report" do
      report = build_stubbed(:report, :inapplicable)
      render_inline described_class.new(report)

      expect(page).to have_selector(".badge.badge--orange", text: "Traitement annulé")
    end

    it "renders a badge for an approved report" do
      report = build_stubbed(:report, :approved)
      render_inline described_class.new(report)

      expect(page).to have_selector(".badge.badge--green", text: "Réponse positive")
    end

    it "renders a badge for a canceled report" do
      report = build_stubbed(:report, :canceled)
      render_inline described_class.new(report)

      expect(page).to have_selector(".badge.badge--red", text: "Réponse négative")
    end
  end
end
