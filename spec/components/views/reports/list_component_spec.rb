# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Reports::ListComponent, type: :component do
  subject(:component_call) { described_class.new(reports, pagy, parent: parent, searchable: searchable) }

  let(:collectivity) { create(:collectivity) }
  let!(:reports) { Report.all }
  let(:pagy) { nil }
  let(:namespace) { :organization }
  let(:parent) { nil }
  let(:searchable) { true }

  before do
    sign_in_as(organization: collectivity)
    create_list(:report, 2, collectivity: collectivity, package: create(:package))
  end

  def render_component
    render_inline(component_call)
  end

  it "preloads package association" do
    expect {
      described_class.new(reports.strict_loading, pagy).with_column(:package)
    }.not_to raise_error(ActiveRecord::StrictLoadingViolationError)
  end

  it "preloads commune association" do
    expect {
      described_class.new(reports.strict_loading, pagy).with_column(:commune)
    }.not_to raise_error(ActiveRecord::StrictLoadingViolationError)
  end

  it "preloads collectivity association" do
    expect {
      described_class.new(reports.strict_loading, pagy).with_column(:collectivity)
    }.not_to raise_error(ActiveRecord::StrictLoadingViolationError)
  end

  it "preloads workshop association" do
    expect {
      described_class.new(reports.strict_loading, pagy).with_column(:workshop)
    }.not_to raise_error(ActiveRecord::StrictLoadingViolationError)
  end

  context "with pagination" do
    let(:pagy) { Pagy.new(count: 1, page: 1, items: 1) }

    it "renders pagination" do
      render_component

      expect(page).to have_text("Page 1 sur 1")
    end
  end

  it "renders a table of reports" do
    render_component

    expect(page).to have_selector(".datatable table") do |table|
      aggregate_failures do
        expect(table).to have_selector("th", text: "Etat")
        expect(table).to have_selector("th", text: "Reference")
        expect(table).to have_selector("th", text: "Priorité")
        expect(table).to have_selector("th", text: "Type de signalement")
        expect(table).to have_selector("th", text: "Objet")
        expect(table).to have_selector("th", text: "Invariant")
        expect(table).to have_selector("th", text: "Adresse")
        expect(table).to have_selector("th", text: "Commune")
        expect(table).to have_selector(:table_row, {
          "Reference"  => reports.first.reference
        })
      end
    end
  end

  it "renders reports links" do
    render_component

    expect(page).to have_selector(:table_row, "Reference" => reports.first.reference) do |row|
      expect(row).to have_link(reports.first.reference, href: "/signalements/#{reports.first.id}")
    end
  end

  it "renders a table with a limited set of columns" do
    component_call.with_column(:reference)
    component_call.with_column(:invariant)
    render_component

    expect(page).to have_selector(".datatable table") do |table|
      aggregate_failures do
        expect(table).to have_selector("th", text: "Reference")
        expect(table).to have_selector("th", text: "Invariant")
        expect(table).not_to have_selector("th", text: "Etat")
        expect(table).not_to have_selector("th", text: "Priorité")
        expect(table).not_to have_selector("th", text: "Type de signalement")
        expect(table).not_to have_selector("th", text: "Objet")
        expect(table).not_to have_selector("th", text: "Adresse")
        expect(table).not_to have_selector("th", text: "Commune")

        expect(table).to have_selector(:table_row, {
          "Reference"  => reports.first.reference
        })
      end
    end
  end
end
