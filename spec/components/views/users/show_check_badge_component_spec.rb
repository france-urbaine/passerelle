# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Users::ShowCheckBadgeComponent, type: :component do
  it "renders a check icon when user matches the attribute" do
    user = build_stubbed(:user, :organization_admin)
    render_inline described_class.new(user, :organization_admin)

    expect(page).to have_selector("svg") do |svg|
      expect(svg).to have_html_attribute("data-source", "heroicons/optimized/24/outline/check-badge.svg")
      expect(svg).to have_selector("title", text: "Administrateur de l'organisation")
    end
  end

  it "renders an empty string when user doesn't match the attribute" do
    user = build_stubbed(:user)
    doc  = render_inline described_class.new(user, :organization_admin)

    expect(doc.children.text).to eq(" ")
  end
end
