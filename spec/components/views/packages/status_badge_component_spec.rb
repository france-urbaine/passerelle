# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Packages::StatusBadgeComponent, type: :component do
  it "renders a badge for transmitted package" do
    package = build_stubbed(:package)
    render_inline described_class.new(package)

    expect(page).to have_selector(".badge.badge--blue", text: "Paquet transmis, en attente de confirmation")
  end

  it "renders a badge for an assigned package" do
    package = build_stubbed(:package, :assigned)
    render_inline described_class.new(package)

    expect(page).to have_selector(".badge.badge--green", text: "Paquet assigné")
  end

  it "renders a badge for a returned package" do
    package = build_stubbed(:package, :returned)
    render_inline described_class.new(package)

    expect(page).to have_selector(".badge.badge--red", text: "Paquet retourné")
  end
end