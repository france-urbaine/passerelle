# frozen_string_literal: true

require "rails_helper"

RSpec.describe Badge::Component, type: :component do
  it "renders a badge" do
    render_inline described_class.new("Hello World")

    expect(page).to have_selector(".badge", text: "Hello World")
  end

  it "renders a badge with a pre-compiled color" do
    render_inline described_class.new("Hello World", :yellow)

    expect(page).to have_selector(".badge.badge--yellow", text: "Hello World")
  end

  it "renders a badge with a custom color" do
    render_inline described_class.new("Hello World", class: "bagde--violet")

    expect(page).to have_selector(".badge.bagde--violet", text: "Hello World")
  end
end
