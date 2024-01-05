# frozen_string_literal: true

require "rails_helper"

RSpec.describe Layout::Pagination::Buttons::Component do
  it "renders two buttons to navigate to previous and next pages" do
    render_inline described_class.new(
      Pagy.new(count: 125, page: 3, items: 20)
    )

    expect(page).to have_selector(".icon-button", text: "Page précédente") do |button|
      expect(button).to have_html_attribute("href").with_value("/test/components?page=2")
      expect(button).to have_html_attribute("rel").with_value("prev")

      expect(button).to have_no_html_attribute("aria-hidden")
      expect(button).to have_no_html_attribute("disabled")
    end

    expect(page).to have_selector(".icon-button", text: "Page suivante") do |button|
      expect(button).to have_html_attribute("href").with_value("/test/components?page=4")
      expect(button).to have_html_attribute("rel").with_value("next")

      expect(button).to have_no_html_attribute("aria-hidden")
      expect(button).to have_no_html_attribute("disabled")
    end
  end

  it "renders an inactive previous button on first page" do
    render_inline described_class.new(
      Pagy.new(count: 125, page: 1, items: 20)
    )

    expect(page).to have_selector(".icon-button", text: "Page précédente") do |button|
      expect(button).to have_no_html_attribute("href")
      expect(button).to have_no_html_attribute("rel")

      expect(button).to have_html_attribute("aria-hidden").boolean
      expect(button).to have_html_attribute("disabled").boolean
    end

    expect(page).to have_selector(".icon-button", text: "Page suivante") do |button|
      expect(button).to have_html_attribute("href").with_value("/test/components?page=2")
      expect(button).to have_html_attribute("rel").with_value("next")

      expect(button).to have_no_html_attribute("aria-hidden")
      expect(button).to have_no_html_attribute("disabled")
    end
  end

  it "renders an inactive next button on last page" do
    render_inline described_class.new(
      Pagy.new(count: 125, page: 7, items: 20)
    )

    expect(page).to have_selector(".icon-button", text: "Page précédente") do |button|
      expect(button).to have_html_attribute("href").with_value("/test/components?page=6")
      expect(button).to have_html_attribute("rel").with_value("prev")

      expect(button).to have_no_html_attribute("aria-hidden")
      expect(button).to have_no_html_attribute("disabled")
    end

    expect(page).to have_selector(".icon-button", text: "Page suivante") do |button|
      expect(button).to have_no_html_attribute("href")
      expect(button).to have_no_html_attribute("rel")

      expect(button).to have_html_attribute("aria-hidden").boolean
      expect(button).to have_html_attribute("disabled").boolean
    end
  end

  it "renders two inactive buttons when there is only one page" do
    render_inline described_class.new(
      Pagy.new(count: 10, page: 1, items: 20)
    )

    expect(page).to have_selector(".icon-button", text: "Page précédente") do |button|
      expect(button).to have_no_html_attribute("href")
      expect(button).to have_no_html_attribute("rel")

      expect(button).to have_html_attribute("aria-hidden").boolean
      expect(button).to have_html_attribute("disabled").boolean
    end

    expect(page).to have_selector(".icon-button", text: "Page suivante") do |button|
      expect(button).to have_no_html_attribute("href")
      expect(button).to have_no_html_attribute("rel")

      expect(button).to have_html_attribute("aria-hidden").boolean
      expect(button).to have_html_attribute("disabled").boolean
    end
  end

  it "renders buttons and keep actual params" do
    with_request_url("/test/components?search=foo&order=-name") do
      render_inline described_class.new(
        Pagy.new(count: 125, page: 3, items: 20)
      )
    end

    expect(page).to have_link("Page précédente") do |link|
      expect(link).to have_html_attribute("href").with_value("/test/components?order=-name&page=2&search=foo")
    end

    expect(page).to have_link("Page suivante") do |link|
      expect(link).to have_html_attribute("href").with_value("/test/components?order=-name&page=4&search=foo")
    end
  end

  it "renders buttons targeting _top by default" do
    render_inline described_class.new(
      Pagy.new(count: 125, page: 3, items: 20)
    )

    expect(page).to have_selector(".icon-button", text: "Page précédente") do |button|
      expect(button).to have_html_attribute("data-turbo-frame").with_value("_top")
    end

    expect(page).to have_selector(".icon-button", text: "Page suivante") do |button|
      expect(button).to have_html_attribute("data-turbo-frame").with_value("_top")
    end
  end

  it "renders buttons targeting a turbo-frame" do
    render_inline described_class.new(
      Pagy.new(count: 125, page: 3, items: 20),
      turbo_frame: "content"
    )

    expect(page).to have_selector(".icon-button", text: "Page précédente") do |button|
      expect(button).to have_html_attribute("data-turbo-frame").with_value("content")
    end

    expect(page).to have_selector(".icon-button", text: "Page suivante") do |button|
      expect(button).to have_html_attribute("data-turbo-frame").with_value("content")
    end
  end
end
