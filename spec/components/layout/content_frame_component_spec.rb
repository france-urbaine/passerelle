# frozen_string_literal: true

require "rails_helper"

RSpec.describe Layout::ContentFrameComponent, type: :component do
  it "renders main content" do
    render_inline described_class.new do
      tag.p "Hello World"
    end

    expect(page).to have_selector("main.content > turbo-frame") do |node|
      expect(node).to have_selector("p", text: "Hello World")
    end
  end

  it "renders main content with an asynchronous location" do
    render_inline described_class.new(src: "/communes")

    expect(page).to have_selector("main.content > turbo-frame[src='/communes']")
  end
end
