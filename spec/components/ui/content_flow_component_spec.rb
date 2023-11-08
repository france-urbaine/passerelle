# frozen_string_literal: true

require "rails_helper"

# TODO : more tests

RSpec.describe UI::ContentFlowComponent, type: :component do
  it "renders a contenu flow with a section that has a header with actions" do
    render_inline described_class.new do |flow|
      flow.with_header do |header|
        [
          "Section#1",
          header.with_action do
            UI::BadgeComponent.new("Pending", :yellow).call
          end
        ].join
      end
      flow.with_section
    end

    expect(page).to have_selector(".content-flow") do |flow|
      expect(flow).not_to have_selector("div.content__separator")
    end

    expect(page).to have_selector(".content-flow > .header > .subheader-bar") do |header|
      expect(header).to have_selector("h2.subheader", text: "Section#1")
      expect(header).to have_selector(".subheader-bar__actions") do |actions|
        expect(actions).to have_selector(".subheader-bar__action") do |action|
          expect(action).to have_selector(".badge", text: "Pending")
        end
      end
    end
  end

  it "renders a contenu flow with 2 sections with a separator before the second" do
    render_inline described_class.new do |flow|
      flow.with_section
      flow.with_section
    end

    expect(page).to have_selector(".content-flow") do |flow|
      expect(flow).to have_selector("div.content__separator")
    end
  end
end
