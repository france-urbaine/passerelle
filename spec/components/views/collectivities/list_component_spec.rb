# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Collectivities::ListComponent, type: :component do
  context "with admin namespace" do
    let!(:collectivities) { create_list(:collectivity, 3) }
    let(:pagy)            { Pagy.new(count: 56, page: 1, items: 20) }

    before { sign_in_as(:super_admin) }

    it "renders pagination" do
      render_inline described_class.new(Collectivity.all, pagy, namespace: :admin)

      expect(page).to have_text("56 collectivités | Page 1 sur 3")
    end

    it "renders a table of users" do
      render_inline described_class.new(Collectivity.all, pagy, namespace: :admin)

      expect(page).to have_table(class: "datatable") do |table|
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

      expect(page).to have_table(class: "datatable") do |table|
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

    it "renders collectivities links" do
      render_inline described_class.new(Collectivity.all, pagy, namespace: :admin)

      expect(page).to have_selector(:table_row, "Collectivité" => collectivities.first.name) do |row|
        expect(row).to have_link(collectivities.first.name, href: "/admin/collectivites/#{collectivities.first.id}")
      end
    end
  end

  context "with organization namespace" do
    let!(:publisher)      { create(:publisher) }
    let!(:collectivities) { create_list(:collectivity, 3, publisher: publisher) }
    let(:pagy)            { Pagy.new(count: 56, page: 1, items: 20) }

    before { sign_in_as(:organization_admin, organization: publisher) }

    it "renders links to collectivities" do
      render_inline described_class.new(publisher.collectivities, pagy, namespace: :organization)

      expect(page).to have_selector(:table_row, "Collectivité" => collectivities.first.name) do |row|
        expect(row).to have_link(collectivities.first.name, href: "/organisation/collectivites/#{collectivities.first.id}")
      end
    end
  end

  context "with territories namespace" do
    let!(:collectivities) { create_list(:collectivity, 3) }
    let(:pagy)            { Pagy.new(count: 56, page: 1, items: 20) }

    before { sign_in_as(:super_admin) }

    it "renders links to collectivities" do
      render_inline described_class.new(Collectivity.all, pagy, namespace: :territories)

      expect(page).to have_selector(:table_row, "Collectivité" => collectivities.first.name) do |row|
        expect(row).to have_link(collectivities.first.name, href: "/admin/collectivites/#{collectivities.first.id}")
      end
    end
  end
end
