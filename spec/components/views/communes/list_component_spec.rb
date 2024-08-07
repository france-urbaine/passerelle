# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Communes::ListComponent, type: :component do
  describe "rendered component" do
    let!(:communes) { create_list(:commune, 3, :with_epci) }
    let(:pagy)      { Pagy.new(count: 56, page: 1, limit: 20) }

    before { sign_in_as(:super_admin) }

    it "renders pagination" do
      render_inline described_class.new(Commune.all, pagy, namespace: :admin)

      expect(page).to have_text("56 communes | Page 1 sur 3")
    end

    it "renders a table of communes" do
      render_inline described_class.new(Commune.all, pagy, namespace: :admin)

      expect(page).to have_selector(".datatable table") do |table|
        expect(table).to have_selector("th", text: "Commune")
        expect(table).to have_selector("th", text: "Département")
        expect(table).to have_selector("th", text: "EPCI")
        expect(table).to have_selector("th", text: "Collectivités")

        expect(table).to have_selector(:table_row, { "Commune" => communes.first.code_insee }, text: communes.first.name)
      end
    end

    it "renders a table with a limited set of columns" do
      render_inline described_class.new(Commune.all, pagy, namespace: :admin) do |list|
        list.with_column(:name)
        list.with_column(:departement)
      end

      expect(page).to have_selector(".datatable table") do |table|
        expect(table).to have_selector("th", text: "Commune")
        expect(table).to have_selector("th", text: "Département")
        expect(table).to have_no_selector("th", text: "EPCI")
        expect(table).to have_no_selector("th", text: "Collectivités")

        expect(table).to have_selector(:table_row, { "Commune" => communes.first.code_insee }, text: communes.first.name)
      end
    end
  end

  describe "links & actions" do
    let!(:office)   { create(:office) }
    let!(:communes) { create_list(:commune, 3, :with_epci, offices: [office]) }
    let(:pagy)      { Pagy.new(count: 3) }

    context "with admin namespace" do
      before { sign_in_as(:super_admin) }

      context "with an office parent" do
        it "renders users links & actions" do
          render_inline described_class.new(Commune.all, pagy, namespace: :admin, parent: office)

          expect(page).to have_selector(:table_row, "Commune" => communes.first.code_insee) do |row|
            expect(row).to have_link(communes.first.name,                href: "/territoires/communes/#{communes.first.id}")
            expect(row).to have_link("Modifier cette commune",           href: "/territoires/communes/#{communes.first.id}/edit")
            expect(row).to have_link("Exclure cette commune du guichet", href: "/admin/guichets/#{office.id}/communes/#{communes.first.id}/remove")
          end
        end
      end
    end

    context "with organization namespace" do
      let!(:organization) { create(:ddfip) }

      before { sign_in_as(:organization_admin, organization: organization) }

      context "with an office parent" do
        it "renders users links & actions" do
          render_inline described_class.new(Commune.all, pagy, namespace: :organization, parent: office)

          expect(page).to have_selector(:table_row, "Commune" => communes.first.code_insee) do |row|
            expect(row).to have_no_link(communes.first.name)
            expect(row).to have_no_link("Modifier cette commune")
            expect(row).to have_link("Exclure cette commune du guichet", href: "/organisation/guichets/#{office.id}/communes/#{communes.first.id}/remove")
          end
        end
      end
    end

    context "with territories namespace" do
      before { sign_in_as(:super_admin) }

      context "without parent" do
        it "renders users links & actions" do
          render_inline described_class.new(Commune.all, pagy, namespace: :territories)

          expect(page).to have_selector(:table_row, "Commune" => communes.first.code_insee) do |row|
            expect(row).to have_link(communes.first.name,             href: "/territoires/communes/#{communes.first.id}")
            expect(row).to have_link("Modifier cette commune",        href: "/territoires/communes/#{communes.first.id}/edit")
            expect(row).to have_link(communes.first.departement.name, href: "/territoires/departements/#{communes.first.departement.id}")
            expect(row).to have_link(communes.first.epci.name,        href: "/territoires/epcis/#{communes.first.epci.id}")
          end
        end
      end

      context "with a departement parent" do
        let!(:departement) { create(:departement) }
        let!(:communes)    { create_list(:commune, 3, :with_epci, departement: departement) }

        it "renders users links & actions" do
          render_inline described_class.new(Commune.all, pagy, namespace: :territories, parent: departement)

          expect(page).to have_selector(:table_row, "Commune" => communes.first.code_insee) do |row|
            expect(row).to have_link(communes.first.name,             href: "/territoires/communes/#{communes.first.id}")
            expect(row).to have_link("Modifier cette commune",        href: "/territoires/communes/#{communes.first.id}/edit")
            expect(row).to have_link(communes.first.departement.name, href: "/territoires/departements/#{communes.first.departement.id}")
            expect(row).to have_link(communes.first.epci.name,        href: "/territoires/epcis/#{communes.first.epci.id}")
          end
        end
      end

      context "with an epci parent" do
        let!(:epci)     { create(:epci) }
        let!(:communes) { create_list(:commune, 3, epci: epci) }

        it "renders users links & actions" do
          render_inline described_class.new(Commune.all, pagy, namespace: :territories, parent: epci)

          expect(page).to have_selector(:table_row, "Commune" => communes.first.code_insee) do |row|
            expect(row).to have_link(communes.first.name,             href: "/territoires/communes/#{communes.first.id}")
            expect(row).to have_link("Modifier cette commune",        href: "/territoires/communes/#{communes.first.id}/edit")
            expect(row).to have_link(communes.first.departement.name, href: "/territoires/departements/#{communes.first.departement.id}")
            expect(row).to have_link(communes.first.epci.name,        href: "/territoires/epcis/#{communes.first.epci.id}")
          end
        end
      end
    end
  end
end
