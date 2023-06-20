# frozen_string_literal: true

require "rails_helper"

RSpec.describe Card::Component, type: :component do
  it "renders a basic card" do
    render_inline described_class.new do
      tag.p "Hello World"
    end

    expect(page).to have_selector(".card")
    expect(page).to have_selector(".card > .card__content > .card__body") do |node|
      expect(node).to have_selector("p", text: "Hello World")
    end
  end

  it "renders a card with header and body" do
    render_inline described_class.new do |card|
      card.with_header do
        "Dialog title"
      end

      card.with_body do
        tag.p "Hello World"
      end
    end

    aggregate_failures do
      expect(page).to have_selector(".card > .card__content > .card__header") do |node|
        expect(node).to have_selector("h1.card__title", text: "Dialog title")
      end

      expect(page).to have_selector(".card > .card__content > .card__body") do |node|
        expect(node).to have_selector("p", text: "Hello World")
      end
    end
  end

  it "renders card header from an argument" do
    render_inline described_class.new do |card|
      card.with_header("Dialog title")
      card.with_body do
        tag.p "Hello World"
      end
    end

    expect(page).to have_selector(".card > .card__content > .card__header") do |node|
      expect(node).to have_selector("h1.card__title", text: "Dialog title")
    end
  end

  it "renders card body from an argument" do
    render_inline described_class.new do |card|
      card.with_body("Hello World")
    end

    expect(page).to have_selector(".card > .card__content > .card__body") do |node|
      expect(node).to have_text("Hello World")
    end
  end

  it "renders a card with actions" do
    render_inline described_class.new do |card|
      card.with_body do
        tag.p "Hello World"
      end

      card.with_action("Action 1", primary: true)
      card.with_action("Action 2", href: "/some/path")
    end

    expect(page).to have_selector(".card > .card__content > .card__actions") do |node|
      aggregate_failures do
        expect(node).to have_button("Action 1", class: "button--primary")
        expect(node).to have_link("Action 2", class: "button", href: "/some/path")
      end
    end
  end

  it "add custom classes on card elements" do
    render_inline described_class.new(
      class:         "card-wrapper",
      content_class: "card__content--status",
      body_class:    "card__body--grid",
      actions_class: "card__actions--center"
    ) do |card|
      card.with_header("Dialog title")
      card.with_body("Hello World")
      card.with_action("Action")
    end

    expect(page).to have_selector(".card.card-wrapper") do |node|
      expect(node).to have_selector(".card__content.card__content--status") do |content|
        expect(content).to have_selector(".card__body.card__body--grid")
        expect(content).to have_selector(".card__actions.card__actions--center")
      end
    end
  end
end
