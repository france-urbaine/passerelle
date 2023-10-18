# frozen_string_literal: true

require "rails_helper"

RSpec.describe UI::Form::RadioButtonsComponent, type: :component do
  it "renders checkboxes with a collection of records" do
    users = create_list(:user, 3)
    render_inline described_class.new(:office, :user_ids, users)

    expect(page).to have_selector(".choices-collection") do |div|
      aggregate_failures do
        expect(div).to have_unchecked_field(users.first.name,  type: "radio", with: users.first.id)
        expect(div).to have_unchecked_field(users.second.name, type: "radio", with: users.second.id)
        expect(div).to have_unchecked_field(users.third.name,  type: "radio", with: users.third.id)
      end
    end
  end

  it "renders checkboxes with a collection of records and custom properties" do
    users = create_list(:user, 3)
    render_inline described_class.new(:office, :user_ids, users, value_method: :first_name, text_method: :first_name)

    expect(page).to have_selector(".choices-collection") do |div|
      aggregate_failures do
        expect(div).to have_unchecked_field(users.first.first_name,  with: users.first.first_name)
        expect(div).to have_unchecked_field(users.second.first_name, with: users.second.first_name)
        expect(div).to have_unchecked_field(users.third.first_name,  with: users.third.first_name)
      end
    end
  end

  it "renders checkboxes with a collection of arrays" do
    users  = create_list(:user, 3)
    values = users.map { |o| [o.first_name, o.name] }

    render_inline described_class.new(:office, :user_ids, values)

    expect(page).to have_selector(".choices-collection") do |div|
      aggregate_failures do
        expect(div).to have_unchecked_field(users.first.name,  with: users.first.first_name)
        expect(div).to have_unchecked_field(users.second.name, with: users.second.first_name)
        expect(div).to have_unchecked_field(users.third.name,  with: users.third.first_name)
      end
    end
  end

  it "renders checkboxes with a collection of single values" do
    users  = create_list(:user, 3)
    values = users.map(&:name)

    render_inline described_class.new(:office, :user_ids, values)

    expect(page).to have_selector(".choices-collection") do |div|
      aggregate_failures do
        expect(div).to have_unchecked_field(users.first.name,  with: users.first.name)
        expect(div).to have_unchecked_field(users.second.name, with: users.second.name)
        expect(div).to have_unchecked_field(users.third.name,  with: users.third.name)
      end
    end
  end

  it "renders a radio button to reset the choice" do
    users = create_list(:user, 3)
    render_inline described_class.new(:office, :user_ids, users, resettable: true)

    expect(page).to have_selector(".choices-collection") do |div|
      expect(div).to have_unchecked_field("Annuler l'option saisie", type: "radio")
    end
  end

  it "renders a radio button to reset the choice and a custom label" do
    users = create_list(:user, 3)
    render_inline described_class.new(:office, :user_ids, users, resettable: "Reset value")

    expect(page).to have_selector(".choices-collection") do |div|
      expect(div).to have_unchecked_field("Reset value", type: "radio")
    end
  end
end
