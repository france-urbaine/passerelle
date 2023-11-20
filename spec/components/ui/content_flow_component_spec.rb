# frozen_string_literal: true

require "rails_helper"

# TODO : more tests

RSpec.describe UI::ContentFlowComponent, type: :component do
  it "renders content with headers & sections" do
    render_inline described_class.new do |flow|
      flow.with_header  { "Section title #1" }
      flow.with_section { "Section content #1" }
      flow.with_header  { "Section title #2" }
      flow.with_section { "Section content #2" }
      flow.with_section { "Section content #3" }
    end

    expect(page).to have_selector(".content-flow") do |flow|
      expect(flow).to have_selector(".content__header:nth-child(1)",  text: "Section title #1")
      expect(flow).to have_selector(".content__section:nth-child(2)", text: "Section content #1")
      expect(flow).to have_selector(".content__separator:nth-child(3)")
      expect(flow).to have_selector(".content__header:nth-child(4)",  text: "Section title #2")
      expect(flow).to have_selector(".content__section:nth-child(5)", text: "Section content #2")
      expect(flow).to have_selector(".content__separator:nth-child(6)")
      expect(flow).to have_selector(".content__section:nth-child(7)", text: "Section content #3")
    end
  end

  it "renders content without headers" do
    render_inline described_class.new do |flow|
      flow.with_section { "Section content #1" }
      flow.with_section { "Section content #2" }
      flow.with_section { "Section content #3" }
    end

    expect(page).to have_selector(".content-flow") do |flow|
      expect(flow).to have_selector(".content__section:nth-child(1)", text: "Section content #1")
      expect(flow).to have_selector(".content__separator:nth-child(2)")
      expect(flow).to have_selector(".content__section:nth-child(3)", text: "Section content #2")
      expect(flow).to have_selector(".content__separator:nth-child(4)")
      expect(flow).to have_selector(".content__section:nth-child(5)", text: "Section content #3")
    end
  end

  it "renders content an header with title" do
    render_inline described_class.new do |flow|
      flow.with_header do |header|
        header.with_title "Section #1", "server-stack"
      end

      flow.with_section { "Section content" }
    end

    expect(page).to have_selector(".content-flow > .content__header > h2.content__header-title") do |h2|
      expect(h2).to have_selector("svg[data-source$='server-stack.svg']")
      expect(h2).to have_text("Section #1")
    end
  end

  it "renders content an header with actions" do
    render_inline described_class.new do |flow|
      flow.with_header do |header|
        header.with_title "Section #1", "server-stack"
        header.with_action "Do something"
        header.with_action do
          tag.div("Hello world", class: "badge")
        end
      end

      flow.with_section { "Section content" }
    end

    expect(page).to have_selector(".content-flow > .content__header > .content__header-actions") do |actions|
      expect(actions).to have_button("Do something")
      expect(actions).to have_selector(".content__header-action > .badge", text: "Hello world")
    end
  end
end
