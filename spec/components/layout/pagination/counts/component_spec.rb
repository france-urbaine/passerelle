# frozen_string_literal: true

require "rails_helper"

RSpec.describe Layout::Pagination::Counts::Component do
  it "renders counts with only one page" do
    render_inline described_class.new(
      Pagy.new(count: 10, page: 1, items: 20)
    )

    expect(page).to have_text("Page 1 sur 1")
  end

  it "renders counts with no resources" do
    render_inline described_class.new(
      Pagy.new(count: 0, page: 1, items: 20)
    )

    expect(page).to have_text("Page 1 sur 1")
  end

  it "renders counts with multiple pages" do
    render_inline described_class.new(
      Pagy.new(count: 125, page: 3, items: 20)
    )

    expect(page).to have_text("Page 3 sur 7")
  end

  it "renders models count with only one record" do
    render_inline described_class.new(
      Pagy.new(count: 1, page: 1, items: 20),
      Commune
    )

    expect(page).to have_text("1 commune | Page 1 sur 1")
  end

  it "renders models count with no resources" do
    render_inline described_class.new(
      Pagy.new(count: 0, page: 1, items: 20),
      Commune
    )

    expect(page).to have_text("0 commune | Page 1 sur 1")
  end

  it "renders models count with multiple resources" do
    render_inline described_class.new(
      Pagy.new(count: 1025, page: 3, items: 20),
      Commune
    )

    expect(page).to have_text("1 025 communes | Page 3 sur 52")
  end

  it "renders resources count when using a word" do
    render_inline described_class.new(
      Pagy.new(count: 1025, page: 3, items: 20),
      "établissement"
    )

    expect(page).to have_text("1 025 établissements | Page 3 sur 52")
  end

  it "renders resources count when using custom inflection" do
    render_inline described_class.new(
      Pagy.new(count: 1025, page: 3, items: 20),
      singular: "établissement publique",
      plural:   "établissements publiques"
    )

    expect(page).to have_text("1 025 établissements publiques | Page 3 sur 52")
  end
end
