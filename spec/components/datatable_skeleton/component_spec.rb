# frozen_string_literal: true

require "rails_helper"

RSpec.describe DatatableSkeleton::Component, type: :component do
  it "renders a table" do
    render_inline described_class.new

    expect(page).to have_table(class: "datatable") do |table|
      aggregate_failures do
        expect(table).to have_selector("thead tr th .text-skeleton-loader", count: 3)
        expect(table).to have_selector("tbody tr td .text-skeleton-loader", count: 15)
      end
    end
  end

  it "renders a table with sizes of rows and columns" do
    render_inline described_class.new(rows: 5, columns: 5)

    expect(page).to have_table(class: "datatable") do |table|
      aggregate_failures do
        expect(table).to have_selector("thead tr th .text-skeleton-loader", count: 5)
        expect(table).to have_selector("tbody tr td .text-skeleton-loader", count: 25)
      end
    end
  end

  it "renders a table with column headers" do
    render_inline described_class.new(columns: %w[A B C])

    expect(page).to have_table(class: "datatable") do |table|
      aggregate_failures do
        expect(table).to have_selector("thead tr th .text-skeleton-loader", count: 3)
        expect(table).to have_selector("thead tr th .text-skeleton-loader", text: "A")
        expect(table).to have_selector("thead tr th .text-skeleton-loader", text: "B")
        expect(table).to have_selector("thead tr th .text-skeleton-loader", text: "C")
      end
    end
  end

  it "renders a header bar" do
    render_inline described_class.new do |skeleton|
      skeleton.with_search
      skeleton.with_pagination
    end

    aggregate_failures do
      expect(page).to have_selector(".header-bar") do |header|
        expect(header).to have_selector(".search .form-skeleton-loader input")
        expect(header).to have_selector(".header-bar__actions .button-skeleton-loader", count: 2)
      end

      expect(page).to have_table(class: "datatable")
    end
  end
end
