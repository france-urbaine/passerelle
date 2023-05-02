# frozen_string_literal: true

require "rails_helper"

RSpec.describe Notification::Component, type: :component do
  subject(:component) { described_class.new }

  it "renders a notification" do
    render_inline described_class.new("Hello world !")

    expect(page).to have_selector(".notification[role='alert']") do |alert|
      aggregate_failures do
        expect(alert["aria-live"]).to eq("polite")

        expect(alert).to have_selector(".notification__title", text: "Hello world !")
        expect(alert).to have_selector("svg") do |svg|
          expect(svg).to have_selector("title", text: "Information")
        end
      end
    end
  end

  it "renders a notification with description" do
    render_inline described_class.new({
      title:       "Hello world !",
      description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
    })

    expect(page).to have_selector(".notification[role='alert']") do |alert|
      aggregate_failures do
        expect(alert).to have_selector(".notification__title", text: "Hello world !")
        expect(alert).to have_selector(".notification__message", text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
      end
    end
  end

  it "renders a successful notification" do
    render_inline described_class.new({
      type:  "success",
      title: "Hello world !"
    })

    expect(page).to have_selector(".notification[role='alert']") do |alert|
      expect(alert).to have_selector("svg.notification__icon--success") do |svg|
        expect(svg).to have_selector("title", text: "Succés")
      end
    end
  end

  it "renders an error notification" do
    render_inline described_class.new({
      type:  "error",
      title: "Hello world !"
    })

    expect(page).to have_selector(".notification[role='alert']") do |alert|
      expect(alert).to have_selector("svg.notification__icon--error") do |svg|
        expect(svg).to have_selector("title", text: "Erreur")
      end
    end
  end

  it "renders a notification with one link" do
    render_inline described_class.new({
      title:       "Hello world !",
      description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
    }, {
      label:  "En savoir plus",
      url:    "/some/path"
    })

    expect(page).to have_selector(".notification[role='alert']") do |alert|
      aggregate_failures do
        expect(alert).to have_selector(".notification__title", text: "Hello world !")
        expect(alert).to have_selector(".notification__message", text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
        expect(alert).to have_selector(".notification__actions") do |actions|
          expect(actions).to have_link("En savoir plus") do |link|
            aggregate_failures do
              expect(link["href"]).to eq("/some/path")
              expect(link["class"]).to include("button")
            end
          end
        end
      end
    end
  end

  it "renders a notification with one action with method and params" do
    render_inline described_class.new({
      title:       "Hello world !",
      description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
    }, {
      label:  "Continuer",
      url:    "/some/path",
      method: :patch,
      params: { ids: "all" }
    })

    expect(page).to have_selector(".notification[role='alert']") do |alert|
      aggregate_failures do
        expect(alert).to have_selector(".notification__title", text: "Hello world !")
        expect(alert).to have_selector(".notification__message", text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
        expect(alert).to have_selector(".notification__actions") do |actions|
          expect(actions).to have_selector("form") do |form|
            aggregate_failures do
              expect(form["method"]).to eq("post")
              expect(form["action"]).to eq("/some/path")

              expect(form).to have_selector("input[type='hidden'][name='_method'][value='patch']", visible: :hidden)
              expect(form).to have_selector("input[type='hidden'][name='ids'][value='all']", visible: :hidden)
              expect(form).to have_button("Continuer")
            end
          end
        end
      end
    end
  end

  it "raise an exception with an unexpected argument" do
    expect { described_class.new(:foo) }
      .to raise_exception(TypeError)
  end
end
