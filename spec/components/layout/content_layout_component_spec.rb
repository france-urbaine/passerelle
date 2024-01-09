# frozen_string_literal: true

require "rails_helper"

RSpec.describe Layout::ContentLayoutComponent, type: :component do
  it "renders content with headers & sections" do
    render_inline described_class.new do |layout|
      layout.with_header  { "Section title #1" }
      layout.with_section { "Section content #1" }
      layout.with_header  { "Section title #2" }
      layout.with_section { "Section content #2" }
      layout.with_section { "Section content #3" }
    end

    expect(page).to have_selector(".content__layout") do |layout|
      expect(layout).to have_selector(".content__header:nth-child(1)",  text: "Section title #1")
      expect(layout).to have_selector(".content__section:nth-child(2)", text: "Section content #1")
      expect(layout).to have_selector(".content__header:nth-child(3)",  text: "Section title #2")
      expect(layout).to have_selector(".content__section:nth-child(4)", text: "Section content #2")
      expect(layout).to have_selector(".content__section:nth-child(5)", text: "Section content #3")
    end
  end

  it "renders content without headers" do
    render_inline described_class.new do |layout|
      layout.with_section { "Section content #1" }
      layout.with_section { "Section content #2" }
      layout.with_section { "Section content #3" }
    end

    expect(page).to have_selector(".content__layout") do |layout|
      expect(layout).to have_selector(".content__section:nth-child(1)", text: "Section content #1")
      expect(layout).to have_selector(".content__section:nth-child(2)", text: "Section content #2")
      expect(layout).to have_selector(".content__section:nth-child(3)", text: "Section content #3")
    end
  end

  it "renders content an header with an icon" do
    render_inline described_class.new do |layout|
      layout.with_header icon: "server-stack" do
        "Section #1"
      end

      layout.with_section { "Section content" }
    end

    expect(page).to have_selector(".content__layout > .content__header > h2") do |h2|
      expect(h2).to have_text("Section #1")
      expect(h2).to have_selector("svg") do |svg|
        expect(svg).to have_html_attribute("data-source").with_value("heroicons/optimized/24/outline/server-stack.svg")
        expect(svg).to have_html_attribute("aria-hidden").boolean
      end
    end
  end

  it "renders content an header with icon options" do
    render_inline described_class.new do |layout|
      layout.with_header icon: "server-stack", icon_options: { variant: :solid } do
        "Section #1"
      end

      layout.with_section { "Section content" }
    end

    expect(page).to have_selector(".content__layout > .content__header > h2") do |h2|
      expect(h2).to have_text("Section #1")
      expect(h2).to have_selector("svg") do |svg|
        expect(svg).to have_html_attribute("data-source").with_value("heroicons/optimized/24/solid/server-stack.svg")
        expect(svg).to have_html_attribute("aria-hidden").boolean
      end
    end
  end

  it "renders content an header without title" do
    render_inline described_class.new do |layout|
      layout.with_header title: false do
        tag.div "Section #1"
      end
    end

    expect(page).to have_selector(".content__layout > .content__header") do |header|
      expect(header).to have_selector("div", text: "Section #1")
      expect(header).to have_no_selector("h2")
    end
  end

  it "renders content an header with actions" do
    render_inline described_class.new do |layout|
      layout.with_header do |header|
        header.with_action "Do something"
        header.with_action do
          tag.div("Hello world", class: "badge")
        end

        "Section #1"
      end

      layout.with_section { "Section content" }
    end

    expect(page).to have_selector(".content__layout > .content__header > .content__header-actions") do |actions|
      expect(actions).to have_button("Do something")
      expect(actions).to have_selector(".content__header-action > .badge", text: "Hello world")
    end
  end

  it "renders a grid in content layout" do
    render_inline described_class.new do |layout|
      layout.with_section { "Section content #1" }
      layout.with_grid do |grid|
        grid.with_column do |column|
          column.with_header  { "Section title #2" }
          column.with_section { "Section content #2" }
        end

        grid.with_column do |column|
          column.with_header  { "Section title #3" }
          column.with_section { "Section content #3" }
        end
      end
    end

    expect(page).to have_selector(".content__layout") do |layout|
      expect(layout).to have_selector(".content__section:nth-child(1)", text: "Section content #1")
      expect(layout).to have_selector(".content__grid:nth-child(2)") do |grid|
        expect(grid).to have_html_attribute("class").with_value("content__grid content__grid--cols-2")

        expect(grid).to have_selector(".content__grid-col:nth-child(1)") do |column|
          expect(column).to have_selector(".content__header:nth-child(1)", text: "Section title #2")
          expect(column).to have_selector(".content__section:nth-child(2)", text: "Section content #2")
        end

        expect(grid).to have_selector(".content__grid-col:nth-child(2)") do |column|
          expect(column).to have_selector(".content__header:nth-child(1)", text: "Section title #3")
          expect(column).to have_selector(".content__section:nth-child(2)", text: "Section content #3")
        end
      end
    end
  end

  it "raises an exception when building a grid with more than 2 columns but no CSS class" do
    expect {
      render_inline described_class.new do |layout|
        layout.with_grid do |grid|
          grid.with_column
          grid.with_column
          grid.with_column
        end
      end
    }.to raise_exception(ArgumentError, <<~MESSAGE)
      No default CSS class found for content layout grid with 3 columns.
      You must add it to `with_grid` :

      with_grid(class: "xl:grid-cols-3) do
        [...]
      end
    MESSAGE
  end

  it "renders a grid with more than 2 columns" do
    render_inline described_class.new do |layout|
      layout.with_grid(class: "xl:grid-cols-4 md:grid-cols-2") do |grid|
        grid.with_column
        grid.with_column
        grid.with_column
      end
    end

    expect(page).to have_selector(".content__layout > .content__grid") do |grid|
      expect(grid).to have_html_attribute("class").with_value("content__grid xl:grid-cols-4 md:grid-cols-2")
      expect(grid).to have_selector(".content__grid-col", count: 3)
    end
  end

  it "renders 1-section-layout without slots" do
    render_inline described_class.new do
      "Hello world"
    end

    expect(page).to have_selector(".content__layout") do |layout|
      expect(layout).to have_selector(".content__section:only-child", text: "Hello world")
    end
  end

  it "renders a grid with 1-section-layout per columns" do
    render_inline described_class.new do |layout|
      layout.with_grid do |grid|
        grid.with_column { "Column #1" }
        grid.with_column { "Column #2" }
      end
    end

    expect(page).to have_selector(".content__layout > .content__grid") do |grid|
      expect(grid).to have_selector(".content__grid-col:nth-child(1)") do |column|
        expect(column).to have_selector(".content__section:only-child", text: "Column #1")
      end

      expect(grid).to have_selector(".content__grid-col:nth-child(2)") do |column|
        expect(column).to have_selector(".content__section:only-child", text: "Column #2")
      end
    end
  end

  it "merges default & custom CSS classes" do
    render_inline described_class.new(class: "custom-layout") do |layout|
      layout.with_header(class: "custom-header")   { "Section title #1" }
      layout.with_section(class: "custom-section") { "Section content #1" }

      layout.with_grid(class: "custom-grid") do |grid|
        grid.with_column(class: "custom-column") do |column|
          column.with_header(class: "custom-column-header")
          column.with_section(class: "custom-column-section")
        end
      end
    end

    expect(page).to have_selector(".content__layout.custom-layout") do |layout|
      expect(layout).to have_selector(".content__header.custom-header")
      expect(layout).to have_selector(".content__section.custom-section")
      expect(layout).to have_selector(".content__grid.custom-grid") do |grid|
        expect(grid).to have_selector(".content__grid-col.custom-column") do |column|
          expect(column).to have_selector(".content__header.custom-column-header:not(.custom-header)")
          expect(column).to have_selector(".content__section.custom-column-section:not(.custom-section)")
        end
      end
    end
  end

  context "when wrapping a component with its own layout" do
    let!(:sample_component_class) do
      Class.new(ApplicationViewComponent) do
        def self.name
          "SampleComponent"
        end

        def call
          content_layout_component do |layout|
            layout.with_header { "Title from SampleComponent" }
            layout.with_section { card_component { "Section rendered from SampleComponent" } }
          end
        end
      end
    end

    it "wraps the component and renders its layout" do
      # Use #render_in_view_context to render 2 components
      render_in_view_context(
        described_class,
        sample_component_class
      ) do |a, b|
        render a.new do |layout|
          layout.with_section { "Not in a component" }
          layout.with_section { render(b.new) }
          layout.with_section { "Still not in a component" }
        end
      end

      expect(page).to have_selector(".content__layout") do |layout|
        expect(layout).to have_selector(".content__section:nth-child(1)", text: "Not in a component")
        expect(layout).to have_selector(".content__section:nth-child(2) > .content__layout") do |div|
          expect(div).to have_selector(".content__header:nth-child(1)", text: "Title from SampleComponent")
          expect(div).to have_selector(".content__section:nth-child(2)", text: "Section rendered from SampleComponent")
        end
        expect(layout).to have_selector(".content__section:nth-child(3)", text: "Still not in a component")
      end
    end

    it "wraps the component inside a grid and renders its layout" do
      render_in_view_context(
        described_class,
        sample_component_class
      ) do |a, b|
        render a.new do |layout|
          layout.with_grid do |grid|
            grid.with_column do |column|
              column.with_section { "Not in a component" }
              column.with_section { render b.new }
            end
            grid.with_column do
              render b.new
            end
          end
        end
      end

      expect(page).to have_selector(".content__layout > .content__grid") do |grid|
        expect(grid).to have_selector(".content__grid-col:nth-child(1)") do |column|
          expect(column).to have_selector(".content__section:nth-child(1)", text: "Not in a component")
          expect(column).to have_selector(".content__section:nth-child(2) > .content__layout") do |div|
            expect(div).to have_selector(".content__header:nth-child(1)", text: "Title from SampleComponent")
            expect(div).to have_selector(".content__section:nth-child(2)", text: "Section rendered from SampleComponent")
          end
        end

        expect(grid).to have_selector(".content__grid-col:nth-child(2)") do |column|
          expect(column).to have_selector(".content__section:nth-child(1) > .content__layout") do |div|
            expect(div).to have_selector(".content__header:nth-child(1)", text: "Title from SampleComponent")
            expect(div).to have_selector(".content__section:nth-child(2)", text: "Section rendered from SampleComponent")
          end
        end
      end
    end
  end
end
