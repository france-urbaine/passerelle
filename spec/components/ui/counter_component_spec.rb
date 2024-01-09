# frozen_string_literal: true

require "rails_helper"

RSpec.describe UI::CounterComponent, type: :component do
  it "renders a badge with a number" do
    render_inline described_class.new(9)

    expect(page).to have_selector(".counter-badge", text: "9")
  end

  it "renders a badge with a number superior to 100" do
    render_inline described_class.new(256)

    expect(page).to have_selector(".counter-badge", text: "99+")
  end

  it "doesn't render a badge with a zero number" do
    render_inline described_class.new(0)

    expect(page).to have_no_selector(".counter-badge")
  end
end
