# frozen_string_literal: true

require "rails_helper"

RSpec.describe UI::Form::ArrayField::Component do
  it "renders a array field" do
    render_inline described_class.new(:organization, :ip_ranges, ["127.0.0.1", "192.168.2.0/24"])

    expect(page).to have_selector("div[data-controller]") do |node|
      expect(node).to have_html_attribute("data-controller").with_value("array-field")

      expect(node).to have_field("organization[ip_ranges][]", count: 2)
      expect(node).to have_button("Supprimer", count: 2)

      expect(node).to have_field("organization[ip_ranges][]", with: "127.0.0.1") do |field|
        expect(field).to have_html_attribute("multiple").with_value("multiple")
      end

      expect(node).to have_field("organization[ip_ranges][]", with: "192.168.2.0/24") do |field|
        expect(field).to have_html_attribute("multiple").with_value("multiple")
      end

      expect(node).to have_button("Ajouter") do |button|
        expect(button).to have_html_attribute("data-action").with_value("array-field#addEmptyInput")
      end
    end
  end
end
