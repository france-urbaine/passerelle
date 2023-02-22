# frozen_string_literal: true

require "rails_helper"

RSpec.describe Layout::ModalFrameComponent, type: :component do
  it "renders component with block" do
    render_inline described_class.new do
      tag.p "Hello World"
    end

    expect(page).to have_selector("turbo-frame#modal") do |node|
      expect(node).to have_selector("p", text: "Hello World")
    end
  end

  it "renders component with [src] location" do
    render_inline described_class.new(src: "/communes")

    expect(page).to have_selector("turbo-frame#modal[src='/communes']")
  end
end
