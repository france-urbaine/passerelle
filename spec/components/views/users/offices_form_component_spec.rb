# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Users::OfficesFormComponent, type: :component do
  let_it_be(:ddfip)       { create(:ddfip) }
  let_it_be(:offices)     { create_list(:office, 3, ddfip: ddfip) }
  let_it_be(:user)        { create(:user, organization: ddfip) }
  let_it_be(:office_user) { create(:office_user, office: offices[0], user:, supervisor: true) }

  context "with admin scope" do
    before { sign_in_as(:super_admin) }

    it "renders hidden turbo-frame to assign offices when no organization is set" do
      render_inline described_class.new(User.new, namespace: :admin)

      expect(page).to have_selector(".form-block", visible: :hidden) do |form_block|
        expect(form_block).to have_html_attribute("data-user-form-target").with_value("officesFormBlock")
        expect(form_block).to have_selector("turbo-frame[data-user-form-target='officesCheckboxesFrame']", visible: :hidden)
      end

      expect(page).to have_no_selector(".choices-collection")
    end

    it "renders fields to assign offices when user's organization is a DDFIP" do
      render_inline described_class.new(User.new, namespace: :admin, organization: ddfip)

      expect(page).to have_selector(".choices-collection") do |form_block|
        ddfip.offices.order(:name).each_with_index do |office, index|
          expect(form_block).to have_selector("input#user_office_users_attributes_#{index}_id", visible: :hidden)
          expect(form_block).to have_selector("input#user_office_users_attributes_#{index}_office_id[value='#{office.id}']", visible: :hidden)

          expect(form_block).to have_selector("#user_office_users_attributes_#{index}_office_id + [data-controller='switch']") do |switch|
            expect(switch).to have_unchecked_field(office.name)
            expect(switch).to have_selector("fieldset[data-switch-target='show']", visible: :hidden) do |fieldset|
              expect(fieldset).to have_unchecked_field("Superviseur", visible: :hidden)
            end
          end
        end
      end
    end

    it "renders fields to with assigned offices when user's organization is a DDFIP" do
      render_inline described_class.new(office_user.user, namespace: :admin, organization: ddfip)

      expect(page).to have_selector(".choices-collection") do |form_block|
        ddfip.offices.each do |office|
          office_user = user.office_users.find { |office_user| office_user.office_id == office.id }
          checked = !office_user.nil?
          visibility = office_user ? :visible : :hidden

          if office_user
            expect(form_block).to have_selector("input[id^='user_office_users_attributes_'][value='#{office_user.id}']", visible: :hidden)
          else
            expect(form_block).to have_selector("input[id^='user_office_users_attributes_']", visible: :hidden)
          end
          expect(form_block).to have_selector("input[id^='user_office_users_attributes_'][value='#{office.id}']", visible: :hidden)

          expect(form_block).to have_selector("[id$='_office_id'][value='#{office.id}'] + [data-controller='switch']") do |switch|
            expect(switch).to have_field(office.name, checked:)
            expect(switch).to have_selector("fieldset[data-switch-target='show']", visible: visibility) do |fieldset|
              expect(fieldset).to have_field("Superviseur", visible: visibility)
            end
          end
        end
      end
    end

    it "renders no fields when organization is not a DDFIP" do
      collectivity = build_stubbed(:collectivity)
      render_inline described_class.new(User.new, namespace: :admin, organization: collectivity)

      expect(page).to have_no_selector(".choices-collection")
    end
  end

  context "with organization scope and logged in as a publisher admin" do
    before { sign_in_as(:publisher, :organization_admin) }

    it "renders no fields" do
      render_inline described_class.new(User.new, namespace: :organization)

      expect(page).to have_no_selector(".choices-collection")
    end
  end

  context "with organization scope and logged in as a collectivity admin" do
    before { sign_in_as(:collectivity, :organization_admin) }

    it "renders no fields" do
      render_inline described_class.new(User.new, namespace: :organization)

      expect(page).to have_no_selector(".choices-collection")
    end
  end

  context "with organization scope and logged in as a DDFIP admin" do
    before { sign_in_as(:ddfip, :organization_admin, organization: ddfip) }

    it "renders fields to assign offices to a new user" do
      render_inline described_class.new(User.new, namespace: :organization)

      expect(page).to have_selector(".choices-collection") do |form_block|
        ddfip.offices.order(:name).each_with_index do |office, index|
          expect(form_block).to have_selector("input#user_office_users_attributes_#{index}_id", visible: :hidden)
          expect(form_block).to have_selector("input#user_office_users_attributes_#{index}_office_id[value='#{office.id}']", visible: :hidden)

          expect(form_block).to have_selector("#user_office_users_attributes_#{index}_office_id + [data-controller='switch']") do |switch|
            expect(switch).to have_unchecked_field(office.name)
            expect(switch).to have_selector("fieldset[data-switch-target='show']", visible: :hidden) do |fieldset|
              expect(fieldset).to have_unchecked_field("Superviseur", visible: :hidden)
            end
          end
        end
      end
    end

    it "renders fields to assign office to an existing user" do
      render_inline described_class.new(office_user.user, namespace: :organization)

      expect(page).to have_selector(".choices-collection") do |form_block|
        ddfip.offices.each do |office|
          office_user = user.office_users.find { |office_user| office_user.office_id == office.id }
          checked = !office_user.nil?
          visibility = office_user ? :visible : :hidden

          if office_user
            expect(form_block).to have_selector("input[id^='user_office_users_attributes_'][value='#{office_user.id}']", visible: :hidden)
          else
            expect(form_block).to have_selector("input[id^='user_office_users_attributes_']", visible: :hidden)
          end
          expect(form_block).to have_selector("input[id^='user_office_users_attributes_'][value='#{office.id}']", visible: :hidden)

          expect(form_block).to have_selector("[id$='_office_id'][value='#{office.id}'] + [data-controller='switch']") do |switch|
            expect(switch).to have_field(office.name, checked:)
            expect(switch).to have_selector("fieldset[data-switch-target='show']", visible: visibility) do |fieldset|
              expect(fieldset).to have_field("Superviseur", visible: visibility)
            end
          end
        end
      end
    end
  end

  context "with organization scope and logged in as a DDFIP supervisor" do
    before { sign_in_as(:ddfip, :supervisor, organization: ddfip) }

    it "renders fields to assign offices to a new user" do
      render_inline described_class.new(User.new, namespace: :organization)

      expect(page).to have_selector(".choices-collection") do |form_block|
        ddfip.offices.order(:name).each do |office|
          disabled = !current_user.office_users.find { |office_user| office_user.office_id == office.id && office_user.supervisor }

          expect(form_block).to have_selector("input[id$='_office_id'][value='#{office.id}']", visible: :hidden)

          expect(form_block).to have_selector("[id$='_office_id'][value='#{office.id}'] + [data-controller='switch']") do |switch|
            expect(switch).to have_unchecked_field(office.name, disabled:)
            expect(switch).to have_selector("fieldset[data-switch-target='show']", visible: :hidden) do |fieldset|
              expect(fieldset).to have_unchecked_field("Superviseur", visible: :hidden, disabled:)
            end
          end
        end
      end
    end

    it "renders fields to assign office to an existing user" do
      render_inline described_class.new(office_user.user, namespace: :organization)

      expect(page).to have_selector(".choices-collection") do |form_block|
        ddfip.offices.each do |office|
          office_user = user.office_users.find { |office_user| office_user.office_id == office.id }
          checked = !office_user.nil?
          disabled = !current_user.office_users.find { |current_user_office_user| current_user_office_user.office_id == office.id && current_user_office_user.supervisor }
          visibility = office_user ? :visible : :hidden

          if office_user
            expect(form_block).to have_selector("input[id^='user_office_users_attributes_'][value='#{office_user.id}']", visible: :hidden)
          else
            expect(form_block).to have_selector("input[id^='user_office_users_attributes_']", visible: :hidden)
          end
          expect(form_block).to have_selector("input[id^='user_office_users_attributes_'][value='#{office.id}']", visible: :hidden)

          expect(form_block).to have_selector("[id$='_office_id'][value='#{office.id}'] + [data-controller='switch']") do |switch|
            expect(switch).to have_field(office.name, checked:, disabled:)
            expect(switch).to have_selector("fieldset[data-switch-target='show']", visible: visibility) do |fieldset|
              expect(fieldset).to have_field("Superviseur", visible: visibility, disabled:)
            end
          end
        end
      end
    end
  end
end
