# frozen_string_literal: true

require "rails_helper"

RSpec.describe TemplateStatus::Component, type: :component do
  it "renders a status template within a card" do
    render_inline described_class.new do
      tag.p "Hello World"
    end

    expect(page).to have_selector("main.content > turbo-frame > .card > .card__content > .card__body") do |node|
      expect(node).to have_selector("p", text: "Hello World")
    end
  end

  it "renders a status template with header and body" do
    render_inline described_class.new do |template|
      template.with_header do
        "Card title"
      end

      template.with_body do
        tag.p "Hello World"
      end
    end

    aggregate_failures do
      expect(page).to have_selector(".card > .card__content > .card__header") do |node|
        expect(node).to have_selector("h1.card__title", text: "Card title")
      end

      expect(page).to have_selector(".card > .card__content > .card__body") do |node|
        expect(node).to have_selector("p", text: "Hello World")
      end
    end
  end

  it "renders a status template with header and body passed as arguments" do
    render_inline described_class.new do |template|
      template.with_header("Card title")
      template.with_body("Hello World")
    end

    aggregate_failures do
      expect(page).to have_selector(".card > .card__content > .card__header") do |node|
        expect(node).to have_selector("h1.card__title", text: "Card title")
      end

      expect(page).to have_selector(".card > .card__content > .card__body") do |node|
        expect(node).to have_text("Hello World")
      end
    end
  end

  it "renders a status template with actions" do
    render_inline described_class.new do |card|
      card.with_body("Hello World")
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

  it "renders a modal instead of a card when requested" do
    with_variant :modal do
      render_inline described_class.new(referrer: "/background/path") do |card|
        card.with_breadcrumbs do |breadcrumbs|
          breadcrumbs.with_path("Root path")
        end

        card.with_body("Hello World")
        card.with_action("Action 1", primary: true)
        card.with_action("Action 2", href: "/some/path")
      end
    end

    expect(page).not_to have_selector(".card")
    expect(page).not_to have_selector(".breadcrumbs")

    expect(page).to have_selector("main.content > turbo-frame[src='/background/path']")

    expect(page).to have_selector(".modal > .modal__content > .modal__actions") do |node|
      aggregate_failures do
        expect(node).to have_button("Action 1", class: "button--primary")
        expect(node).to have_link("Action 2", class: "button", href: "/some/path")
      end
    end
  end

  it "renders a custom breadcrumbs" do
    render_inline described_class.new do |card|
      card.with_breadcrumbs do |breadcrumbs|
        breadcrumbs.with_path("Root path")
      end

      card.with_body("Hello World")
    end

    expect(page).to have_selector(".header-bar > .breadcrumbs") do |node|
      aggregate_failures do
        expect(node).to     have_selector(".breadcrumbs__path", count: 2)
        expect(node).not_to have_selector("h1")

        expect(node).to have_selector(".breadcrumbs__path:nth-child(1) > a.icon-button", text: "Retour à la page d'accueil")
        expect(node).to have_selector(".breadcrumbs__separator:nth-child(2)", text: "/")
        expect(node).to have_selector(".breadcrumbs__path:nth-child(3)", text: "Root path")
      end
    end
  end

  it "doesn't render any breadcrumbs by default" do
    render_inline described_class.new do
      tag.p "Hello World"
    end

    expect(page).not_to have_selector(".breadcrumbs")
  end

  it "doesn't render breadcrumbs when a modal is requested" do
    with_variant :modal do
      render_inline described_class.new do
        tag.p "Hello World"
      end
    end

    expect(page).not_to have_selector(".breadcrumbs")
  end
end
