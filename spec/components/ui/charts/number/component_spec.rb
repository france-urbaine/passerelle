# frozen_string_literal: true

require "rails_helper"

RSpec.describe UI::Charts::Number::Component do
  it "renders the number" do
    render_inline described_class.new(1, "user")

    expect(page).to have_selector(".chart-number") do |div|
      expect(div).to have_text("1 user")
    end
  end

  it "pluralizes the word" do
    render_inline described_class.new(100, "user")

    expect(page).to have_selector(".chart-number") do |div|
      expect(div).to have_text("100 users")
    end
  end

  it "renders the number by formatting thousands" do
    render_inline described_class.new(3_569_303, "user")

    expect(page).to have_selector(".chart-number") do |div|
      expect(div).to have_text("3 569 303 users")
    end
  end

  it "uses the custom plural" do
    render_inline described_class.new(100, "user known", "users known")

    expect(page).to have_selector(".chart-number") do |div|
      expect(div).to have_text("100 users known")
    end
  end
end
