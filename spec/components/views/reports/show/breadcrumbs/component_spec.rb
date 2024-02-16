# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Reports::Show::Breadcrumbs::Component, type: :component do
  it "renders a draft report to a collectivity" do
    report = create(:report, form_type: "evaluation_local_habitation")
    sign_in_as(organization: report.collectivity)

    render_inline described_class.new(report)

    expect(page).to have_selector("h1", text: "Évaluation d'un local d'habitation")
    expect(page).to have_no_button("Transmettre")
  end

  it "renders a ready report to a collectivity" do
    report = create(:report, :ready, form_type: "evaluation_local_habitation")
    sign_in_as(organization: report.collectivity)

    render_inline described_class.new(report)

    expect(page).to have_selector("h1", text: "Évaluation du local d'habitation")
    expect(page).to have_button("Transmettre")
  end

  it "renders a transmitted report to a collectivity" do
    report = create(:report, :transmitted, form_type: "evaluation_local_habitation")
    sign_in_as(organization: report.collectivity)

    render_inline described_class.new(report)

    expect(page).to have_selector("h1", text: "Évaluation du local d'habitation")
    expect(page).to have_no_button("Transmettre")
  end

  it "renders a transmitted report to a DDFIP admin" do
    report = create(:report, :transmitted_to_ddfip, form_type: "evaluation_local_habitation")
    sign_in_as(:organization_admin, organization: report.ddfip)

    render_inline described_class.new(report)

    expect(page).to have_selector("h1", text: "Évaluation du local d'habitation")
    expect(page).to have_link("Accepter", class: "button")
    expect(page).to have_link("Rejeter", class: "button")
  end

  it "renders a transmitted report to a DDFIP user" do
    report = build_stubbed(:report, :transmitted_to_ddfip, form_type: "evaluation_local_habitation")
    sign_in_as(organization: report.ddfip)

    render_inline described_class.new(report)

    expect(page).to have_selector("h1", text: "Évaluation du local d'habitation")
    expect(page).to have_no_link("Accepter")
    expect(page).to have_no_link("Rejeter")
  end
end
