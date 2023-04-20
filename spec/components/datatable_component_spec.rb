# frozen_string_literal: true

require "rails_helper"

RSpec.describe DatatableComponent, type: :component do
  let(:records) { create_list(:commune, 2) }

  it "renders a table" do
    render_inline described_class.new(records) do |datatable|
      datatable.with_column(:code) { "Code INSEE" }
      datatable.with_column(:name) { "Commune" }

      datatable.each_row do |row, record|
        row.with_column(:code) { record.code_insee }
        row.with_column(:name) { record.name }
      end
    end

    expect(page).to have_table(class: "datatable") do |table|
      expect(table).to have_selector("thead tr th", text: "Code INSEE")
      expect(table).to have_selector("thead tr th", text: "Commune")

      expect(table).to have_selector("tbody tr:first-child td", text: records[0].code_insee)
      expect(table).to have_selector("tbody tr:first-child td", text: records[0].name)

      expect(table).to have_selector("tbody tr:last-child td", text: records[1].code_insee)
      expect(table).to have_selector("tbody tr:last-child td", text: records[1].name)
    end
  end

  it "renders a table with a compact column" do
    render_inline described_class.new(records) do |datatable|
      datatable.with_column(:code, compact: true) { "Code INSEE" }
      datatable.with_column(:name)                { "Commune" }

      datatable.each_row do |row, record|
        row.with_column(:code_insee) { record.code_insee }
        row.with_column(:name)       { record.name }
      end
    end

    expect(page).to have_table(class: "datatable") do |table|
      expect(table).to have_selector("thead tr th.w-px", text: "Code INSEE")
      expect(table).to have_selector("thead tr th", text: "Commune")
    end
  end

  it "renders a table with a numeric column" do
    render_inline described_class.new(records) do |datatable|
      datatable.with_column(:name)                  { "Commune" }
      datatable.with_column(:number, numeric: true) { "Total" }

      datatable.each_row do |row, record|
        row.with_column(:name)   { record.name }
        row.with_column(:number) { "3" }
      end
    end

    expect(page).to have_table(class: "datatable") do |table|
      expect(table).to have_selector("thead tr th",            text: "Commune")
      expect(table).to have_selector("thead tr th.text-right", text: "Total")

      expect(table).to have_selector("tbody tr:first-child td",            text: records[0].name)
      expect(table).to have_selector("tbody tr:first-child td.text-right", text: "3")
    end
  end

  it "renders a proper table even when column are missingin rows" do
    render_inline described_class.new(records) do |datatable|
      datatable.with_column(:code) { "Code INSEE" }
      datatable.with_column(:name) { "Commune" }

      datatable.each_row do |row, record|
        if record == records.first
          row.with_column(:name) { record.name }
        else
          row.with_column(:code) { record.code_insee }
        end
      end
    end

    expect(page).to have_table(class: "datatable") do |table|
      expect(table).to have_selector("thead tr th", text: "Code INSEE")
      expect(table).to have_selector("thead tr th", text: "Commune")

      expect(table).to have_selector("tbody tr:first-child td", count: 2)
      expect(table).to have_selector("tbody tr:first-child td:first-child", text: "")
      expect(table).to have_selector("tbody tr:first-child td:last-child", text: records[0].name)

      expect(table).to have_selector("tbody tr:last-child td", count: 2)
      expect(table).to have_selector("tbody tr:last-child td:first-child", text: records[1].code_insee)
      expect(table).to have_selector("tbody tr:last-child td:last-child", text: "")
    end
  end

  it "ignores row column missing from top definitions" do
    render_inline described_class.new(records) do |datatable|
      datatable.with_column(:name) { "Commune" }

      datatable.each_row do |row, record|
        row.with_column(:code) { record.code_insee }
        row.with_column(:name) { record.name }
      end
    end

    expect(page).to have_table(class: "datatable") do |table|
      expect(table).to have_selector("thead tr th", text: "Commune")

      expect(table).to have_selector("tbody tr:first-child td", count: 1)
      expect(table).to have_selector("tbody tr:first-child td", text: records[0].name)
      expect(table).not_to have_selector("tbody tr:first-child td", text: records[0].code_insee)
    end
  end

  it "renders checkboxes" do
    render_inline described_class.new(records) do |datatable|
      datatable.with_selection
      datatable.with_column(:name) { "Commune" }

      datatable.each_row do |row, record|
        row.with_selection
        row.with_column(:code) { record.code_insee }
        row.with_column(:name) { record.name }
      end
    end

    expect(page).to have_table(class: "datatable") do |table|
      expect(table).to have_selector("thead tr th:first-child") do |th|
        expect(th).to have_unchecked_field
        expect(th).to have_selector("input[aria-label='Tout sélectionner']")
      end

      expect(table).to have_selector("tbody tr td:first-child") do |td|
        expect(td).to have_unchecked_field
        expect(td).to have_selector("input[aria-label='Sélectionner cette ligne']")
      end
    end
  end

  it "renders accessible checkboxes" do
    render_inline described_class.new(records) do |datatable|
      datatable.with_selection "Sélectionner toutes les communes"
      datatable.with_column(:name) { "Commune" }

      datatable.each_row do |row, record|
        row.with_selection "Sélectionner cette commune", described_by: :name
        row.with_column(:name) { record.name }
      end
    end

    expect(page).to have_table(class: "datatable") do |table|
      expect(table).to have_selector("thead tr th:first-child") do |th|
        expect(th).to have_selector("input[aria-label='Sélectionner toutes les communes']")
        expect(th).to have_selector(".tooltip", text: "Sélectionner toutes les communes")
      end

      expect(table).to have_selector("tbody tr td:first-child") do |td|
        expect(td).to have_selector("input[aria-label='Sélectionner cette commune'][aria-describedby='name_commune_#{records[0].id}']")
        expect(td).to have_selector(".tooltip", text: "Sélectionner cette commune")
      end
    end
  end

  it "renders actions" do
    render_inline described_class.new(records) do |datatable|
      datatable.with_actions
      datatable.with_column(:name) { "Commune" }

      datatable.each_row do |row, record|
        row.with_action "Modifier cette commune", "/communes/123", icon: "pencil-square"
        row.with_column(:name) { record.name }
      end
    end

    expect(page).to have_table(class: "datatable") do |table|
      expect(table).to have_selector("tbody tr td:first-child") do |td|
        expect(td).to have_link("Modifier cette commune", href: "/communes/123")
      end
    end
  end

  it "renders actions using href option" do
    render_inline described_class.new(records) do |datatable|
      datatable.with_actions
      datatable.with_column(:name) { "Commune" }

      datatable.each_row do |row, record|
        row.with_action "Modifier cette commune", href: "/communes/123", icon: "pencil-square"
        row.with_column(:name) { record.name }
      end
    end

    expect(page).to have_table(class: "datatable") do |table|
      expect(table).to have_selector("tbody tr td:first-child") do |td|
        expect(td).to have_link("Modifier cette commune", href: "/communes/123")
      end
    end
  end

  it "renders a table with irregular columns" do
    render_inline described_class.new(records) do |datatable|
      datatable.with_column(:name, span: 2) { "Commune" }
      datatable.with_column(:epci, span: 2) { "EPCI" }
      datatable.with_column(:creation) { "Creation" }

      datatable.each_row do |row, commune|
        row.with_column(:name) do |column|
          column.with_span { commune.code_insee }
          column.with_span { commune.name }
        end
      end
    end

    expect(page).to have_table(class: "datatable") do |table|
      expect(table).to have_selector("colgroup col:first-child[span=2]")
      expect(table).to have_selector("colgroup col:nth-child(2)[span=2]")
      expect(table).to have_selector("colgroup col:nth-child(3):not([span])")

      expect(table).to have_selector("thead tr th:first-child[colspan=2]", text: "Commune")
      expect(table).to have_selector("thead tr th:nth-child(2)[colspan=2]", text: "EPCI")
      expect(table).to have_selector("thead tr th:nth-child(3):not([colspan])", text: "Creation")

      expect(table).to have_selector("tbody tr td:first-child", text: records[0].code_insee)
      expect(table).to have_selector("tbody tr td:nth-child(2)", text: records[0].name)
      expect(table).to have_selector("tbody tr td:nth-child(3)[colspan=2]", text: "")
      expect(table).to have_selector("tbody tr td:nth-child(4)", text: "")
    end
  end
end
