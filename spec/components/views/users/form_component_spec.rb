# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Users::FormComponent, type: :component do
  let_it_be(:ddfip)   { create(:ddfip) }
  let_it_be(:offices) { create_list(:office, 3, ddfip: ddfip) }

  context "with admin scope" do
    before { sign_in_as(:super_admin) }

    it "renders a form in a modal to create a new user" do
      render_inline described_class.new(User.new, namespace: :admin)

      expect(page).to have_selector(".modal form") do |form|
        expect(form).to have_html_attribute("action").with_value("/admin/utilisateurs")

        expect(form).to have_field("Organisation")
        expect(form).to have_field("Nom")
        expect(form).to have_field("Prénom")
        expect(form).to have_unchecked_field("Administrateur de l'organisation")
        expect(form).to have_unchecked_field("Administrateur de la plateforme Passerelle")
        expect(form).to have_no_field(name: "user[office_ids][]", type: :hidden)

        expect(form).to have_selector(".form-block", text: "Guichets",       visible: :hidden)
        expect(form).to have_selector("turbo-frame#user_offices_checkboxes", visible: :hidden)
      end
    end

    it "renders a form in a modal to create a new user belonging to a given publisher" do
      publisher = build_stubbed(:publisher)
      render_inline described_class.new(User.new, namespace: :admin, organization: publisher)

      expect(page).to have_selector(".modal form") do |form|
        expect(form).to have_html_attribute("action").with_value("/admin/editeurs/#{publisher.id}/utilisateurs")

        expect(form).to have_no_field("Organisation")
        expect(form).to have_field("Nom")
        expect(form).to have_field("Prénom")
        expect(form).to have_unchecked_field("Administrateur de l'organisation")
        expect(form).to have_unchecked_field("Administrateur de la plateforme Passerelle")
        expect(form).to have_no_field(name: "user[office_ids][]", type: :hidden)

        expect(form).to have_no_selector(".form-block", text: "Guichets",       visible: :all)
        expect(form).to have_no_selector("turbo-frame#user_offices_checkboxes", visible: :all)
      end
    end

    it "renders a form in a modal to create a new user belonging to a given collectivity" do
      collectivity = build_stubbed(:collectivity)
      render_inline described_class.new(User.new, namespace: :admin, organization: collectivity)

      expect(page).to have_selector(".modal form") do |form|
        expect(form).to have_html_attribute("action").with_value("/admin/collectivites/#{collectivity.id}/utilisateurs")

        expect(form).to have_no_field("Organisation")
        expect(form).to have_field("Nom")
        expect(form).to have_field("Prénom")
        expect(form).to have_unchecked_field("Administrateur de l'organisation")
        expect(form).to have_unchecked_field("Administrateur de la plateforme Passerelle")
        expect(form).to have_no_field(name: "user[office_ids][]", type: :hidden)

        expect(form).to have_no_selector(".form-block", text: "Guichets",       visible: :all)
        expect(form).to have_no_selector("turbo-frame#user_offices_checkboxes", visible: :all)
      end
    end

    it "renders a form in a modal to create a new user belonging to a given DDFIP" do
      ddfip = create(:ddfip)
      render_inline described_class.new(User.new, namespace: :admin, organization: ddfip)

      expect(page).to have_selector(".modal form") do |form|
        expect(form).to have_html_attribute("action").with_value("/admin/ddfips/#{ddfip.id}/utilisateurs")

        expect(form).to have_no_field("Organisation")
        expect(form).to have_field("Nom")
        expect(form).to have_field("Prénom")
        expect(form).to have_unchecked_field("Administrateur de l'organisation")
        expect(form).to have_unchecked_field("Administrateur de la plateforme Passerelle")
        expect(form).to have_field(name: "user[office_ids][]", type: :hidden)

        expect(form).to have_selector(".form-block", text: "Guichets",          visible: :visible)
        expect(form).to have_no_selector("turbo-frame#user_offices_checkboxes", visible: :all)
      end
    end

    it "renders a form in a modal to update an existing publisher user" do
      user = build_stubbed(:user, :publisher)
      render_inline described_class.new(user, namespace: :admin)

      expect(page).to have_selector(".modal form") do |form|
        expect(form).to have_html_attribute("action").with_value("/admin/utilisateurs/#{user.id}")

        expect(form).to have_field("Organisation", with: user.organization&.name)
        expect(form).to have_field("Nom",          with: user.last_name)
        expect(form).to have_field("Prénom",       with: user.first_name)
        expect(form).to have_unchecked_field("Administrateur de l'organisation")
        expect(form).to have_unchecked_field("Administrateur de la plateforme Passerelle")
        expect(form).to have_no_field(name: "user[office_ids][]", type: :hidden)

        expect(form).to have_selector(".form-block", text: "Guichets",       visible: :hidden)
        expect(form).to have_selector("turbo-frame#user_offices_checkboxes", visible: :hidden)
      end
    end

    it "renders a form in a modal to update an existing DDFIP user" do
      user = build_stubbed(:user, :ddfip)
      render_inline described_class.new(user, namespace: :admin)

      expect(page).to have_selector(".modal form") do |form|
        expect(form).to have_html_attribute("action").with_value("/admin/utilisateurs/#{user.id}")

        expect(form).to have_field("Organisation", with: user.organization&.name)
        expect(form).to have_field("Nom",          with: user.last_name)
        expect(form).to have_field("Prénom",       with: user.first_name)
        expect(form).to have_unchecked_field("Administrateur de l'organisation")
        expect(form).to have_unchecked_field("Administrateur de la plateforme Passerelle")
        expect(form).to have_no_field(name: "user[office_ids][]", type: :hidden)

        expect(form).to have_selector(".form-block", text: "Guichets",       visible: :visible)
        expect(form).to have_selector("turbo-frame#user_offices_checkboxes", visible: :visible)
      end
    end

    it "renders a form in a modal to update an existing admin" do
      user = build_stubbed(:user, :organization_admin, :super_admin)
      render_inline described_class.new(user, namespace: :admin)

      expect(page).to have_selector(".modal form") do |form|
        expect(form).to have_html_attribute("action").with_value("/admin/utilisateurs/#{user.id}")

        expect(form).to have_field("Organisation", with: user.organization&.name)
        expect(form).to have_field("Nom",          with: user.last_name)
        expect(form).to have_field("Prénom",       with: user.first_name)
        expect(form).to have_checked_field("Administrateur de l'organisation")
        expect(form).to have_checked_field("Administrateur de la plateforme Passerelle")
      end
    end
  end

  context "with organization scope and logged in as a publisher admin" do
    before { sign_in_as(:publisher, :organization_admin) }

    it "renders a form in a modal to create a new user" do
      render_inline described_class.new(User.new, namespace: :organization)

      expect(page).to have_selector(".modal form") do |form|
        expect(form).to have_html_attribute("action").with_value("/organisation/utilisateurs")

        expect(form).to have_no_field("Organisation")
        expect(form).to have_field("Nom")
        expect(form).to have_field("Prénom")
        expect(form).to have_field("Administrateur de l'organisation")
        expect(form).to have_no_field("Administrateur de la plateforme Passerelle")
        expect(form).to have_no_field(name: "user[office_ids][]", type: :hidden)

        expect(form).to have_no_selector(".form-block", text: "Guichets",       visible: :all)
        expect(form).to have_no_selector("turbo-frame#user_offices_checkboxes", visible: :all)
      end
    end

    it "renders a form in a modal to update an existing user" do
      user = build_stubbed(:user, organization: current_user.organization)
      render_inline described_class.new(user, namespace: :organization)

      expect(page).to have_selector(".modal form") do |form|
        expect(form).to have_html_attribute("action").with_value("/organisation/utilisateurs/#{user.id}")

        expect(form).to have_no_field("Organisation")
        expect(form).to have_field("Nom",          with: user.last_name)
        expect(form).to have_field("Prénom",       with: user.first_name)
        expect(form).to have_unchecked_field("Administrateur de l'organisation")
        expect(form).to have_no_field("Administrateur de la plateforme Passerelle")
        expect(form).to have_no_field(name: "user[office_ids][]", type: :hidden)

        expect(form).to have_no_selector(".form-block", text: "Guichets",       visible: :all)
        expect(form).to have_no_selector("turbo-frame#user_offices_checkboxes", visible: :all)
      end
    end

    it "renders a form in a modal to update an existing admin" do
      user = build_stubbed(:user, :organization_admin, organization: current_user.organization)
      render_inline described_class.new(user, namespace: :organization)

      expect(page).to have_selector(".modal form") do |form|
        expect(form).to have_html_attribute("action").with_value("/organisation/utilisateurs/#{user.id}")

        expect(form).to have_no_field("Organisation")
        expect(form).to have_field("Nom",          with: user.last_name)
        expect(form).to have_field("Prénom",       with: user.first_name)
        expect(form).to have_checked_field("Administrateur de l'organisation")
        expect(form).to have_no_field("Administrateur de la plateforme Passerelle")
      end
    end

    it "does not renders super admin checkbox even when signed as a super admin" do
      current_user.update(super_admin: true)
      render_inline described_class.new(User.new, namespace: :organization)

      expect(page).to have_selector(".modal form") do |form|
        expect(form).to have_field("Administrateur de l'organisation")
        expect(form).to have_no_field("Administrateur de la plateforme Passerelle")
      end
    end

    it "renders a form in a modal to create a new user in an owned collectivity" do
      collectivity = build_stubbed(:collectivity, publisher: current_user.organization)

      render_inline described_class.new(User.new, namespace: :organization, organization: collectivity)

      expect(page).to have_selector(".modal form") do |form|
        expect(form).to have_html_attribute("action").with_value("/organisation/collectivites/#{collectivity.id}/utilisateurs")

        expect(form).to have_no_field("Organisation")
        expect(form).to have_field("Nom")
        expect(form).to have_field("Prénom")
        expect(form).to have_field("Administrateur de l'organisation")
        expect(form).to have_no_field("Administrateur de la plateforme Passerelle")
        expect(form).to have_no_field(name: "user[office_ids][]", type: :hidden)

        expect(form).to have_no_selector(".form-block", text: "Guichets",       visible: :all)
        expect(form).to have_no_selector("turbo-frame#user_offices_checkboxes", visible: :all)
      end
    end

    it "renders a form in a modal to update an existing user from an owned collectivity" do
      collectivity = build_stubbed(:collectivity, publisher: current_user.organization)
      user         = build_stubbed(:user, organization: collectivity)

      render_inline described_class.new(user, namespace: :organization, organization: collectivity)

      expect(page).to have_selector(".modal form") do |form|
        expect(form).to have_html_attribute("action").with_value("/organisation/collectivites/#{collectivity.id}/utilisateurs/#{user.id}")

        expect(form).to have_no_field("Organisation")
        expect(form).to have_field("Nom",          with: user.last_name)
        expect(form).to have_field("Prénom",       with: user.first_name)
        expect(form).to have_unchecked_field("Administrateur de l'organisation")
        expect(form).to have_no_field("Administrateur de la plateforme Passerelle")
        expect(form).to have_no_field(name: "user[office_ids][]", type: :hidden)

        expect(form).to have_no_selector(".form-block", text: "Guichets",       visible: :all)
        expect(form).to have_no_selector("turbo-frame#user_offices_checkboxes", visible: :all)
      end
    end
  end

  context "with organization scope and logged in as a publisher user" do
    before { sign_in_as(:publisher) }

    it "renders a form in a modal to create a new user in an owned collectivity without admin checkbox" do
      collectivity = build_stubbed(:collectivity, publisher: current_user.organization)

      render_inline described_class.new(User.new, namespace: :organization, organization: collectivity)

      expect(page).to have_selector(".modal form") do |form|
        expect(form).to have_html_attribute("action").with_value("/organisation/collectivites/#{collectivity.id}/utilisateurs")

        expect(form).to have_no_field("Organisation")
        expect(form).to have_field("Nom")
        expect(form).to have_field("Prénom")
        expect(form).to have_no_field("Administrateur de l'organisation")
        expect(form).to have_no_field("Administrateur de la plateforme Passerelle")
      end
    end

    it "renders a form in a modal to update an existing user from an owned collectivity without admin checkbox" do
      collectivity = build_stubbed(:collectivity, publisher: current_user.organization)
      user         = build_stubbed(:user, organization: collectivity)

      render_inline described_class.new(user, namespace: :organization, organization: collectivity)

      expect(page).to have_selector(".modal form") do |form|
        expect(form).to have_html_attribute("action").with_value("/organisation/collectivites/#{collectivity.id}/utilisateurs/#{user.id}")

        expect(form).to have_no_field("Organisation")
        expect(form).to have_field("Nom",          with: user.last_name)
        expect(form).to have_field("Prénom",       with: user.first_name)
        expect(form).to have_no_field("Administrateur de l'organisation")
        expect(form).to have_no_field("Administrateur de la plateforme Passerelle")
      end
    end
  end

  context "with organization scope and logged in as a collectivity admin" do
    before { sign_in_as(:collectivity, :organization_admin) }

    it "renders a form in a modal to create a new user" do
      render_inline described_class.new(User.new, namespace: :organization)

      expect(page).to have_selector(".modal form") do |form|
        expect(form).to have_html_attribute("action").with_value("/organisation/utilisateurs")

        expect(form).to have_no_field("Organisation")
        expect(form).to have_field("Nom")
        expect(form).to have_field("Prénom")
        expect(form).to have_field("Administrateur de l'organisation")
        expect(form).to have_no_field("Administrateur de la plateforme Passerelle")
        expect(form).to have_no_field(name: "user[office_ids][]", type: :hidden)

        expect(form).to have_no_selector(".form-block", text: "Guichets",       visible: :all)
        expect(form).to have_no_selector("turbo-frame#user_offices_checkboxes", visible: :all)
      end
    end

    it "renders a form in a modal to update an existing user" do
      user = build_stubbed(:user, organization: current_user.organization)
      render_inline described_class.new(user, namespace: :organization)

      expect(page).to have_selector(".modal form") do |form|
        expect(form).to have_html_attribute("action").with_value("/organisation/utilisateurs/#{user.id}")

        expect(form).to have_no_field("Organisation")
        expect(form).to have_field("Nom",          with: user.last_name)
        expect(form).to have_field("Prénom",       with: user.first_name)
        expect(form).to have_unchecked_field("Administrateur de l'organisation")
        expect(form).to have_no_field("Administrateur de la plateforme Passerelle")
        expect(form).to have_no_field(name: "user[office_ids][]", type: :hidden)

        expect(form).to have_no_selector(".form-block", text: "Guichets",       visible: :all)
        expect(form).to have_no_selector("turbo-frame#user_offices_checkboxes", visible: :all)
      end
    end

    it "renders a form in a modal to update an existing admin" do
      user = build_stubbed(:user, :organization_admin, organization: current_user.organization)
      render_inline described_class.new(user, namespace: :organization)

      expect(page).to have_selector(".modal form") do |form|
        expect(form).to have_html_attribute("action").with_value("/organisation/utilisateurs/#{user.id}")

        expect(form).to have_no_field("Organisation")
        expect(form).to have_field("Nom",          with: user.last_name)
        expect(form).to have_field("Prénom",       with: user.first_name)
        expect(form).to have_checked_field("Administrateur de l'organisation")
        expect(form).to have_no_field("Administrateur de la plateforme Passerelle")
      end
    end

    it "does not renders super admin checkbox even when signed as a super admin" do
      current_user.update(super_admin: true)
      render_inline described_class.new(User.new, namespace: :organization)

      expect(page).to have_selector(".modal form") do |form|
        expect(form).to have_field("Administrateur de l'organisation")
        expect(form).to have_no_field("Administrateur de la plateforme Passerelle")
      end
    end
  end

  context "with organization scope and logged in as a DDFIP admin" do
    before { sign_in_as(:ddfip, :organization_admin, organization: ddfip) }

    it "renders a form in a modal to create a new user" do
      render_inline described_class.new(User.new, namespace: :organization)

      expect(page).to have_selector(".modal form") do |form|
        expect(form).to have_html_attribute("action").with_value("/organisation/utilisateurs")

        expect(form).to have_no_field("Organisation")
        expect(form).to have_field("Nom")
        expect(form).to have_field("Prénom")
        expect(form).to have_field("Administrateur de l'organisation")
        expect(form).to have_no_field("Administrateur de la plateforme Passerelle")
        expect(form).to have_field(name: "user[office_ids][]", type: :hidden)

        expect(form).to have_selector(".form-block", text: "Guichets",          visible: :visible)
        expect(form).to have_no_selector("turbo-frame#user_offices_checkboxes", visible: :all)
      end
    end

    it "renders a form in a modal to update an existing user" do
      user = build_stubbed(:user, organization: ddfip, offices: offices[2..])
      render_inline described_class.new(user, namespace: :organization)

      expect(page).to have_selector(".modal form") do |form|
        expect(form).to have_html_attribute("action").with_value("/organisation/utilisateurs/#{user.id}")

        expect(form).to have_no_field("Organisation")
        expect(form).to have_field("Nom",          with: user.last_name)
        expect(form).to have_field("Prénom",       with: user.first_name)
        expect(form).to have_unchecked_field("Administrateur de l'organisation")
        expect(form).to have_no_field("Administrateur de la plateforme Passerelle")

        expect(form).to have_selector("label", text: "Guichets")
        expect(form).to have_field("user[office_ids][]", count: 3)
        expect(form).to have_unchecked_field(offices[0].name)
        expect(form).to have_unchecked_field(offices[1].name)
        expect(form).to have_checked_field(offices[2].name)
      end
    end

    it "renders a form in a modal to update an existing admin" do
      user = build_stubbed(:user, :organization_admin, organization: current_user.organization)
      render_inline described_class.new(user, namespace: :organization)

      expect(page).to have_selector(".modal form") do |form|
        expect(form).to have_html_attribute("action").with_value("/organisation/utilisateurs/#{user.id}")

        expect(form).to have_no_field("Organisation")
        expect(form).to have_field("Nom",          with: user.last_name)
        expect(form).to have_field("Prénom",       with: user.first_name)
        expect(form).to have_checked_field("Administrateur de l'organisation")
        expect(form).to have_no_field("Administrateur de la plateforme Passerelle")
      end
    end

    it "does not renders super admin checkbox even when signed as a super admin" do
      current_user.update(super_admin: true)
      render_inline described_class.new(User.new, namespace: :organization)

      expect(page).to have_selector(".modal form") do |form|
        expect(form).to have_field("Administrateur de l'organisation")
        expect(form).to have_no_field("Administrateur de la plateforme Passerelle")
      end
    end
  end
end
