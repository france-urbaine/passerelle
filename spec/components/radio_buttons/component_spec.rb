# frozen_string_literal: true

require "rails_helper"

RSpec.describe RadioButtons::Component, type: :component do
  it "renders radio buttons" do
    users = create_list(:user, 5)
    render_inline described_class.new(:office, :user_ids, users)

    expect(page).to have_selector(".choices-collection") do |div|
      aggregate_failures do
        expect(div).to have_unchecked_field(users.first.name)
        expect(div).to have_unchecked_field(users.second.name)
        expect(div).to have_unchecked_field(users.third.name)
      end
    end
  end

  it "renders a radio button to reset the choice" do
    users = create_list(:user, 5)
    render_inline described_class.new(:office, :user_ids, users, resettable: true)

    expect(page).to have_selector(".choices-collection") do |div|
      aggregate_failures do
        expect(div).to have_unchecked_field(users.first.name)
        expect(div).to have_unchecked_field(users.second.name)
        expect(div).to have_unchecked_field(users.third.name)
        expect(div).to have_unchecked_field("Annuler l'option saisie")
      end
    end
  end

  it "renders a radio button to reset the choice and a custom label" do
    users = create_list(:user, 5)
    render_inline described_class.new(:office, :user_ids, users, resettable: "Reset value")

    expect(page).to have_selector(".choices-collection") do |div|
      aggregate_failures do
        expect(div).to have_unchecked_field(users.first.name)
        expect(div).to have_unchecked_field(users.second.name)
        expect(div).to have_unchecked_field(users.third.name)
        expect(div).to have_unchecked_field("Reset value")
      end
    end
  end
end
