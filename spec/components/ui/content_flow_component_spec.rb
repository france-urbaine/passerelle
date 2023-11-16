# frozen_string_literal: true

require "rails_helper"

# TODO : more tests

RSpec.describe UI::ContentFlowComponent, type: :component do
  it "renders a contenu flow with a section that has a header with parts" do
    render_inline described_class.new do |flow|
      flow.with_header do |header|
        header.with_title "Section#1", "server-stack"
        header.with_action "Do something"
      end

      flow.with_section do
        "Contenu section"
      end
    end

    expect(page).to have_selector(".content-flow") do |flow|
      expect(flow).not_to have_selector("div.content__separator")
    end

    expect(page).to have_selector(".content-flow > .header > .subheader-bar") do |header|
      expect(header).to have_selector("h2.subheader", text: "Section#1") do |subheader|
        expect(subheader).to have_selector("svg[data-source$='server-stack.svg']")
      end

      expect(header).to have_selector(".subheader-bar__parts") do |parts|
        expect(parts).to have_selector(".subheader-bar__part") do |part|
          expect(part).to have_button("Do something")
        end
      end
    end
  end

  it "renders a contenu flow with a section that has a header with a custom part" do
    render_inline described_class.new do |flow|
      flow.with_header do |header|
        header.with_custom(id: "custom-id", class: "custom-class", is: "turbo-frame")
      end
      flow.with_section do
        "Contenu section"
      end
    end

    expect(page).to have_selector(".content-flow > .header > .subheader-bar > .subheader-bar__parts") do |parts|
      expect(parts).to have_selector(".subheader-bar__part.custom-class")
      expect(parts).to have_selector(".subheader-bar__part[is='turbo-frame']")
      expect(parts).to have_selector("#custom-id")
    end
  end

  it "renders a contenu flow without header" do
    render_inline described_class.new do |flow|
      flow.with_section do
        "Section#1"
      end
    end

    expect(page).to have_selector(".content-flow") do |flow|
      expect(flow).not_to have_selector(".header")
    end
  end

  it "renders a contenu flow with 2 sections with a separator before the second" do
    render_inline described_class.new do |flow|
      flow.with_section # first section : should not have separator
      flow.with_section # second section : should have separator
    end

    expect(page).to have_selector(".content-flow") do |flow|
      expect(flow).to have_selector("div.content__separator")
    end
  end

  it "renders a contenu flow with 2 sections with no separator" do
    render_inline described_class.new do |flow|
      flow.with_section # first section : should not have separator
      flow.with_section separator: false # no separator
    end

    expect(page).to have_selector(".content-flow") do |flow|
      expect(flow).not_to have_selector("div.content__separator")
    end
  end
end
