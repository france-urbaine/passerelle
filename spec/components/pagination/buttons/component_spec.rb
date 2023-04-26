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

    expect(page).to have_selector(".icon-button", text: "Page précédente") do |button|
      expect(button["aria-hidden"]).not_to be_present
      expect(button["disabled"]).not_to be_present
      expect(button["href"]).to eq("/communes?page=2")
      expect(button["rel"]).to eq("prev")
    end

    expect(page).to have_selector(".icon-button", text: "Page suivante") do |button|
      expect(button["aria-hidden"]).not_to be_present
      expect(button["disabled"]).not_to be_present
      expect(button["href"]).to eq("/communes?page=4")
      expect(button["rel"]).to eq("next")
    end
  end

  it "renders an inactive previous button on first page" do
    render_inline described_class.new(
      Pagy.new(count: 125, page: 1, items: 20)
    )

    expect(page).to have_selector(".icon-button", text: "Page précédente") do |button|
      expect(button["aria-hidden"]).to be_present
      expect(button["disabled"]).to be_present
      expect(button["href"]).not_to be_present
      expect(button["rel"]).not_to be_present
    end

    expect(page).to have_selector(".icon-button", text: "Page suivante") do |button|
      expect(button["aria-hidden"]).not_to be_present
      expect(button["disabled"]).not_to be_present
      expect(button["href"]).to eq("/communes?page=2")
      expect(button["rel"]).to eq("next")
    end
  end

  it "renders an inactive next button on last page" do
    render_inline described_class.new(
      Pagy.new(count: 125, page: 7, items: 20)
    )

    expect(page).to have_selector(".icon-button", text: "Page précédente") do |button|
      expect(button["aria-hidden"]).not_to be_present
      expect(button["disabled"]).not_to be_present
      expect(button["href"]).to eq("/communes?page=6")
      expect(button["rel"]).to eq("prev")
    end

    expect(page).to have_selector(".icon-button", text: "Page suivante") do |button|
      expect(button["aria-hidden"]).to be_present
      expect(button["disabled"]).to be_present
      expect(button["href"]).not_to be_present
      expect(button["rel"]).not_to be_present
    end
  end

  it "renders two inactive buttons when there is only one page" do
    render_inline described_class.new(
      Pagy.new(count: 10, page: 1, items: 20)
    )

    expect(page).to have_selector(".icon-button", text: "Page précédente") do |button|
      expect(button["aria-hidden"]).to be_present
      expect(button["disabled"]).to be_present
      expect(button["href"]).not_to be_present
      expect(button["rel"]).not_to be_present
    end

    expect(page).to have_selector(".icon-button", text: "Page suivante") do |button|
      expect(button["aria-hidden"]).to be_present
      expect(button["disabled"]).to be_present
      expect(button["href"]).not_to be_present
      expect(button["rel"]).not_to be_present
    end
  end

  it "renders buttons and keep actual params" do
    with_request_url("/communes?search=foo&order=-name") do
      render_inline described_class.new(
        Pagy.new(count: 125, page: 3, items: 20)
      )
    end

    expect(page).to have_link("Page précédente") do |link|
      expect(link["href"]).to eq("/communes?order=-name&page=2&search=foo")
    end

    expect(page).to have_link("Page suivante") do |link|
      expect(link["href"]).to eq("/communes?order=-name&page=4&search=foo")
    end
  end

  it "renders buttons targeting _top by default" do
    render_inline described_class.new(
      Pagy.new(count: 125, page: 3, items: 20)
    )

    expect(page).to have_selector(".icon-button", text: "Page précédente") do |button|
      expect(button["data-turbo-frame"]).to eq("_top")
    end

    expect(page).to have_selector(".icon-button", text: "Page suivante") do |button|
      expect(button["data-turbo-frame"]).to eq("_top")
    end
  end

  it "renders buttons targeting a turbo-frame" do
    render_inline described_class.new(
      Pagy.new(count: 125, page: 3, items: 20),
      turbo_frame: "content"
    )

    expect(page).to have_selector(".icon-button", text: "Page précédente") do |button|
      expect(button["data-turbo-frame"]).to eq("content")
    end

    expect(page).to have_selector(".icon-button", text: "Page suivante") do |button|
      expect(button["data-turbo-frame"]).to eq("content")
    end
  end
end
