# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Collectivities::ListComponent, type: :component do
  describe "rendered component" do
    let!(:collectivities) { create_list(:collectivity, 3) }
    let(:pagy)            { Pagy.new(count: 56, page: 1, items: 20) }

    before { sign_in_as(:super_admin) }

    it "renders pagination" do
      render_inline described_class.new(Collectivity.all, pagy, namespace: :admin)

      expect(page).to have_text("56 collectivités | Page 1 sur 3")
    end

    it "renders a table of users" do
      render_inline described_class.new(Collectivity.all, pagy, namespace: :admin)

      expect(page).to have_selector(".datatable table") do |table|
        aggregate_failures do
          expect(table).to have_selector("th", text: "Collectivité")
          expect(table).to have_selector("th", text: "SIREN")
          expect(table).to have_selector("th", text: "Éditeur")
          expect(table).to have_selector("th", text: "Contact")
          expect(table).to have_selector("th", text: "Adresse mail de contact")
          expect(table).to have_selector("th", text: "Numéro de téléphone")
          expect(table).to have_selector("th", text: "Utilisateurs")
          expect(table).to have_selector("th", text: "Paquets")
          expect(table).to have_selector("th", text: "Signalements")
          expect(table).to have_selector("th", text: "Approuvés")
          expect(table).to have_selector("th", text: "Rejetés")

          expect(table).to have_selector(:table_row, {
            "Collectivité"  => collectivities.first.name,
            "SIREN" => collectivities.first.siren,
            "Éditeur" => collectivities.first.publisher.name
          })
        end
      end
    end

    it "renders a table with a limited set of columns" do
      render_inline described_class.new(Collectivity.all, pagy, namespace: :admin) do |list|
        list.with_column(:name)
        list.with_column(:siren)
      end

      expect(page).to have_selector(".datatable table") do |table|
        aggregate_failures do
          expect(table).to have_selector("th",     text: "Collectivité")
          expect(table).to have_selector("th",     text: "SIREN")
          expect(table).not_to have_selector("th", text: "Éditeur")
          expect(table).not_to have_selector("th", text: "Contact")
          expect(table).not_to have_selector("th", text: "Adresse mail de contact")
          expect(table).not_to have_selector("th", text: "Numéro de téléphone")
          expect(table).not_to have_selector("th", text: "Utilisateurs")
          expect(table).not_to have_selector("th", text: "Paquets")
          expect(table).not_to have_selector("th", text: "Signalements")
          expect(table).not_to have_selector("th", text: "Approuvés")
          expect(table).not_to have_selector("th", text: "Rejetés")

          expect(table).to have_selector(:table_row, {
            "Collectivité"  => collectivities.first.name,
            "SIREN" => collectivities.first.siren
          })
        end
      end
    end
  end

  describe "links & actions" do
    let!(:collectivities) { create_list(:collectivity, 3) }
    let(:pagy)            { Pagy.new(count: 3) }

    context "with admin namespace" do
      before { sign_in_as(:super_admin) }

      context "without parent" do
        it "renders collectivites links & actions" do
          render_inline described_class.new(Collectivity.all, pagy, namespace: :admin)

          expect(page).to have_selector(:table_row, "Collectivité" => collectivities.first.name) do |row|
            aggregate_failures do
              expect(row).to     have_link(collectivities.first.name,      href: "/admin/collectivites/#{collectivities.first.id}")
              expect(row).to     have_link("Modifier cette collectivité",  href: "/admin/collectivites/#{collectivities.first.id}/edit")
              expect(row).to     have_link("Supprimer cette collectivité", href: "/admin/collectivites/#{collectivities.first.id}/remove")
            end
          end
        end
      end

      context "with a ddfip parent" do
        let!(:ddfip) { create(:ddfip) }
        let!(:commune) { create(:commune, code_departement: ddfip.code_departement) }
        let!(:collectivity) { create(:collectivity, territory: commune) }

        it "renders collectivites links & actions" do
          render_inline described_class.new(Collectivity.all, pagy, namespace: :admin, parent: ddfip)

          expect(page).to have_selector(:table_row, "Collectivité" => collectivity.name) do |row|
            aggregate_failures do
              expect(row).to have_link(collectivity.name,              href: "/admin/collectivites/#{collectivity.id}")
              expect(row).to have_link("Modifier cette collectivité",  href: "/admin/collectivites/#{collectivity.id}/edit")
              expect(row).to have_link("Supprimer cette collectivité", href: "/admin/collectivites/#{collectivity.id}/remove")
            end
          end
        end
      end

      context "with an office parent" do
        let!(:office) { create(:office) }
        let!(:commune) { create(:commune, offices: [office]) }
        let!(:collectivity) { create(:collectivity, territory: commune) }

        it "renders collectivites links & actions" do
          render_inline described_class.new(Collectivity.all, pagy, namespace: :admin, parent: office)

          expect(page).to have_selector(:table_row, "Collectivité" => collectivity.name) do |row|
            aggregate_failures do
              expect(row).to have_link(collectivity.name,              href: "/admin/collectivites/#{collectivity.id}")
              expect(row).to have_link("Modifier cette collectivité",  href: "/admin/collectivites/#{collectivity.id}/edit")
              expect(row).to have_link("Supprimer cette collectivité", href: "/admin/collectivites/#{collectivity.id}/remove")
            end
          end
        end
      end

      context "with a publisher parent" do
        let!(:publisher) { create(:publisher) }
        let!(:collectivity) { create(:collectivity, publisher: publisher) }

        it "renders collectivites links & actions" do
          render_inline described_class.new(Collectivity.all, pagy, namespace: :admin, parent: publisher)

          expect(page).to have_selector(:table_row, "Collectivité" => collectivity.name) do |row|
            aggregate_failures do
              expect(row).to have_link(collectivity.name,              href: "/admin/collectivites/#{collectivity.id}")
              expect(row).to have_link("Modifier cette collectivité",  href: "/admin/collectivites/#{collectivity.id}/edit")
              expect(row).to have_link("Supprimer cette collectivité", href: "/admin/collectivites/#{collectivity.id}/remove")
            end
          end
        end
      end
    end

    context "with organization namespace" do
      let!(:ddfip) { create(:ddfip) }
      let!(:commune) { create(:commune, code_departement: ddfip.code_departement) }
      let!(:publisher) { create(:publisher) }
      let!(:collectivity) { create(:collectivity, territory: commune, publisher: publisher) }

      before { sign_in_as(:organization_admin, organization: [ddfip, publisher].sample) }

      context "without parent" do
        it "renders collectivites links & actions" do
          render_inline described_class.new(Collectivity.all, pagy, namespace: :organization)

          expect(page).to have_selector(:table_row, "Collectivité" => collectivity.name) do |row|
            aggregate_failures do
              expect(row).to     have_link(collectivity.name,              href: "/organisation/collectivites/#{collectivity.id}")
              expect(row).not_to have_link("Modifier cette collectivité",  href: "/organisation/collectivites/#{collectivity.id}/edit")
              expect(row).not_to have_link("Supprimer cette collectivité", href: "/organisation/collectivites/#{collectivity.id}/remove")
            end
          end
        end
      end

      context "with office parent" do
        let!(:ddfip) { create(:ddfip) }
        let!(:office) { create(:office, ddfip: ddfip) }
        let!(:commune) { create(:commune, code_departement: ddfip.code_departement, offices: [office]) }
        let!(:collectivity) { create(:collectivity, territory: commune) }

        before { sign_in_as(:organization_admin, organization: ddfip) }

        it "renders collectivites links & actions" do
          render_inline described_class.new(Collectivity.all, pagy, namespace: :organization, parent: office)

          expect(page).to have_selector(:table_row, "Collectivité" => collectivity.name) do |row|
            aggregate_failures do
              expect(row).to     have_link(collectivity.name,              href: "/organisation/collectivites/#{collectivity.id}")
              expect(row).not_to have_link("Modifier cette collectivité",  href: "/organisation/collectivites/#{collectivity.id}/edit")
              expect(row).not_to have_link("Supprimer cette collectivité", href: "/organisation/collectivites/#{collectivity.id}/remove")
            end
          end
        end
      end
    end

    context "with territories namespace" do
      before { sign_in_as(:super_admin) }

      context "with commune parent" do
        let!(:commune)      { create(:commune) }
        let!(:collectivity) { create(:collectivity, territory: commune) }

        it "renders collectivites links & actions" do
          render_inline described_class.new(Collectivity.all, pagy, namespace: :territories, parent: commune)

          expect(page).to have_selector(:table_row, "Collectivité" => collectivity.name) do |row|
            aggregate_failures do
              expect(row).to     have_link(collectivity.name,              href: "/admin/collectivites/#{collectivity.id}")
              expect(row).not_to have_link("Modifier cette collectivité",  href: "/admin/collectivites/#{collectivity.id}/edit")
              expect(row).not_to have_link("Supprimer cette collectivité", href: "/admin/collectivites/#{collectivity.id}/remove")
            end
          end
        end
      end

      context "with department parent" do
        let!(:departement)  { create(:departement) }
        let!(:collectivity) { create(:collectivity, territory: departement) }

        it "renders collectivites links & actions" do
          render_inline described_class.new(Collectivity.all, pagy, namespace: :territories, parent: departement)

          expect(page).to have_selector(:table_row, "Collectivité" => collectivity.name) do |row|
            aggregate_failures do
              expect(row).to     have_link(collectivity.name,              href: "/admin/collectivites/#{collectivity.id}")
              expect(row).not_to have_link("Modifier cette collectivité",  href: "/admin/collectivites/#{collectivity.id}/edit")
              expect(row).not_to have_link("Supprimer cette collectivité", href: "/admin/collectivites/#{collectivity.id}/remove")
            end
          end
        end
      end

      context "with epci parent" do
        let!(:epci)         { create(:epci) }
        let!(:collectivity) { create(:collectivity, territory: epci) }

        it "renders collectivites links & actions" do
          render_inline described_class.new(Collectivity.all, pagy, namespace: :territories, parent: epci)

          expect(page).to have_selector(:table_row, "Collectivité" => collectivity.name) do |row|
            aggregate_failures do
              expect(row).to     have_link(collectivity.name,              href: "/admin/collectivites/#{collectivity.id}")
              expect(row).not_to have_link("Modifier cette collectivité",  href: "/admin/collectivites/#{collectivity.id}/edit")
              expect(row).not_to have_link("Supprimer cette collectivité", href: "/admin/collectivites/#{collectivity.id}/remove")
            end
          end
        end
      end

      context "with region parent" do
        let!(:region)       { create(:region) }
        let!(:collectivity) { create(:collectivity, territory: region) }

        it "renders collectivites links & actions" do
          render_inline described_class.new(Collectivity.all, pagy, namespace: :territories, parent: region)

          expect(page).to have_selector(:table_row, "Collectivité" => collectivity.name) do |row|
            aggregate_failures do
              expect(row).to     have_link(collectivity.name,              href: "/admin/collectivites/#{collectivity.id}")
              expect(row).not_to have_link("Modifier cette collectivité",  href: "/admin/collectivites/#{collectivity.id}/edit")
              expect(row).not_to have_link("Supprimer cette collectivité", href: "/admin/collectivites/#{collectivity.id}/remove")
            end
          end
        end
      end
    end
  end
end
