# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Reports::ListComponent, type: :component do
  describe "rendered component" do
    let!(:collectivity) { create(:collectivity) }
    let!(:reports)      { create_list(:report, 2, :completed, collectivity:) }
    let(:pagy)          { Pagy.new(count: 56, page: 1, items: 20) }

    def form_type_title(report)
      I18n.t(report.form_type, scope: "enum.report_form_type")
    end

    def concat_address(report)
      [
        report.situation_numero_voie,
        report.situation_indice_repetition,
        report.situation_libelle_voie
      ].compact.join(" ")
    end

    before { sign_in_as(organization: collectivity) }

    it "renders pagination" do
      render_inline described_class.new(Report.all, pagy)

      expect(page).to have_text("56 signalements | Page 1 sur 3")
    end

    it "renders a table of reports" do
      render_inline described_class.new(Report.all, pagy)

      expect(page).to have_selector(".datatable table") do |table|
        expect(table).to have_selector("th", text: "Etat")
        expect(table).to have_selector("th", text: "Reference")
        expect(table).to have_selector("th", text: "Priorité")
        expect(table).to have_selector("th", text: "Type de signalement")
        expect(table).to have_selector("th", text: "Objet")
        expect(table).to have_selector("th", text: "Invariant")
        expect(table).to have_selector("th", text: "Adresse")
        expect(table).to have_selector("th", text: "Commune")
        expect(table).to have_selector(:table_row, {
          "Type de signalement" => form_type_title(reports.first),
          "Adresse"             => concat_address(reports.first)
        })
      end
    end

    it "renders a table with a limited set of columns" do
      render_inline described_class.new(Report.all, pagy) do |list|
        list.with_column(:reference)
        list.with_column(:form_type)
        list.with_column(:anomalies)
      end

      expect(page).to have_selector(".datatable table") do |table|
        expect(table).to have_selector("th", text: "Reference")
        expect(table).to have_selector("th", text: "Type de signalement")
        expect(table).to have_selector("th", text: "Objet")

        expect(table).not_to have_selector("th", text: "Etat")
        expect(table).not_to have_selector("th", text: "Priorité")
        expect(table).not_to have_selector("th", text: "Invariant")
        expect(table).not_to have_selector("th", text: "Adresse")
      end
    end

    it "renders search form by default" do
      render_inline described_class.new(Report.all, pagy)

      expect(page).to have_selector("form.search")
    end

    it "allows to not render search form" do
      render_inline described_class.new(Report.all, pagy, dashboard: true)

      expect(page).not_to have_selector("form.search")
    end

    it "renders sort links by default" do
      render_inline described_class.new(Report.all, pagy)

      expect(page).to have_selector(".datatable table") do |table|
        expect(table).to have_selector("th", text: "Reference") do |row|
          expect(row).to have_link("Trier par ordre croissant")
        end
      end
    end

    it "allows to not render sort links" do
      render_inline described_class.new(Report.all, pagy, dashboard: true)

      expect(page).to have_selector(".datatable table") do |table|
        expect(table).to have_selector("th", text: "Reference") do |row|
          expect(row).not_to have_link("Trier par ordre croissant")
        end
      end
    end

    it "renders reports links" do
      render_inline described_class.new(Report.all, pagy)

      expect(page).to have_selector(
        :table_row,
        "Type de signalement" => form_type_title(reports.first),
        "Adresse"             => concat_address(reports.first)
      ) do |row|
        expect(row).to have_link(
          form_type_title(reports.first),
          href: "/signalements/#{reports.first.id}"
        )
      end
    end
  end

  describe "eager loading resources" do
    let(:pagy) { Pagy.new(count: 2) }

    before do
      collectivity = create(:collectivity)

      create_list(:report, 2, collectivity: collectivity)
      sign_in_as(organization: collectivity)
    end

    it "doesn't raise an error about N+1 queries with all default columns" do
      expect {
        render_inline described_class.new(Report.strict_loading, pagy)
      }.not_to raise_error
    end

    it "doesn't raise an error about N+1 queries with only package column" do
      expect {
        render_inline described_class.new(Report.strict_loading, pagy) do |list|
          list.with_column(:package)
        end
      }.not_to raise_error
    end

    it "doesn't raise an error about N+1 queries with only commune column" do
      expect {
        render_inline described_class.new(Report.strict_loading, pagy) do |list|
          list.with_column(:commune)
        end
      }.not_to raise_error
    end

    it "doesn't raise an error about N+1 queries with only collectivity column" do
      expect {
        render_inline described_class.new(Report.strict_loading, pagy) do |list|
          list.with_column(:collectivity)
        end
      }.not_to raise_error
    end

    it "doesn't raise an error about N+1 queries with only workshop column" do
      expect {
        render_inline described_class.new(Report.strict_loading, pagy) do |list|
          list.with_column(:workshop)
        end
      }.not_to raise_error
    end
  end
end
