# frozen_string_literal: true

require "rails_helper"

RSpec.describe UI::BadgeComponent, type: :component do
  it "renders a badge" do
    render_inline described_class.new("Hello World")

    expect(page).to have_selector(".badge", text: "Hello World")
  end

  it "renders a badge with `warning` scheme" do
    render_inline described_class.new("Hello World", :warning)

    expect(page).to have_selector(".badge.badge--warning", text: "Hello World")
  end

  it "renders a badge with `danger` scheme" do
    render_inline described_class.new("Hello World", :danger)

    expect(page).to have_selector(".badge.badge--danger", text: "Hello World")
  end

  it "renders a badge with `success` scheme" do
    render_inline described_class.new("Hello World", :success)

    expect(page).to have_selector(".badge.badge--success", text: "Hello World")
  end

  it "renders a badge with `done` scheme" do
    render_inline described_class.new("Hello World", :done)

    expect(page).to have_selector(".badge.badge--done", text: "Hello World")
  end

  it "raises an exception on unexpected scheme" do
    expect {
      render_inline described_class.new("Hello World", :what)
    }.to raise_exception(ArgumentError, "unexpected scheme: :what")
  end

  it "renders a badge with a custom attributes" do
    render_inline described_class.new("Hello World", class: "bagde--violet", is: "turbo-frame")

    expect(page).to have_selector(".badge", text: "Hello World") do |badge|
      expect(badge).to have_html_attribute(:class).with_value("badge bagde--violet")
      expect(badge).to have_html_attribute(:is).with_value("turbo-frame")
    end
  end
end
