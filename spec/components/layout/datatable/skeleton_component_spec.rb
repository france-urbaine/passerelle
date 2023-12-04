# frozen_string_literal: true

require "rails_helper"

RSpec.describe Layout::Datatable::SkeletonComponent, type: :component do
  it "renders a table" do
    render_inline described_class.new

    expect(page).to have_selector(".datatable table") do |table|
      expect(table).to have_selector("thead tr th .text-skeleton-loader", count: 3)
      expect(table).to have_selector("tbody tr td .text-skeleton-loader", count: 15)
    end
  end

  it "renders a table with sizes of rows and columns" do
    render_inline described_class.new(rows: 5, columns: 5, nested: false)

    expect(page).to have_selector(".datatable table") do |table|
      expect(table).to have_selector("thead tr th .text-skeleton-loader", count: 5)
      expect(table).to have_selector("tbody tr td .text-skeleton-loader", count: 25)
    end
  end

  it "renders a table with column headers" do
    render_inline described_class.new(columns: %w[A B C])

    expect(page).to have_selector(".datatable table") do |table|
      expect(table).to have_selector("thead tr th .text-skeleton-loader", count: 3)
      expect(table).to have_selector("thead tr th .text-skeleton-loader", text: "A")
      expect(table).to have_selector("thead tr th .text-skeleton-loader", text: "B")
      expect(table).to have_selector("thead tr th .text-skeleton-loader", text: "C")
    end
  end

  it "caps the number of rows when nested" do
    render_inline described_class.new(rows: 15, nested: true)

    expect(page).to have_selector(".datatable table") do |table|
      expect(table).to have_selector("tbody tr", count: 10)
    end
  end

  it "renders a header bar" do
    render_inline described_class.new do |skeleton|
      skeleton.with_search
      skeleton.with_pagination
    end

    expect(page).to have_selector(".content__layout > .content__header") do |header|
      expect(header).to have_selector(".search .form-skeleton-loader input")
      expect(header).to have_selector(".content__header-actions .button-skeleton-loader", count: 2)
    end

    expect(page).to have_selector(".datatable table")
  end
end
