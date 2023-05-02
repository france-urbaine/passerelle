# frozen_string_literal: true

require "rails_helper"

RSpec.describe Pagination::Buttons::Component, type: :component do
  around do |example|
    with_request_url("/communes") { example.run }
  end

  it "renders two buttons to navigate to previous and next pages" do
    render_inline described_class.new(
      Pagy.new(count: 125, page: 3, items: 20)
    )

    aggregate_failures do
      expect(page).to have_selector(".icon-button", text: "Page précédente") do |button|
        aggregate_failures do
          expect(button).to have_html_attribute("href").with_value("/communes?page=2")
          expect(button).to have_html_attribute("rel").with_value("prev")

          expect(button).not_to have_html_attribute("aria-hidden")
          expect(button).not_to have_html_attribute("disabled")
        end
      end

      expect(page).to have_selector(".icon-button", text: "Page suivante") do |button|
        aggregate_failures do
          expect(button).to have_html_attribute("href").with_value("/communes?page=4")
          expect(button).to have_html_attribute("rel").with_value("next")

          expect(button).not_to have_html_attribute("aria-hidden")
          expect(button).not_to have_html_attribute("disabled")
        end
      end
    end
  end

  it "renders an inactive previous button on first page" do
    render_inline described_class.new(
      Pagy.new(count: 125, page: 1, items: 20)
    )

    aggregate_failures do
      expect(page).to have_selector(".icon-button", text: "Page précédente") do |button|
        aggregate_failures do
          expect(button).not_to have_html_attribute("href")
          expect(button).not_to have_html_attribute("rel")

          expect(button).to have_html_attribute("aria-hidden").boolean
          expect(button).to have_html_attribute("disabled").boolean
        end
      end

      expect(page).to have_selector(".icon-button", text: "Page suivante") do |button|
        aggregate_failures do
          expect(button).to have_html_attribute("href").with_value("/communes?page=2")
          expect(button).to have_html_attribute("rel").with_value("next")

          expect(button).not_to have_html_attribute("aria-hidden")
          expect(button).not_to have_html_attribute("disabled")
        end
      end
    end
  end

  it "renders an inactive next button on last page" do
    render_inline described_class.new(
      Pagy.new(count: 125, page: 7, items: 20)
    )

    aggregate_failures do
      expect(page).to have_selector(".icon-button", text: "Page précédente") do |button|
        aggregate_failures do
          expect(button).to have_html_attribute("href").with_value("/communes?page=6")
          expect(button).to have_html_attribute("rel").with_value("prev")

          expect(button).not_to have_html_attribute("aria-hidden")
          expect(button).not_to have_html_attribute("disabled")
        end
      end

      expect(page).to have_selector(".icon-button", text: "Page suivante") do |button|
        aggregate_failures do
          expect(button).not_to have_html_attribute("href")
          expect(button).not_to have_html_attribute("rel")

          expect(button).to have_html_attribute("aria-hidden").boolean
          expect(button).to have_html_attribute("disabled").boolean
        end
      end
    end
  end

  it "renders two inactive buttons when there is only one page" do
    render_inline described_class.new(
      Pagy.new(count: 10, page: 1, items: 20)
    )

    aggregate_failures do
      expect(page).to have_selector(".icon-button", text: "Page précédente") do |button|
        aggregate_failures do
          expect(button).not_to have_html_attribute("href")
          expect(button).not_to have_html_attribute("rel")

          expect(button).to have_html_attribute("aria-hidden").boolean
          expect(button).to have_html_attribute("disabled").boolean
        end
      end

      expect(page).to have_selector(".icon-button", text: "Page suivante") do |button|
        aggregate_failures do
          expect(button).not_to have_html_attribute("href")
          expect(button).not_to have_html_attribute("rel")

          expect(button).to have_html_attribute("aria-hidden").boolean
          expect(button).to have_html_attribute("disabled").boolean
        end
      end
    end
  end

  it "renders buttons and keep actual params" do
    with_request_url("/communes?search=foo&order=-name") do
      render_inline described_class.new(
        Pagy.new(count: 125, page: 3, items: 20)
      )
    end

    aggregate_failures do
      expect(page).to have_link("Page précédente") do |link|
        expect(link).to have_html_attribute("href").with_value("/communes?order=-name&page=2&search=foo")
      end

      expect(page).to have_link("Page suivante") do |link|
        expect(link).to have_html_attribute("href").with_value("/communes?order=-name&page=4&search=foo")
      end
    end
  end

  it "renders buttons targeting _top by default" do
    render_inline described_class.new(
      Pagy.new(count: 125, page: 3, items: 20)
    )

    aggregate_failures do
      expect(page).to have_selector(".icon-button", text: "Page précédente") do |button|
        expect(button).to have_html_attribute("data-turbo-frame").with_value("_top")
      end

      expect(page).to have_selector(".icon-button", text: "Page suivante") do |button|
        expect(button).to have_html_attribute("data-turbo-frame").with_value("_top")
      end
    end
  end

  it "renders buttons targeting a turbo-frame" do
    render_inline described_class.new(
      Pagy.new(count: 125, page: 3, items: 20),
      turbo_frame: "content"
    )

    aggregate_failures do
      expect(page).to have_selector(".icon-button", text: "Page précédente") do |button|
        expect(button).to have_html_attribute("data-turbo-frame").with_value("content")
      end

      expect(page).to have_selector(".icon-button", text: "Page suivante") do |button|
        expect(button).to have_html_attribute("data-turbo-frame").with_value("content")
      end
    end
  end
end
