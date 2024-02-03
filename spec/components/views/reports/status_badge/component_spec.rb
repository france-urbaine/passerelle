# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Reports::StatusBadge::Component, type: :component do
  context "when passing a state symbol" do
    it "renders a badge for a draft state" do
      render_inline described_class.new(:draft)
      expect(page).to have_selector(".badge.badge--yellow", text: "Formulaire incomplet")
    end

    it "renders a badge for a ready state" do
      render_inline described_class.new(:ready)
      expect(page).to have_selector(".badge.badge--lime", text: "Formulaire complété")
    end

    it "renders a badge for a sent state" do
      render_inline described_class.new(:sent)
      expect(page).to have_selector(".badge.badge--blue", text: "Signalement transmis")
    end

    it "renders a badge for an acknowledged state" do
      render_inline described_class.new(:acknowledged)
      expect(page).to have_selector(".badge.badge--blue", text: "Signalement transmis")
    end

    it "renders a badge for a processing state" do
      render_inline described_class.new(:processing)
      expect(page).to have_selector(".badge.badge--blue", text: "Signalement en cours de traitement")
    end

    it "renders a badge for a denied state" do
      render_inline described_class.new(:denied)
      expect(page).to have_selector(".badge.badge--red", text: "Signalement retourné")
    end

    it "renders a badge for an approved state" do
      render_inline described_class.new(:approved)
      expect(page).to have_selector(".badge.badge--green", text: "Signalement approuvé")
    end

    it "renders a badge for a rejected state" do
      render_inline described_class.new(:rejected)
      expect(page).to have_selector(".badge.badge--red", text: "Signalement rejeté")
    end
  end

  context "when passing a meta-state symbol" do
    it "renders a badge for an in_active_transmission state" do
      render_inline described_class.new(:in_active_transmission)
      expect(page).to have_selector(".badge.badge--violet", text: "Transmission en attente")
    end

    it "renders a badge for a transmitted state" do
      render_inline described_class.new(:transmitted)
      expect(page).to have_selector(".badge.badge--blue", text: "Signalement transmis")
    end

    it "renders a badge for an unassigned state" do
      render_inline described_class.new(:unassigned)
      expect(page).to have_selector(".badge.badge--yellow", text: "Signalement non assigné")
    end
  end

  context "when passing a report as a collectivity" do
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

    it "renders a badge for an assigned report" do
      report = build_stubbed(:report, :assigned)
      render_inline described_class.new(report)

      expect(page).to have_selector(".badge.badge--blue", text: "Signalement transmis")
    end

    it "renders a badge for a denied report" do
      report = build_stubbed(:report, :denied)
      render_inline described_class.new(report)

      expect(page).to have_selector(".badge.badge--red", text: "Signalement retourné")
    end

    it "renders a badge for an approved report not yet confirmed by the DDFIP" do
      report = build_stubbed(:report, :approved)
      render_inline described_class.new(report)

      expect(page).to have_selector(".badge.badge--blue", text: "Signalement transmis")
    end

    it "renders a badge for a rejected report not yet confirmed by the DDFIP" do
      report = build_stubbed(:report, :rejected)
      render_inline described_class.new(report)

      expect(page).to have_selector(".badge.badge--blue", text: "Signalement transmis")
    end
  end

  context "when passing a report as a DDFIP" do
    before { sign_in_as(:ddfip) }

    it "renders a badge for a transmitted report" do
      report = build_stubbed(:report, :transmitted)
      render_inline described_class.new(report)

      expect(page).to have_selector(".badge.badge--yellow", text: "Signalement non assigné")
    end

    it "renders a badge for an acknowledged report" do
      report = build_stubbed(:report, :acknowledged)
      render_inline described_class.new(report)

      expect(page).to have_selector(".badge.badge--yellow", text: "Signalement non assigné")
    end

    it "renders a badge for an assigned report" do
      report = build_stubbed(:report, :assigned)
      render_inline described_class.new(report)

      expect(page).to have_selector(".badge.badge--blue", text: "Signalement en cours de traitement")
    end

    it "renders a badge for a denied report" do
      report = build_stubbed(:report, :denied)
      render_inline described_class.new(report)

      expect(page).to have_selector(".badge.badge--red", text: "Signalement retourné")
    end

    it "renders a badge for an approved report" do
      report = build_stubbed(:report, :approved)
      render_inline described_class.new(report)

      expect(page).to have_selector(".badge.badge--green", text: "Signalement approuvé")
    end

    it "renders a badge for a rejected report" do
      report = build_stubbed(:report, :rejected)
      render_inline described_class.new(report)

      expect(page).to have_selector(".badge.badge--red", text: "Signalement rejeté")
    end
  end
end
