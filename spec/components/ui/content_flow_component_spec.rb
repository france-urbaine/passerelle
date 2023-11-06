# frozen_string_literal: true

require "rails_helper"

# TODO : more tests

RSpec.describe UI::ContentFlowComponent, type: :component do
  it "renders a contenu flow with a section that has a header with actions" do
    render_inline described_class.new do |flow|
      flow.with_section do |section|
        section.with_header do |header|
          [
            "Section#1",
            header.with_action do
              UI::BadgeComponent.new("Pending", :yellow).call
            end
          ].join
        end
      end
    end

    expect(page).to have_selector(".content-flow > .section > .subheader-bar") do |header|
      expect(header).to have_selector("h2.subheader", text: "Section#1")
      expect(header).to have_selector(".subheader-bar__actions") do |actions|
        expect(actions).to have_selector(".subheader-bar__action") do |action|
          expect(action).to have_selector(".badge", text: "Pending")
        end
      end
    end
  end
end
