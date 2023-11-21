# frozen_string_literal: true

require "rails_helper"

RSpec.describe UI::FlashComponent, type: :component do
  it "renders a flash message" do
    render_inline described_class.new do
      "Hello world !"
    end

    expect(page).to have_selector(".flash", text: "Hello world !")
  end

  it "renders a 'warning' flash message" do
    render_inline described_class.new(:warning) do
      "Hello world !"
    end

    expect(page).to have_selector(".flash.flash--warning", text: "Hello world !")
  end

  it "renders a 'danger' flash message" do
    render_inline described_class.new(:danger) do
      "Hello world !"
    end

    expect(page).to have_selector(".flash.flash--danger", text: "Hello world !")
  end

  it "renders a 'success' flash message" do
    render_inline described_class.new(:success) do
      "Hello world !"
    end

    expect(page).to have_selector(".flash.flash--success", text: "Hello world !")
  end

  it "renders a 'done' flash message" do
    render_inline described_class.new(:done) do
      "Hello world !"
    end

    expect(page).to have_selector(".flash.flash--done", text: "Hello world !")
  end

  it "raises an exception on unexpected scheme" do
    expect {
      render_inline described_class.new(:what) { "Hello World" }
    }.to raise_exception(ArgumentError, "unexpected scheme: :what")
  end

  it "renders a flash with custom attributes" do
    render_inline described_class.new(class: "custom_class", is: "turbo-frame") do
      "Hello World"
    end

    expect(page).to have_selector(".flash", text: "Hello World") do |flash|
      expect(flash).to have_html_attribute(:class).with_value("flash custom_class")
      expect(flash).to have_html_attribute(:is).with_value("turbo-frame")
    end
  end

  it "renders a flash with custom icon" do
    render_inline described_class.new(icon: "home", icon_options: { variant: :solid }) do
      "Hello World"
    end

    expect(page).to have_selector(".flash", text: "Hello World") do |flash|
      expect(flash).to have_selector("svg") do |svg|
        expect(svg).to have_html_attribute("data-source").with_value("heroicons/optimized/24/solid/home.svg")
      end
    end
  end
end
