# frozen_string_literal: true

require "rails_helper"

RSpec.describe CopyableText::Component, type: :component do
  it "displays text to copy" do
    render_inline described_class.new("value-to-copy")

    expect(page).to have_selector(".copyable-text", text: "value-to-copy")
  end

  it "masks secret to copy" do
    render_inline described_class.new("value-to-copy", secret: true)

    expect(page).to have_selector(".copyable-text", text: "•••••••••••••")
  end

  it "renders a button to copy value" do
    render_inline described_class.new("value-to-copy")

    aggregate_failures do
      expect(page).to have_button(count: 1)
      expect(page).to have_button(class: "icon-button", text: "Copier le texte") do |button|
        aggregate_failures do
          expect(button).to have_html_attribute("data-controller").with_value("copy-text toggle")
          expect(button).to have_html_attribute("data-copy-text-source-value").with_value("value-to-copy")

          expect(button).to have_selector("svg", count: 1, visible: :visible)
          expect(button).to have_selector("svg", count: 1, visible: :hidden)
        end
      end
    end
  end

  it "renders the component with another button to show secret" do
    render_inline described_class.new("value-to-copy", secret: true)

    aggregate_failures do
      expect(page).to have_button(count: 2)
      expect(page).to have_button(class: "icon-button", text: "Révéler le texte") do |button|
        aggregate_failures do
          expect(button).to have_selector("svg", count: 1, visible: :visible)
          expect(button).to have_selector("svg", count: 1, visible: :hidden)
        end
      end
    end
  end
end
