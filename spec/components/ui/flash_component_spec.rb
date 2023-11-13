# frozen_string_literal: true

require "rails_helper"

RSpec.describe UI::FlashComponent, type: :component do
  it "renders a flash message" do
    render_inline described_class.new do
      "Hello world !"
    end

    expect(page).to have_selector(".flash", text: "Hello world !")
  end

  it "renders a warning flash message" do
    render_inline described_class.new(:warning) do
      "Hello world !"
    end

    expect(page).to have_selector(".flash.flash--warning", text: "Hello world !")
  end

  it "renders a danger flash message" do
    render_inline described_class.new(:danger) do
      "Hello world !"
    end

    expect(page).to have_selector(".flash.flash--danger", text: "Hello world !")
  end

  it "renders a success flash message" do
    render_inline described_class.new(:success) do
      "Hello world !"
    end

    expect(page).to have_selector(".flash.flash--success", text: "Hello world !")
  end
end
