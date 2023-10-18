# frozen_string_literal: true

require "rails_helper"

RSpec.describe UI::NoscriptComponent, type: :component do
  it "wraps content in a noscript tag" do
    render_inline described_class.new do
      tag.p "Hello World"
    end

    expect(page).to have_selector("noscript") do |node|
      expect(node["id"]).to match(/^.{16}-noscript$/)
      expect(node).to have_selector("p", text: "Hello World")
    end

    id = page.find("noscript")["id"][/^.{16}/]

    expect(page).to have_selector("script##{id}-script", visible: :hidden) do |node|
      expect(node.text).to include(%{document.getElementById("#{id}-noscript").remove()})
      expect(node.text).to include(%{document.getElementById("#{id}-script").remove()})
    end
  end
end
