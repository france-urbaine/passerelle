# frozen_string_literal: true

require "rails_helper"

# TODO : more tests

RSpec.describe UI::ContentFlowComponent, type: :component do
  it "renders the contenu flow with an header, a section and an action" do
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

      expect(header).to have_selector(".subheader-bar__actions") do |actions|
        expect(actions).to have_selector(".subheader-bar__action") do |action|
          expect(action).to have_button("Do something")
        end
      end
    end
  end

  it "renders the contenu flow with a custom action" do
    render_inline described_class.new do |flow|
      flow.with_header do |header|
        header.with_action do
          tag.p "Hello world"
        end
      end

      flow.with_section do
        "Contenu section"
      end
    end

    expect(page).to have_selector(".content-flow > .header > .subheader-bar > .subheader-bar__actions") do |actions|
      expect(actions).to have_selector(".subheader-bar__action > p", text: "Hello world")
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
