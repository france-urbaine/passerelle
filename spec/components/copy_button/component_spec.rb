# frozen_string_literal: true

require "rails_helper"

RSpec.describe CopyButton::Component, type: :component do
  it "renders a button with an icon" do
    render_inline described_class.new("texte-a-copier")

    expect(page).to have_button(class: "copy-button icon-button") do |node|
      expect(node).to have_html_attribute("data-controller").with_value("copy-text toggle-class")
      expect(node).to have_html_attribute("data-copy-text-source-value").with_value("texte-a-copier")

      expect(node).to have_selector("span svg", count: 2)
      expect(node).to have_selector("span", class: "hidden", count: 1)
      expect(node).to have_selector("span", class: "tooltip", count: 1)
    end
  end
end
