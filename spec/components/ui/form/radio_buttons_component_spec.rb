# frozen_string_literal: true

require "rails_helper"

RSpec.describe UI::Form::RadioButtonsComponent do
  it "renders checkboxes with a collection of records" do
    users = create_list(:user, 3)
    render_inline described_class.new(:user, :inviter_id, users)

    expect(page).to have_selector(".choices-collection") do |div|
      expect(div).to have_unchecked_field(users.first.name,  type: "radio", with: users.first.id)
      expect(div).to have_unchecked_field(users.second.name, type: "radio", with: users.second.id)
      expect(div).to have_unchecked_field(users.third.name,  type: "radio", with: users.third.id)
    end
  end

  it "renders checkboxes with a collection of records and custom properties" do
    users = create_list(:user, 3)
    render_inline described_class.new(:user, :inviter_id, users, value_method: :first_name, text_method: :first_name)

    expect(page).to have_selector(".choices-collection") do |div|
      expect(div).to have_unchecked_field(users.first.first_name,  with: users.first.first_name)
      expect(div).to have_unchecked_field(users.second.first_name, with: users.second.first_name)
      expect(div).to have_unchecked_field(users.third.first_name,  with: users.third.first_name)
    end
  end

  it "renders checkboxes with a collection of arrays" do
    users  = create_list(:user, 3)
    values = users.map { |o| [o.first_name, o.name] }

    render_inline described_class.new(:user, :inviter_id, values)

    expect(page).to have_selector(".choices-collection") do |div|
      expect(div).to have_unchecked_field(users.first.name,  with: users.first.first_name)
      expect(div).to have_unchecked_field(users.second.name, with: users.second.first_name)
      expect(div).to have_unchecked_field(users.third.name,  with: users.third.first_name)
    end
  end

  it "renders checkboxes with a collection of single values" do
    users  = create_list(:user, 3)
    values = users.map(&:name)

    render_inline described_class.new(:user, :inviter_id, values)

    expect(page).to have_selector(".choices-collection") do |div|
      expect(div).to have_unchecked_field(users.first.name,  with: users.first.name)
      expect(div).to have_unchecked_field(users.second.name, with: users.second.name)
      expect(div).to have_unchecked_field(users.third.name,  with: users.third.name)
    end
  end

  it "renders a radio button to reset the choice" do
    users = create_list(:user, 3)
    render_inline described_class.new(:user, :inviter_id, users, resettable: true)

    expect(page).to have_selector(".choices-collection") do |div|
      expect(div).to have_unchecked_field("Annuler l'option saisie", type: "radio") do |field|
        expect(field).to have_html_attribute("name").with_value("user[inviter_id]")
        expect(field).to have_html_attribute("id").with_value("user_inviter_id_reset")
      end

      expect(div).to have_selector("label", text: "Annuler l'option saisie") do |label|
        expect(label).to have_html_attribute("for").with_value("user_inviter_id_reset")
      end
    end
  end

  it "renders a radio button to reset the choice and a custom label" do
    users = create_list(:user, 3)
    render_inline described_class.new(:user, :inviter_id, users, resettable: "Reset value")

    expect(page).to have_selector(".choices-collection") do |div|
      expect(div).to have_unchecked_field("Reset value", type: "radio") do |field|
        expect(field).to have_html_attribute("name").with_value("user[inviter_id]")
        expect(field).to have_html_attribute("id").with_value("user_inviter_id_reset")
      end

      expect(div).to have_selector("label", text: "Reset value") do |label|
        expect(label).to have_html_attribute("for").with_value("user_inviter_id_reset")
      end
    end
  end
end
