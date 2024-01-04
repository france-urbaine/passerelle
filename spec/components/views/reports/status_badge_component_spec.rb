# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Reports::StatusBadgeComponent, type: :component do
  it "renders a badge for an draft report" do
    report = build_stubbed(:report)
    render_inline described_class.new(report)

    expect(page).to have_selector(".badge.badge--yellow", text: "Formulaire incomplet")
  end

  it "renders a badge for an ready report" do
    report = build_stubbed(:report, :ready)
    render_inline described_class.new(report)

    expect(page).to have_selector(".badge.badge--lime", text: "Formulaire complété")
  end

  it "renders a badge for a report in an active transmission" do
    report = build_stubbed(:report, :in_active_transmission)
    render_inline described_class.new(report)

    expect(page).to have_selector(".badge.badge--violet", text: "Transmission en attente")
  end

  it "renders a badge for transmitted report" do
    report = build_stubbed(:report, :transmitted)
    render_inline described_class.new(report)

    expect(page).to have_selector(".badge.badge--blue", text: "Signalement transmis, en attente de confirmation")
  end

  it "renders a badge for a processing report" do
    report = build_stubbed(:report, :assigned)
    render_inline described_class.new(report)

    expect(page).to have_selector(".badge.badge--sky", text: "Signalement non traité")
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
