# frozen_string_literal: true

require "rails_helper"

RSpec.describe UI::Table::Component do
  let(:array_of_data) do
    [
      { id: 1, column_a: "Cell 1.A", column_b: "Cell 1.B", number1: 27,    number2: 294 },
      { id: 2, column_a: "Cell 2.A", column_b: "Cell 2.B", number1: 4_326, number2: 3572 },
      { id: 3, column_a: "Cell 3.A", column_b: "Cell 3.B", number1: 0,     number2: nil }
    ]
  end

  it "renders a table" do
    render_inline described_class.new(array_of_data) do |table|
      table.with_column(:id)
      table.with_column(:column_a)
      table.with_column(:number1)

      table.each_row do |row|
        row.with_column(:id)
        row.with_column(:column_a)
        row.with_column(:number1)
      end
    end

    expect(page).to have_selector(".table__wrapper table") do |table|
      expect(table).to have_selector("thead tr th", text: "Id")
      expect(table).to have_selector("thead tr th", text: "Column a")
      expect(table).to have_selector("thead tr th", text: "Number1")

      expect(table).to have_selector("tbody tr:first-child td:first-child",  text: "1")
      expect(table).to have_selector("tbody tr:first-child td:nth-child(2)", text: "Cell 1.A")
      expect(table).to have_selector("tbody tr:first-child td:nth-child(3)", text: "27")

      expect(table).to have_selector("tbody tr:nth-child(2) td:first-child",  text: "2")
      expect(table).to have_selector("tbody tr:nth-child(2) td:nth-child(2)", text: "Cell 2.A")
      expect(table).to have_selector("tbody tr:nth-child(2) td:nth-child(3)", text: "4326")
    end
  end

  it "renders a table with contents" do
    render_inline described_class.new(array_of_data) do |table|
      table.with_column(:id)       { "#" }
      table.with_column(:column_a) { "Title" }
      table.with_column(:amount)   { "Amount" }

      table.each_row do |row, datum|
        row.with_column(:id) { "##{datum[:id]}" }
        row.with_column(:column_a)
        row.with_column(:amount) do
          "#{datum[:number2]} $" if datum[:number1]&.positive?
        end
      end
    end

    expect(page).to have_selector(".table__wrapper table") do |table|
      expect(table).to have_selector("thead tr th", text: "#")
      expect(table).to have_selector("thead tr th", text: "Title")
      expect(table).to have_selector("thead tr th", text: "Amount")

      expect(table).to have_selector("tbody tr:first-child td:first-child",  text: "#1")
      expect(table).to have_selector("tbody tr:first-child td:nth-child(2)", text: "Cell 1.A")
      expect(table).to have_selector("tbody tr:first-child td:nth-child(3)", text: "294 $")

      expect(table).to have_selector("tbody tr:nth-child(2) td:first-child",  text: "#2")
      expect(table).to have_selector("tbody tr:nth-child(2) td:nth-child(2)", text: "Cell 2.A")
      expect(table).to have_selector("tbody tr:nth-child(2) td:nth-child(3)", text: "3572 $")

      expect(table).to have_selector("tbody tr:nth-child(3) td:nth-child(3):empty")
    end
  end

  it "renders a proper table even when some rows missed some columns" do
    render_inline described_class.new(array_of_data) do |table|
      table.with_column(:id)       { "ID" }
      table.with_column(:column_a) { "Title" }

      table.each_row.with_index do |(row, _datum), index|
        if index.zero?
          row.with_column(:id)
        else
          row.with_column(:column_a)
        end
      end
    end

    expect(page).to have_selector(".table__wrapper table") do |table|
      expect(table).to have_selector("thead tr th", count: 2)
      expect(table).to have_selector("thead tr th", text: "ID")
      expect(table).to have_selector("thead tr th", text: "Title")

      expect(table).to have_selector("tbody tr:first-child td", count: 2)
      expect(table).to have_selector("tbody tr:first-child td:first-child", text: "1")
      expect(table).to have_selector("tbody tr:first-child td:nth-child(2):empty")

      expect(table).to have_selector("tbody tr:nth-child(2) td", count: 2)
      expect(table).to have_selector("tbody tr:nth-child(2) td:first-child:empty")
      expect(table).to have_selector("tbody tr:nth-child(2) td:nth-child(2)", text: "Cell 2.A")
    end
  end

  it "ignores row column missing from top definitions" do
    render_inline described_class.new(array_of_data) do |table|
      table.with_column(:column_a) { "Title" }

      table.each_row do |row|
        row.with_column(:column_a)
        row.with_column(:number1)
      end
    end

    expect(page).to have_selector(".table__wrapper table") do |table|
      expect(table).to have_selector("thead tr th", count: 1)
      expect(table).to have_selector("thead tr th", text: "Title")

      expect(table).to have_selector("tbody tr:first-child td", count: 1)
      expect(table).to have_selector("tbody tr:first-child td", text: "Cell 1.A")
    end
  end

  it "renders a table with a compact column" do
    render_inline described_class.new(array_of_data) do |table|
      table.with_column(:id, compact: true)
      table.with_column(:column_a)

      table.each_row do |row|
        row.with_column(:id)
        row.with_column(:column_a)
      end
    end

    expect(page).to have_selector(".table__wrapper table") do |table|
      expect(table).to have_selector("thead tr th.table__cell--compact", text: "Id")
      expect(table).to have_selector("thead tr th:not(.table__cell--compact)", text: "Column a")

      expect(table).to have_selector("tbody tr:first-child td.table__cell--compact", text: "1")
      expect(table).to have_selector("tbody tr:first-child td:not(.table__cell--compact)", text: "Cell 1.A")
    end
  end

  it "renders a table with a right column" do
    render_inline described_class.new(array_of_data) do |table|
      table.with_column(:column_a)
      table.with_column(:number1, right: true)

      table.each_row do |row|
        row.with_column(:column_a)
        row.with_column(:number1)
      end
    end

    expect(page).to have_selector(".table__wrapper table") do |table|
      expect(table).to have_selector("thead tr th.table__cell--right", text: "Number1")
      expect(table).to have_selector("thead tr th:not(.table__cell--right)", text: "Column a")

      expect(table).to have_selector("tbody tr:first-child td.table__cell--right", text: "27")
      expect(table).to have_selector("tbody tr:first-child td:not(.table__cell--right)", text: "Cell 1.A")
    end
  end

  it "renders a table with irregular columns" do
    render_inline described_class.new(array_of_data) do |table|
      table.with_column(:title, span: 2)                { "Title" }
      table.with_column(:column_b)                      { "Subtitle" }
      table.with_column(:numbers, right: true, span: 2) { "Numbers" }

      table.each_row do |row, datum|
        row.with_column(:title) do |column|
          column.with_span { "##{datum[:id]}" }
          column.with_span { datum[:column_a] }
        end

        row.with_column(:column_b)

        row.with_column(:numbers) do |column|
          if datum[:number1]&.positive?
            column.with_span { datum[:number1].to_s }
            column.with_span { datum[:number2].to_s }
          end
        end
      end
    end

    expect(page).to have_selector(".table__wrapper table") do |table|
      expect(table).to have_selector("colgroup col:first-child[span=2]")
      expect(table).to have_selector("colgroup col:nth-child(2):not([span])")
      expect(table).to have_selector("colgroup col:nth-child(3)[span=2]")

      expect(table).to have_selector("thead tr th", count: 3)
      expect(table).to have_selector("thead tr th:first-child[colspan=2]",      text: "Title")
      expect(table).to have_selector("thead tr th:nth-child(2):not([colspan])", text: "Subtitle")
      expect(table).to have_selector("thead tr th:nth-child(3)[colspan=2]",     text: "Numbers")

      expect(table).to have_selector("tbody tr:first-child td", count: 5)
      expect(table).to have_selector("tbody tr:first-child td:first-child.table__cell--compact",        text: "#1")
      expect(table).to have_selector("tbody tr:first-child td:nth-child(2):not(.table__cell--compact)", text: "Cell 1.A")
      expect(table).to have_selector("tbody tr:first-child td:nth-child(3)",                            text: "Cell 1.B")
      expect(table).to have_selector("tbody tr:first-child td:nth-child(4).table__cell--right",         text: "27")
      expect(table).to have_selector("tbody tr:first-child td:nth-child(5).table__cell--right",         text: "294")

      expect(table).to have_selector("tbody tr:last-child td", count: 4)
      expect(table).to have_selector("tbody tr:last-child td:first-child.table__cell--compact",        text: "#3")
      expect(table).to have_selector("tbody tr:last-child td:nth-child(2):not(.table__cell--compact)", text: "Cell 3.A")
      expect(table).to have_selector("tbody tr:last-child td:nth-child(3)",                            text: "Cell 3.B")
      expect(table).to have_selector("tbody tr:last-child td:nth-child(4)[colspan=2]:empty")
    end
  end

  it "renders checkboxes" do
    render_inline described_class.new(array_of_data) do |table|
      table.with_column(:column_a)

      table.each_row do |row, datum|
        row.with_checkbox(value: datum[:id])
        row.with_column(:column_a)
      end
    end

    expect(page).to have_selector(".table__wrapper table") do |table|
      expect(table).to have_selector("thead tr th:first-child input[type='checkbox']") do |input|
        expect(input).to have_html_attribute("aria-label").with_value("Tout sélectionner")
      end

      expect(table).to have_selector("tbody tr td:first-child input[type='checkbox']") do |input|
        expect(input).to have_html_attribute("aria-label").with_value("Sélectionner cette ligne")
        expect(input).to have_html_attribute("value").with_value("1")
      end
    end
  end

  it "renders accessible checkboxes" do
    render_inline described_class.new(array_of_data) do |table|
      table.with_column(:column_a)

      table.each_row do |row, datum|
        row.with_checkbox("Sélectionner la ligne ##{datum[:id]}", described_by: :column_a, value: datum[:id])
        row.with_column(:column_a)
      end
    end

    expect(page).to have_selector(".table__wrapper table tbody tr") do |row|
      expect(row).to have_selector("td:first-child input") do |input|
        expect(input).to have_html_attribute("aria-label").with_value("Sélectionner la ligne #1")
        expect(input).to have_html_attribute("aria-describedby")

        expect(row).to have_selector(id: input["aria-describedby"], text: "Cell 1.A")
      end
    end
  end

  it "renders checkboxes column for each row even when missed one" do
    render_inline described_class.new(array_of_data) do |table|
      table.with_column(:column_a)

      table.each_row.with_index do |(row, datum), index|
        row.with_checkbox(value: datum[:id]) unless index.zero?
        row.with_column(:column_a)
      end
    end

    expect(page).to have_selector(".table__wrapper table") do |table|
      expect(table).to have_selector("tbody tr:first-child td:first-child:empty")
      expect(table).to have_selector("tbody tr:first-child td:nth-child(2)", text: "Cell 1.A")

      expect(table).to have_selector("tbody tr:nth-child(2) td:first-child input[type=checkbox]")
      expect(table).to have_selector("tbody tr:nth-child(2) td:nth-child(2)", text: "Cell 2.A")
    end
  end

  it "renders actions" do
    render_inline described_class.new(array_of_data) do |table|
      table.with_column(:column_a)

      table.each_row do |row, datum|
        row.with_action("Modifier cette ligne", "/data/#{datum[:id]}/edit", icon: "pencil-square")
        row.with_column(:column_a)
      end
    end

    expect(page).to have_selector(".table__wrapper table") do |table|
      expect(table).to have_selector("thead tr th:first-child.table__actions[aria-label='Actions']")

      expect(table).to have_selector("tbody tr td:first-child.table__actions") do |td|
        expect(td).to have_link("Modifier cette ligne", href: "/data/1/edit")
      end
    end
  end

  it "renders a table with records" do
    communes = create_list(:commune, 2).sort_by(&:code_insee)
    relation = Commune.order(:code_insee)

    render_inline described_class.new(relation) do |table|
      table.with_column(:code) { "Code INSEE" }
      table.with_column(:name) { "Commune" }

      table.each_row do |row, record|
        row.with_column(:code) { record.code_insee }
        row.with_column(:name)
      end
    end

    expect(page).to have_selector(".table__wrapper table") do |table|
      expect(table).to have_selector("thead tr th", text: "Code INSEE")
      expect(table).to have_selector("thead tr th", text: "Commune")

      expect(table).to have_selector("tbody tr:first-child td", text: communes[0].code_insee)
      expect(table).to have_selector("tbody tr:first-child td", text: communes[0].name)

      expect(table).to have_selector("tbody tr:last-child td", text: communes[1].code_insee)
      expect(table).to have_selector("tbody tr:last-child td", text: communes[1].name)
    end
  end

  it "renders checkboxes with records IDs as values" do
    communes = create_list(:commune, 2).sort_by(&:code_insee)
    relation = Commune.order(:code_insee)

    render_inline described_class.new(relation) do |table|
      table.with_column(:code) { "Code INSEE" }
      table.with_column(:name) { "Commune" }

      table.each_row do |row, record|
        row.with_checkbox
        row.with_column(:code) { record.code_insee }
        row.with_column(:name)
      end
    end

    expect(page).to have_selector(".table__wrapper table") do |table|
      expect(table).to have_selector("tbody tr td:first-child input[type='checkbox']") do |input|
        expect(input).to have_html_attribute("value").with_value(communes[0].id)
      end
    end
  end

  it "warns about not being able to set ARIA on checkboxes linked to irregular columns" do
    allow(Rails.logger).to receive(:warn).and_call_original

    render_inline described_class.new(array_of_data) do |table|
      table.with_column(:column_a, span: 2)

      table.each_row do |row, datum|
        row.with_checkbox(value: datum[:id], described_by: :column_a)
        row.with_column(:column_a) do |column|
          column.with_span { "##{datum[:id]}" }
          column.with_span { datum[:column_a] }
        end
      end
    end

    expect(Rails.logger).to have_received(:warn).exactly(3).times.with(<<~MESSAGE.strip)
      the column :column_a in :described_by cannot be applied because of multiple spans
    MESSAGE

    expect(page).to have_selector(".table__wrapper tbody td:first-child input") do |input|
      expect(input).to have_no_html_attribute("aria-describedby")
    end
  end

  it "renders ARIA link on checkboxes linked to irregular columns" do
    render_inline described_class.new(array_of_data) do |table|
      table.with_column(:column_a, span: 2)

      table.each_row do |row, datum|
        row.with_checkbox(value: datum[:id], aria: { describedby: "column_a_#{datum[:id]}" })
        row.with_column(:column_a) do |column|
          column.with_span { "##{datum[:id]}" }
          column.with_span(id: "column_a_#{datum[:id]}") do
            datum[:column_a]
          end
        end
      end
    end

    expect(page).to have_selector(".table__wrapper table tbody tr") do |row|
      expect(row).to have_selector("input[aria-describedby=column_a_1]")
      expect(row).to have_selector("td#column_a_1", text: "Cell 1.A")
    end
  end
end
