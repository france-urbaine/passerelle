# frozen_string_literal: true

require "rails_helper"

RSpec.describe DataTable::Component, type: :component do
  around do |example|
    with_request_url("/communes") { example.run }
  end

  let!(:communes) { create_list(:commune, 2).sort_by(&:code_insee) }
  let!(:relation) { Commune.order(:code_insee) }

  it "renders a table" do
    render_inline described_class.new(relation) do |datatable|
      datatable.with_column(:code) { "Code INSEE" }
      datatable.with_column(:name) { "Commune" }

      datatable.each_row do |row, record|
        row.with_column(:code) { record.code_insee }
        row.with_column(:name) { record.name }
      end
    end

    expect(page).to have_table(class: "datatable") do |table|
      aggregate_failures do
        expect(table).to have_selector("thead tr th", text: "Code INSEE")
        expect(table).to have_selector("thead tr th", text: "Commune")

        expect(table).to have_selector("tbody tr:first-child td", text: communes[0].code_insee)
        expect(table).to have_selector("tbody tr:first-child td", text: communes[0].name)

        expect(table).to have_selector("tbody tr:last-child td", text: communes[1].code_insee)
        expect(table).to have_selector("tbody tr:last-child td", text: communes[1].name)
      end
    end
  end

  it "renders a table with a compact column" do
    render_inline described_class.new(relation) do |datatable|
      datatable.with_column(:code, compact: true) { "Code INSEE" }
      datatable.with_column(:name)                { "Commune" }

      datatable.each_row do |row, record|
        row.with_column(:code_insee) { record.code_insee }
        row.with_column(:name)       { record.name }
      end
    end

    expect(page).to have_table(class: "datatable") do |table|
      aggregate_failures do
        expect(table).to have_selector("thead tr th.w-px", text: "Code INSEE")
        expect(table).to have_selector("thead tr th", text: "Commune")
      end
    end
  end

  it "renders a table with a numeric column" do
    render_inline described_class.new(relation) do |datatable|
      datatable.with_column(:name)                  { "Commune" }
      datatable.with_column(:number, numeric: true) { "Total" }

      datatable.each_row do |row, record|
        row.with_column(:name)   { record.name }
        row.with_column(:number) { "3" }
      end
    end

    expect(page).to have_table(class: "datatable") do |table|
      aggregate_failures do
        expect(table).to have_selector("thead tr th",            text: "Commune")
        expect(table).to have_selector("thead tr th.text-right", text: "Total")

        expect(table).to have_selector("tbody tr:first-child td",            text: communes[0].name)
        expect(table).to have_selector("tbody tr:first-child td.text-right", text: "3")
      end
    end
  end

  it "renders a proper table even when some rows missed some columns" do
    render_inline described_class.new(relation) do |datatable|
      datatable.with_column(:code) { "Code INSEE" }
      datatable.with_column(:name) { "Commune" }

      datatable.each_row do |row, record|
        if record == communes.first
          row.with_column(:name) { record.name }
        else
          row.with_column(:code) { record.code_insee }
        end
      end
    end

    expect(page).to have_table(class: "datatable") do |table|
      aggregate_failures do
        expect(table).to have_selector("thead tr th", text: "Code INSEE")
        expect(table).to have_selector("thead tr th", text: "Commune")

        expect(table).to have_selector("tbody tr:first-child td", count: 2)
        expect(table).to have_selector("tbody tr:first-child td:first-child", text: "")
        expect(table).to have_selector("tbody tr:first-child td:last-child", text: communes[0].name)

        expect(table).to have_selector("tbody tr:last-child td", count: 2)
        expect(table).to have_selector("tbody tr:last-child td:first-child", text: communes[1].code_insee)
        expect(table).to have_selector("tbody tr:last-child td:last-child", text: "")
      end
    end
  end

  it "ignores row column missing from top definitions" do
    render_inline described_class.new(relation) do |datatable|
      datatable.with_column(:name) { "Commune" }

      datatable.each_row do |row, record|
        row.with_column(:code) { record.code_insee }
        row.with_column(:name) { record.name }
      end
    end

    expect(page).to have_table(class: "datatable") do |table|
      aggregate_failures do
        expect(table).to have_selector("thead tr th", text: "Commune")

        expect(table).to have_selector("tbody tr:first-child td", count: 1)
        expect(table).to have_selector("tbody tr:first-child td", text: communes[0].name)
        expect(table).not_to have_selector("tbody tr:first-child td", text: communes[0].code_insee)
      end
    end
  end

  it "renders checkboxes" do
    render_inline described_class.new(relation) do |datatable|
      datatable.with_column(:name) { "Commune" }

      datatable.each_row do |row, record|
        row.with_checkbox
        row.with_column(:code) { record.code_insee }
        row.with_column(:name) { record.name }
      end
    end

    expect(page).to have_table(class: "datatable") do |table|
      aggregate_failures do
        expect(table).to have_selector("thead tr th:first-child") do |th|
          aggregate_failures do
            expect(th).to have_unchecked_field
            expect(th).to have_selector("input[aria-label='Tout sélectionner']")
          end
        end

        expect(table).to have_selector("tbody tr td:first-child") do |td|
          aggregate_failures do
            expect(td).to have_unchecked_field
            expect(td).to have_selector("input[aria-label='Sélectionner cette ligne']")
          end
        end
      end
    end
  end

  it "renders accessible checkboxes" do
    render_inline described_class.new(relation) do |datatable|
      datatable.with_column(:name) { "Commune" }

      datatable.each_row do |row, record|
        row.with_checkbox "Sélectionner cette commune", described_by: :name
        row.with_column(:name) { record.name }
      end
    end

    expect(page).to have_table(class: "datatable") do |table|
      expect(table).to have_selector("tbody tr td:first-child") do |td|
        aggregate_failures do
          expect(td).to have_selector("input[aria-label='Sélectionner cette commune'][aria-describedby='name_commune_#{communes[0].id}']")
          expect(td).to have_selector(".tooltip", text: "Sélectionner cette commune")
        end
      end
    end
  end

  it "renders checkboxes column for each row even when missed one" do
    render_inline described_class.new(relation) do |datatable|
      datatable.with_column(:name) { "Commune" }

      datatable.each_row do |row, record|
        row.with_checkbox if record == communes.last
        row.with_column(:code) { record.code_insee }
        row.with_column(:name) { record.name }
      end
    end

    expect(page).to have_table(class: "datatable") do |table|
      aggregate_failures do
        expect(table).to have_selector("tbody tr:first-child td:first-child:empty")
        expect(table).to have_selector("tbody tr:last-child td:first-child") do |td|
          expect(td).to have_unchecked_field
        end
      end
    end
  end

  it "renders actions" do
    render_inline described_class.new(relation) do |datatable|
      datatable.with_column(:name) { "Commune" }

      datatable.each_row do |row, record|
        row.with_action "Modifier cette commune", "/communes/123", icon: "pencil-square"
        row.with_column(:name) { record.name }
      end
    end

    expect(page).to have_table(class: "datatable") do |table|
      aggregate_failures do
        expect(table).to have_selector("thead tr th:first-child[aria-label='Actions']")
        expect(table).to have_selector("tbody tr td:first-child") do |td|
          expect(td).to have_link("Modifier cette commune", href: "/communes/123")
        end
      end
    end
  end

  it "renders actions using href option" do
    render_inline described_class.new(relation) do |datatable|
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
    render_inline described_class.new(relation) do |datatable|
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
      aggregate_failures do
        expect(table).to have_selector("colgroup col:first-child[span=2]")
        expect(table).to have_selector("colgroup col:nth-child(2)[span=2]")
        expect(table).to have_selector("colgroup col:nth-child(3):not([span])")

        expect(table).to have_selector("thead tr th:first-child[colspan=2]", text: "Commune")
        expect(table).to have_selector("thead tr th:nth-child(2)[colspan=2]", text: "EPCI")
        expect(table).to have_selector("thead tr th:nth-child(3):not([colspan])", text: "Creation")

        expect(table).to have_selector("tbody tr td:first-child", text: communes[0].code_insee)
        expect(table).to have_selector("tbody tr td:nth-child(2)", text: communes[0].name)
        expect(table).to have_selector("tbody tr td:nth-child(3)[colspan=2]", text: "")
        expect(table).to have_selector("tbody tr td:nth-child(4)", text: "")
      end
    end
  end

  it "renders a table with order buttons in head row" do
    render_inline described_class.new(relation) do |datatable|
      datatable.with_column(:code, sort: true) { "Code INSEE" }
      datatable.with_column(:name, sort: true) { "Commune" }

      datatable.each_row do |row, record|
        row.with_column(:code) { record.code_insee }
        row.with_column(:name) { record.name }
      end
    end

    expect(page).to have_table(class: "datatable") do |table|
      aggregate_failures do
        expect(table).to have_selector("thead tr th:first-child", text: "Code INSEE") do |cell|
          expect(cell).to have_link("Trier par ordre croissant", href: "/communes?order=code")
          expect(cell).to have_selector("svg title", text: "Trier par ordre croissant")
        end

        expect(table).to have_selector("thead tr th:nth-child(2)", text: "Commune") do |cell|
          expect(cell).to have_link("Trier par ordre croissant", href: "/communes?order=name")
          expect(cell).to have_selector("svg title", text: "Trier par ordre croissant")
        end
      end
    end
  end

  it "renders a table with current order button" do
    with_request_url("/communes?order=name") do
      render_inline described_class.new(relation) do |datatable|
        datatable.with_column(:code, sort: true) { "Code INSEE" }
        datatable.with_column(:name, sort: true) { "Commune" }

        datatable.each_row do |row, record|
          row.with_column(:code) { record.code_insee }
          row.with_column(:name) { record.name }
        end
      end
    end

    expect(page).to have_table(class: "datatable") do |table|
      aggregate_failures do
        expect(table).to have_selector("thead tr th:first-child", text: "Code INSEE") do |cell|
          expect(cell).to have_link("Trier par ordre croissant", href: "/communes?order=code")
          expect(cell).to have_selector("svg title", text: "Trier par ordre croissant")
        end

        expect(table).to have_selector("thead tr th:nth-child(2)", text: "Commune") do |cell|
          expect(cell).to have_link("Trier par ordre décroissant", href: "/communes?order=-name")
          expect(cell).to have_selector("svg title", text: "Trier par ordre décroissant")
        end
      end
    end
  end
end
