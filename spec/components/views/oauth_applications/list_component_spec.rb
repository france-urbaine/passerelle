# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::OauthApplications::ListComponent, type: :component do
  describe "rendered component" do
    let!(:oauth_applications) { create_list(:oauth_application, 3) }
    let(:pagy)                { Pagy.new(count: 56, page: 1, limit: 20) }

    before { sign_in_as(:publisher) }

    it "renders pagination" do
      render_inline described_class.new(OauthApplication.all, pagy, namespace: :organization)

      expect(page).to have_text("56 applications | Page 1 sur 3")
    end

    it "renders a table of applications" do
      render_inline described_class.new(OauthApplication.all, pagy, namespace: :organization)

      expect(page).to have_selector(".datatable table") do |table|
        expect(table).to have_selector("th", text: "Nom")
        expect(table).to have_selector("th", text: "Date de création")

        expect(table).to have_selector(:table_row, {
          "Nom" => oauth_applications.first.name
        })
      end
    end

    it "renders a table with a limited set of columns" do
      render_inline described_class.new(OauthApplication.all, pagy, namespace: :organization) do |list|
        list.with_column(:name)
      end

      expect(page).to have_selector(".datatable table") do |table|
        expect(table).to have_selector("th", text: "Nom")

        expect(table).to have_selector(:table_row, {
          "Nom" => oauth_applications.first.name
        })
      end
    end
  end

  describe "links & actions" do
    let!(:user)               { create(:user, :publisher) }
    let!(:oauth_applications) { create_list(:oauth_application, 3, owner: user.organization) }
    let(:pagy)                { Pagy.new(count: 3) }

    context "with organization namespace" do
      before { sign_in(user) }

      it "renders users links & actions" do
        render_inline described_class.new(OauthApplication.all, pagy, namespace: :organization)

        expect(page).to have_selector(:table_row, "Nom" => oauth_applications.first.name) do |row|
          expect(row).to have_link(oauth_applications.first.name, href: "/organisation/oauth_applications/#{oauth_applications.first.id}")
          expect(row).to have_link("Modifier cette application",  href: "/organisation/oauth_applications/#{oauth_applications.first.id}/edit")
          expect(row).to have_link("Supprimer cette application", href: "/organisation/oauth_applications/#{oauth_applications.first.id}/remove")
        end
      end
    end
  end
end
