# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Users::ListComponent, type: :component do
  describe "rendered component" do
    let!(:users) { create_list(:user, 3) }
    let(:pagy)   { Pagy.new(count: 56, page: 1, limit: 20) }

    before { sign_in_as(:super_admin) }

    it "renders pagination" do
      render_inline described_class.new(User.all, pagy, namespace: :admin)

      expect(page).to have_text("56 utilisateurs | Page 1 sur 3")
    end

    it "renders a table of users" do
      render_inline described_class.new(User.all, pagy, namespace: :admin)

      expect(page).to have_selector(".datatable table") do |table|
        expect(table).to have_selector("th", text: "Utilisateur")
        expect(table).to have_selector("th", text: "Adresse mail")
        expect(table).to have_selector("th", text: "Organisation")
        expect(table).to have_selector("th", text: "Admin. de l'organisation")
        expect(table).to have_selector("th", text: "Admin. de Passerelle")
        expect(table).to have_selector("th", text: "Guichets")

        expect(table).to have_selector(:table_row, {
          "Utilisateur"  => users.first.name,
          "Adresse mail" => users.first.email,
          "Organisation" => users.first.organization.name
        })
      end
    end

    it "renders a table with a limited set of columns" do
      render_inline described_class.new(User.all, pagy, namespace: :admin) do |list|
        list.with_column(:name)
        list.with_column(:email)
      end

      expect(page).to have_selector(".datatable table") do |table|
        expect(table).to have_selector("th", text: "Utilisateur")
        expect(table).to have_selector("th", text: "Adresse mail")
        expect(table).to have_no_selector("th", text: "Organisation")
        expect(table).to have_no_selector("th", text: "Admin. de l'organisation")
        expect(table).to have_no_selector("th", text: "Admin. de Passerelle")
        expect(table).to have_no_selector("th", text: "Guichets")

        expect(table).to have_selector(:table_row, {
          "Utilisateur"  => users.first.name,
          "Adresse mail" => users.first.email
        })
      end
    end
  end

  describe "eager loading" do
    let(:pagy) { Pagy.new(count: 3) }

    before do
      sign_in_as(:super_admin)
      create_list(:user, 3)
    end

    # Expect strict_loading to raise an ActiveRecord::StrictLoadingViolationError
    # in case of a N+1 query.

    it "doesn't raise an error about N+1 queries with all default columns" do
      expect {
        render_inline described_class.new(User.strict_loading, pagy, namespace: :admin)
      }.not_to raise_error
    end

    it "doesn't raise an error about N+1 queries with a limited set of columns" do
      expect {
        render_inline described_class.new(User.strict_loading, pagy, namespace: :admin) do |list|
          list.with_column(:name)
          list.with_column(:organization)
          list.with_column(:offices)
        end
      }.not_to raise_error
    end
  end

  describe "links & actions" do
    let!(:users) { create_list(:user, 3) }
    let(:pagy)   { Pagy.new(count: 3) }

    context "with admin namespace" do
      before { sign_in_as(:super_admin) }

      context "without parent" do
        it "renders users links & actions" do
          render_inline described_class.new(User.all, pagy, namespace: :admin)

          expect(page).to have_selector(:table_row, "Utilisateur" => users.first.name) do |row|
            expect(row).to have_link(users.first.name,            href: "/admin/utilisateurs/#{users.first.id}")
            expect(row).to have_link("Modifier cet utilisateur",  href: "/admin/utilisateurs/#{users.first.id}/edit")
            expect(row).to have_link("Supprimer cet utilisateur", href: "/admin/utilisateurs/#{users.first.id}/remove")
            expect(row).to have_no_link("Exclure cet utilisateur du guichet")
          end
        end
      end

      context "with a collectivity parent" do
        let!(:collectivity) { create(:collectivity) }
        let!(:users)        { create_list(:user, 3, organization: collectivity) }

        it "renders users links & actions" do
          render_inline described_class.new(User.all, pagy, namespace: :admin, parent: collectivity)

          expect(page).to have_selector(:table_row, "Utilisateur" => users.first.name) do |row|
            expect(row).to have_link(users.first.name,            href: "/admin/utilisateurs/#{users.first.id}")
            expect(row).to have_link("Modifier cet utilisateur",  href: "/admin/utilisateurs/#{users.first.id}/edit")
            expect(row).to have_link("Supprimer cet utilisateur", href: "/admin/utilisateurs/#{users.first.id}/remove")
            expect(row).to have_no_link("Exclure cet utilisateur du guichet")
          end
        end
      end

      context "with an office parent" do
        let!(:ddfip)  { create(:ddfip) }
        let!(:office) { create(:office, ddfip: ddfip) }
        let!(:users)  { create_list(:user, 3, organization: ddfip, offices: [office]) }

        it "renders users links & actions" do
          render_inline described_class.new(User.all, pagy, namespace: :admin, parent: office)

          expect(page).to have_selector(:table_row, "Utilisateur" => users.first.name) do |row|
            expect(row).to have_link(users.first.name,                     href: "/admin/utilisateurs/#{users.first.id}")
            expect(row).to have_link("Modifier cet utilisateur",           href: "/admin/utilisateurs/#{users.first.id}/edit")
            expect(row).to have_link("Supprimer cet utilisateur",          href: "/admin/utilisateurs/#{users.first.id}/remove")
            expect(row).to have_link("Exclure cet utilisateur du guichet", href: "/admin/guichets/#{office.id}/utilisateurs/#{users.first.id}/remove")
          end
        end
      end
    end

    context "with organization namespace" do
      let!(:organization) { create(%i[publisher ddfip collectivity].sample) }
      let!(:users)        { create_list(:user, 3, organization: organization) }

      before { sign_in_as(:organization_admin, organization: organization) }

      context "without parent" do
        it "renders users links & actions" do
          render_inline described_class.new(organization.users, pagy, namespace: :organization)

          expect(page).to have_selector(:table_row, "Utilisateur" => users.first.name) do |row|
            expect(row).to have_link(users.first.name,            href: "/organisation/utilisateurs/#{users.first.id}")
            expect(row).to have_link("Modifier cet utilisateur",  href: "/organisation/utilisateurs/#{users.first.id}/edit")
            expect(row).to have_link("Supprimer cet utilisateur", href: "/organisation/utilisateurs/#{users.first.id}/remove")
            expect(row).to have_no_link("Exclure cet utilisateur du guichet")
          end
        end
      end

      context "with a collectivity parent" do
        let!(:organization) { create(:publisher) }
        let!(:collectivity) { create(:collectivity, publisher: organization) }
        let!(:users)        { create_list(:user, 3, organization: collectivity) }

        context "when collectivity doesn't allow management by publisher" do
          it "renders no links or actions" do
            render_inline described_class.new(collectivity.users, pagy, namespace: :organization, parent: collectivity)

            expect(page).to have_selector(:table_row, "Utilisateur" => users.first.name) do |row|
              expect(row).to have_no_link(users.first.name)
              expect(row).to have_no_link("Modifier cet utilisateur")
              expect(row).to have_no_link("Supprimer cet utilisateur")
              expect(row).to have_no_link("Exclure cet utilisateur du guichet")
            end
          end
        end

        context "when collectivity allows management by publisher" do
          before { collectivity.update(allow_publisher_management: true) }

          it "renders users links & actions" do
            render_inline described_class.new(User.all, pagy, namespace: :organization, parent: collectivity)

            expect(page).to have_selector(:table_row, "Utilisateur" => users.first.name) do |row|
              expect(row).to have_link(users.first.name,            href: "/organisation/collectivites/#{collectivity.id}/utilisateurs/#{users.first.id}")
              expect(row).to have_link("Modifier cet utilisateur",  href: "/organisation/collectivites/#{collectivity.id}/utilisateurs/#{users.first.id}/edit")
              expect(row).to have_link("Supprimer cet utilisateur", href: "/organisation/collectivites/#{collectivity.id}/utilisateurs/#{users.first.id}/remove")
              expect(row).to have_no_link("Exclure cet utilisateur du guichet")
            end
          end
        end
      end

      context "with an office parent" do
        let!(:organization) { create(:ddfip) }
        let!(:office)       { create(:office, ddfip: organization) }
        let!(:users)        { create_list(:user, 3, organization: organization, offices: [office]) }

        it "renders users links & actions" do
          render_inline described_class.new(User.all, pagy, namespace: :organization, parent: office)

          expect(page).to have_selector(:table_row, "Utilisateur" => users.first.name) do |row|
            expect(row).to have_link(users.first.name,                     href: "/organisation/utilisateurs/#{users.first.id}")
            expect(row).to have_link("Modifier cet utilisateur",           href: "/organisation/utilisateurs/#{users.first.id}/edit")
            expect(row).to have_link("Supprimer cet utilisateur",          href: "/organisation/utilisateurs/#{users.first.id}/remove")
            expect(row).to have_link("Exclure cet utilisateur du guichet", href: "/organisation/guichets/#{office.id}/utilisateurs/#{users.first.id}/remove")
          end
        end
      end
    end
  end
end
