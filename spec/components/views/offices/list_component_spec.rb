# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Offices::ListComponent, type: :component do
  describe "rendered component" do
    let!(:offices) { create_list(:office, 3) }
    let(:pagy)     { Pagy.new(count: 56, page: 1, items: 20) }

    before { sign_in_as(:super_admin) }

    it "renders pagination" do
      render_inline described_class.new(Office.all, pagy, namespace: :admin)

      expect(page).to have_text("56 guichets | Page 1 sur 3")
    end

    it "renders a table of guichets" do
      render_inline described_class.new(Office.all, pagy, namespace: :admin)

      expect(page).to have_selector(".datatable table") do |table|
        expect(table).to have_selector("th", text: "Guichet")
        expect(table).to have_selector("th", text: "DDFIP")
        expect(table).to have_selector("th", text: "Compétence")
        expect(table).to have_selector("th", text: "Utilisateurs")
        expect(table).to have_selector("th", text: "Communes")
        expect(table).to have_selector("th", text: "Signalements")
        expect(table).to have_selector("th", text: "Approuvés")
        expect(table).to have_selector("th", text: "Rejetés")

        expect(table).to have_selector(:table_row, {
          "Guichet"  => offices.first.name,
          "DDFIP" => offices.first.ddfip.name
        })
      end
    end

    it "renders a table with a limited set of columns" do
      render_inline described_class.new(Office.all, pagy, namespace: :admin) do |list|
        list.with_column(:name)
        list.with_column(:ddfip)
      end

      expect(page).to have_selector(".datatable table") do |table|
        expect(table).to have_selector("th", text: "Guichet")
        expect(table).to have_selector("th", text: "DDFIP")
        expect(table).not_to have_selector("th", text: "Compétence")
        expect(table).not_to have_selector("th", text: "Utilisateurs")
        expect(table).not_to have_selector("th", text: "Communes")
        expect(table).not_to have_selector("th", text: "Signalements")
        expect(table).not_to have_selector("th", text: "Approuvés")
        expect(table).not_to have_selector("th", text: "Rejetés")

        expect(table).to have_selector(:table_row, {
          "Guichet"  => offices.first.name,
          "DDFIP" => offices.first.ddfip.name
        })
      end
    end
  end

  describe "links & actions" do
    let!(:offices) { create_list(:office, 3) }
    let(:pagy)     { Pagy.new(count: 3) }

    context "with admin namespace" do
      before { sign_in_as(:super_admin) }

      context "without parent" do
        it "renders users links & actions" do
          render_inline described_class.new(Office.all, pagy, namespace: :admin)

          expect(page).to have_selector(:table_row, "Guichet" => offices.first.name) do |row|
            expect(row).to have_link(offices.first.name,     href: "/admin/guichets/#{offices.first.id}")
            expect(row).to have_link("Modifier ce guichet",  href: "/admin/guichets/#{offices.first.id}/edit")
            expect(row).to have_link("Supprimer ce guichet", href: "/admin/guichets/#{offices.first.id}/remove")
          end
        end
      end

      context "with a collectivity parent" do
        let!(:office) { create(:office) }
        let!(:commune) { create(:commune, offices: [office]) }
        let!(:collectivity) { create(:collectivity, territory: commune) }

        it "renders users links & actions" do
          render_inline described_class.new(Office.all, pagy, namespace: :admin, parent: collectivity)

          expect(page).to have_selector(:table_row, "Guichet" => office.name) do |row|
            expect(row).to have_link(office.name,            href: "/admin/guichets/#{office.id}")
            expect(row).to have_link("Modifier ce guichet",  href: "/admin/guichets/#{office.id}/edit")
            expect(row).to have_link("Supprimer ce guichet", href: "/admin/guichets/#{office.id}/remove")
          end
        end
      end

      context "with a ddfip parent" do
        let!(:ddfip)   { create(:ddfip) }
        let!(:offices) { create_list(:office, 3, ddfip: ddfip) }

        it "renders users links & actions" do
          render_inline described_class.new(Office.all, pagy, namespace: :admin, parent: ddfip)

          expect(page).to have_selector(:table_row, "Guichet" => offices.first.name) do |row|
            expect(row).to have_link(offices.first.name,     href: "/admin/guichets/#{offices.first.id}")
            expect(row).to have_link("Modifier ce guichet",  href: "/admin/guichets/#{offices.first.id}/edit")
            expect(row).to have_link("Supprimer ce guichet", href: "/admin/guichets/#{offices.first.id}/remove")
          end
        end
      end
    end

    context "with organization namespace" do
      let!(:ddfip)   { create(:ddfip) }
      let!(:offices) { create_list(:office, 3, ddfip: ddfip) }

      before { sign_in_as(:organization_admin, organization: ddfip) }

      context "without parent" do
        it "renders users links & actions" do
          render_inline described_class.new(ddfip.offices, pagy, namespace: :organization)

          expect(page).to have_selector(:table_row, "Guichet" => offices.first.name) do |row|
            expect(row).to have_link(offices.first.name,     href: "/organisation/guichets/#{offices.first.id}")
            expect(row).to have_link("Modifier ce guichet",  href: "/organisation/guichets/#{offices.first.id}/edit")
            expect(row).to have_link("Supprimer ce guichet", href: "/organisation/guichets/#{offices.first.id}/remove")
          end
        end
      end
    end
  end
end
