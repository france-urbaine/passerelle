# frozen_string_literal: true

require "rails_helper"

RSpec.describe UI::NotificationComponent, type: :component do
  subject(:component) { described_class.new }

  it "renders a notification" do
    render_inline described_class.new do
      "Hello world !"
    end

    expect(page).to have_selector(".notification") do |alert|
      expect(alert).to have_html_attribute("role").with_value("log")
      expect(alert).to have_html_attribute("aria-live").with_value("polite")

      expect(alert).to have_selector(".notification__header", text: "Hello world !")
      expect(alert).to have_selector("svg[aria-hidden]") do |svg|
        expect(svg).to have_html_attribute("data-source").with_value("heroicons/optimized/24/outline/information-circle.svg")
      end
    end
  end

  it "renders a notification with header & body" do
    render_inline described_class.new do |notification|
      notification.with_header do
        "Hello world !"
      end

      notification.with_body do
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
      end
    end

    expect(page).to have_selector(".notification") do |alert|
      expect(alert).to have_selector(".notification__header", text: "Hello world !")
      expect(alert).to have_selector(".notification__body",   text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
    end
  end

  it "renders a notification with 'success' scheme" do
    render_inline described_class.new(:success) do
      "Hello world !"
    end

    expect(page).to have_selector(".notification") do |alert|
      expect(alert).to have_html_attribute("class").with_value("notification notification--success")

      expect(alert).to have_selector("svg[aria-hidden]") do |svg|
        expect(svg).to have_html_attribute("data-source").with_value("heroicons/optimized/24/outline/check-circle.svg")
      end
    end
  end

  it "renders a notification with 'warning' scheme" do
    render_inline described_class.new(:warning) do
      "Hello world !"
    end

    expect(page).to have_selector(".notification") do |alert|
      expect(alert).to have_html_attribute("class").with_value("notification notification--warning")

      expect(alert).to have_selector("svg[aria-hidden]") do |svg|
        expect(svg).to have_html_attribute("data-source").with_value("heroicons/optimized/24/outline/exclamation-triangle.svg")
      end
    end
  end

  it "renders a notification with 'danger' scheme" do
    render_inline described_class.new(:danger) do
      "Hello world !"
    end

    expect(page).to have_selector(".notification") do |alert|
      expect(alert).to have_html_attribute("class").with_value("notification notification--danger")

      expect(alert).to have_selector("svg[aria-hidden]") do |svg|
        expect(svg).to have_html_attribute("data-source").with_value("heroicons/optimized/24/outline/exclamation-triangle.svg")
      end
    end
  end

  it "renders a notification with 'done' scheme" do
    render_inline described_class.new(:done) do
      "Hello world !"
    end

    expect(page).to have_selector(".notification") do |alert|
      expect(alert).to have_html_attribute("class").with_value("notification notification--done")

      expect(alert).to have_selector("svg[aria-hidden]") do |svg|
        expect(svg).to have_html_attribute("data-source").with_value("heroicons/optimized/24/outline/check-circle.svg")
      end
    end
  end

  it "renders a notification with a link" do
    render_inline described_class.new do |notification|
      notification.with_header { "Hello world !" }
      notification.with_action "En savoir plus", "/some/path"
    end

    expect(page).to have_selector(".notification") do |alert|
      expect(alert).to have_selector(".notification__header", text: "Hello world !")
      expect(alert).to have_selector(".notification__actions") do |actions|
        expect(actions).to have_link("En savoir plus") do |link|
          expect(link["href"]).to eq("/some/path")
          expect(link["class"]).to include("button")
        end
      end
    end
  end

  it "renders a notification with one action with method and params" do
    render_inline described_class.new do |notification|
      notification.with_header { "Hello world !" }
      notification.with_action "Continuer", "/some/path", method: :patch, params: { ids: "all" }
    end

    expect(page).to have_selector(".notification") do |alert|
      expect(alert).to have_selector(".notification__header", text: "Hello world !")
      expect(alert).to have_selector(".notification__actions") do |actions|
        expect(actions).to have_selector("form") do |form|
          expect(form["method"]).to eq("post")
          expect(form["action"]).to eq("/some/path")

          expect(form).to have_selector("input[type='hidden'][name='_method'][value='patch']", visible: :hidden)
          expect(form).to have_selector("input[type='hidden'][name='ids'][value='all']", visible: :hidden)
          expect(form).to have_button("Continuer")
        end
      end
    end
  end

  it "raises an exception on unexpected scheme" do
    expect {
      render_inline described_class.new(:what)
    }.to raise_exception(ArgumentError, "unexpected scheme: :what")
  end
end
