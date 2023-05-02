# frozen_string_literal: true

require "rails_helper"

RSpec.describe Checkboxes::Component, type: :component do
  it "renders checkboxes within a Stimulus controller" do
    users = create_list(:user, 5)
    render_inline described_class.new(:office, :user_ids, users, :id, :name)

    expect(page).to have_selector(".checkboxes-collection[data-controller='selection']") do |div|
      aggregate_failures do
        expect(div).to have_unchecked_field("Tout sélectionner")
        expect(div).to have_unchecked_field(users.first.name)
        expect(div).to have_unchecked_field(users.second.name)
        expect(div).to have_unchecked_field(users.third.name)
      end
    end
  end

  it "doesn't render a checkall box with only 3 options" do
    users = create_list(:user, 3)
    render_inline described_class.new(:office, :user_ids, users, :id, :name)

    expect(page).to have_selector(".checkboxes-collection[data-controller='selection']") do |div|
      aggregate_failures do
        expect(div).not_to have_unchecked_field("Tout sélectionner")
        expect(div).to have_unchecked_field(users.first.name)
        expect(div).to have_unchecked_field(users.second.name)
        expect(div).to have_unchecked_field(users.third.name)
      end
    end
  end
end
