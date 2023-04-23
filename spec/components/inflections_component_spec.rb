# frozen_string_literal: true

require "rails_helper"

RSpec.describe InflectionsComponent, type: :component do
  it "inflects a word" do
    component = described_class.new("établissement")

    aggregate_failures do
      expect(component.singular).to eq("établissement")
      expect(component.plural).to eq("établissements")
    end
  end

  it "accepts irregular pluralization" do
    component = described_class.new(
      singular: "établissement publique",
      plural:   "établissements publiques"
    )

    aggregate_failures do
      expect(component.singular).to eq("établissement publique")
      expect(component.plural).to eq("établissements publiques")
    end
  end

  it "check the word is not feminine by default" do
    component = described_class.new("établissement")

    expect(component).not_to be_feminine
  end

  it "check the word is femininie" do
    component = described_class.new("commune", feminine: true)

    expect(component).to be_feminine
  end

  it "renders a formatted count with singular form" do
    component = described_class.new(
      singular: "établissement publique",
      plural:   "établissements publiques"
    )

    # Component must be rendered first
    render_inline(component)

    expect(component.count(1)).to have_text("1 établissement publique")
  end

  it "renders a formatted count with plural form" do
    component = described_class.new(
      singular: "établissement publique",
      plural:   "établissements publiques"
    )

    # Component must be rendered first
    render_inline(component)

    expect(component.count(10)).to have_text("10 établissements publiques")
  end
end
