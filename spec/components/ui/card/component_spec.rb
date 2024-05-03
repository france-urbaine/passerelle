# frozen_string_literal: true

require "rails_helper"

RSpec.describe UI::Card::Component do
  it "renders a basic card with body" do
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
        "Card title"
      end

      card.with_body do
        tag.p "Hello World"
      end
    end

    expect(page).to have_selector(".card > .card__content > .card__header") do |node|
      expect(node).to have_selector("h1.card__title", text: "Card title")
    end

    expect(page).to have_selector(".card > .card__content > .card__body") do |node|
      expect(node).to have_selector("p", text: "Hello World")
    end
  end

  it "renders a card with header and body passed as arguments" do
    render_inline described_class.new do |card|
      card.with_header("Card title")
      card.with_body("Hello World")
    end

    expect(page).to have_selector(".card > .card__content > .card__header") do |node|
      expect(node).to have_selector("h1.card__title", text: "Card title")
    end

    expect(page).to have_selector(".card > .card__content > .card__body") do |node|
      expect(node).to have_text("Hello World")
    end
  end

  it "renders a card with actions" do
    render_inline described_class.new do |card|
      card.with_body("Hello World")
      card.with_action("Action 1", primary: true)
      card.with_action("Action 2", href: "/some/path")
    end

    expect(page).to have_selector(".card > .card__content > .card__actions") do |node|
      expect(node).to have_button("Action 1", class: "button--primary")
      expect(node).to have_link("Action 2", class: "button", href: "/some/path")
    end
  end

  it "adds custom HTML attributes" do
    render_inline described_class.new(
      class:  "custom-card",
      is:     "turbo-frame",
      id:     "card-123"
    ) do |card|
      card.with_header("Card title", class: "text-3xl")
      card.with_body("Hello World", class: "grid2")
      card.with_action("Action")
    end

    expect(page).to have_selector(".card.custom-card") do |node|
      expect(node).to have_html_attribute("is").with_value("turbo-frame")
      expect(node).to have_html_attribute("id").with_value("card-123")

      expect(node).to have_selector(".card__content") do |content|
        expect(content).to have_selector(".card__header.text-3xl")
        expect(content).to have_selector(".card__body.grid2")
      end
    end
  end

  it "renders a card with a form" do
    record = Commune.new
    render_inline described_class.new do |card|
      card.with_header("Card title")

      card.with_form(model: record, url: "/form/path") do |form|
        form.block(:name) do
          form.text_field(:name)
        end
      end

      card.with_submit_action("Save")
    end

    expect(page).to have_selector(".card > .card__content > form[action='/form/path']") do |form|
      expect(form).to have_selector(".card__header > h1.card__title", text: "Card title")
      expect(form).to have_selector(".card__body > .form-block > input[name='commune[name]']")
      expect(form).to have_selector(".card__actions") do |actions|
        expect(actions).to have_button("Save", type: "submit")
      end
    end
  end

  it "renders a card with a form and a custom scope" do
    record = Commune.new
    render_inline described_class.new do |card|
      card.with_header("Card title")

      card.with_form(model: record, scope: :foo, url: "/form/path") do |form|
        form.block(:name) do
          form.text_field(:name)
        end
      end
    end

    expect(page).to have_selector(".card > .card__content > form[action='/form/path']") do |form|
      expect(form).to have_selector(".card__body > .form-block > input[name='foo[name]']")
    end
  end

  it "renders a multipart card" do
    render_inline described_class.new do |card|
      card.with_multipart do |card_content|
        card_content.with_header do
          "Part 1 title"
        end

        card_content.with_body do
          tag.p "Part 1 body"
        end
      end

      card.with_multipart do |card_content|
        card_content.with_header do
          "Part 2 title"
        end

        card_content.with_body do
          tag.p "Part 2 body"
        end
      end
    end

    expect(page).to have_selector(".card > .card__content > .card__header", count: 2) do |node|
      expect(node).to have_selector("h1.card__title")
    end

    expect(page).to have_selector(".card > .card__content > .card__body", count: 2) do |node|
      expect(node).to have_selector("p")
    end
  end
end
