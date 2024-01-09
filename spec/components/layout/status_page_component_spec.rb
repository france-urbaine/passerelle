# frozen_string_literal: true

require "rails_helper"

RSpec.describe Layout::StatusPageComponent, type: :component do
  it "renders a status template within a card" do
    render_inline described_class.new do
      tag.p "Hello World"
    end

    expect(page).to have_selector("main.content > turbo-frame > .content__layout > .content__section")
    expect(page).to have_selector(".content__section > .card > .card__content > .card__body")
    expect(page).to have_selector(".card__body > p", text: "Hello World")
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

    expect(page).to have_selector(".card > .card__content > .card__header") do |node|
      expect(node).to have_selector("h1.card__title", text: "Card title")
    end

    expect(page).to have_selector(".card > .card__content > .card__body") do |node|
      expect(node).to have_selector("p", text: "Hello World")
    end
  end

  it "renders a status template with header and body passed as arguments" do
    render_inline described_class.new do |template|
      template.with_header("Card title")
      template.with_body("Hello World")
    end

    expect(page).to have_selector(".card > .card__content > .card__header") do |node|
      expect(node).to have_selector("h1.card__title", text: "Card title")
    end

    expect(page).to have_selector(".card > .card__content > .card__body") do |node|
      expect(node).to have_text("Hello World")
    end
  end

  it "renders a status template with actions" do
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

    expect(page).to have_no_selector(".card")
    expect(page).to have_no_selector(".breadcrumbs")

    expect(page).to have_selector("main.content > turbo-frame[src='/background/path']")

    expect(page).to have_selector(".modal > .modal__content > .modal__actions") do |node|
      expect(node).to have_button("Action 1", class: "button--primary")
      expect(node).to have_link("Action 2", class: "button", href: "/some/path")
    end
  end

  it "renders a custom breadcrumbs when signed in" do
    sign_in

    render_inline described_class.new do |card|
      card.with_breadcrumbs do |breadcrumbs|
        breadcrumbs.with_path("Root path")
      end

      card.with_body("Hello World")
    end

    expect(page).to have_selector(".breadcrumbs > .breadcrumbs__path") do |node|
      expect(node).to have_selector(".breadcrumbs__path-item", count: 2)
      expect(node).to have_no_selector("h1")

      expect(node).to have_selector(".breadcrumbs__path-item:nth-child(1) > a.icon-button", text: "Retour à la page d'accueil")
      expect(node).to have_selector(".breadcrumbs__separator:nth-child(2)", text: "/")
      expect(node).to have_selector(".breadcrumbs__path-item:nth-child(3)", text: "Root path")
    end
  end

  it "doesn't render custom breadcrumbs when signed out" do
    render_inline described_class.new do |card|
      card.with_breadcrumbs do |breadcrumbs|
        breadcrumbs.with_path("Root path")
      end

      card.with_body("Hello World")
    end

    expect(page).to have_no_selector(".breadcrumbs")
  end

  it "doesn't render any breadcrumbs by default" do
    sign_in

    render_inline described_class.new do
      tag.p "Hello World"
    end

    expect(page).to have_no_selector(".breadcrumbs")
  end

  it "doesn't render breadcrumbs when a modal is requested" do
    sign_in

    with_variant :modal do
      render_inline described_class.new do
        tag.p "Hello World"
      end
    end

    expect(page).to have_no_selector(".breadcrumbs")
  end
end
