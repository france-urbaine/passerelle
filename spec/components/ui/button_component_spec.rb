# frozen_string_literal: true

require "rails_helper"

RSpec.describe UI::ButtonComponent, type: :component do
  it "renders a button" do
    render_inline described_class.new("Click me!")

    expect(page).to have_button("Click me!", class: "button")
  end

  it "renders button with label from block" do
    render_inline described_class.new do
      "Click me!"
    end

    expect(page).to have_button("Click me!", class: "button")
  end

  it "renders a link" do
    render_inline described_class.new("Click me!", "/communes")

    expect(page).to have_link("Click me!", class: "button") do |button|
      expect(button).to have_html_attribute("href").with_value("/communes")
    end
  end

  it "renders a link using a block to capture the label" do
    render_inline described_class.new("/communes") do
      "Click me!"
    end

    expect(page).to have_link("Click me!", class: "button") do |button|
      expect(button).to have_html_attribute("href").with_value("/communes")
    end
  end

  it "renders a link using href option" do
    render_inline described_class.new("Click me!", href: "/communes")

    expect(page).to have_link("Click me!", class: "button") do |button|
      expect(button).to have_html_attribute("href").with_value("/communes")
    end
  end

  it "raises an exception when trying to pass a label from argument & block" do
    expect {
      render_inline described_class.new("Click me!", "/foo") do
        "Click me!"
      end
    }.to raise_exception(ArgumentError, "Label can be specified as an argument or in a block, not both.")
  end

  it "renders a link to open in a modal" do
    render_inline described_class.new("Click me!", "/communes", modal: true)

    expect(page).to have_link("Click me!", class: "button") do |button|
      aggregate_failures do
        expect(button).to have_html_attribute("href").with_value("/communes")
        expect(button).to have_html_attribute("data-turbo-frame").with_value("modal")
      end
    end
  end

  it "renders a primary button" do
    render_inline described_class.new("Click me!", primary: true)

    expect(page).to have_button("Click me!", class: "button--primary")
  end

  it "renders a primary but discrete button" do
    render_inline described_class.new("Click me!", primary: "discrete")

    expect(page).to have_button("Click me!", class: "button--primary-discrete")
  end

  it "renders an accentuated button" do
    render_inline described_class.new("Click me!", accent: true)

    expect(page).to have_button("Click me!", class: "button--accent")
  end

  it "renders an accentuated but discrete button" do
    render_inline described_class.new("Click me!", accent: "discrete")

    expect(page).to have_button("Click me!", class: "button--accent-discrete")
  end

  it "renders a destructive button" do
    render_inline described_class.new("Click me!", destructive: true)

    expect(page).to have_button("Click me!", class: "button--destructive")
  end

  it "renders a destructive but discrete button" do
    render_inline described_class.new("Click me!", destructive: "discrete")

    expect(page).to have_button("Click me!", class: "button--destructive-discrete")
  end

  it "renders a button with an icon" do
    render_inline described_class.new("Click me!", icon: "plus")

    expect(page).to have_button(class: "button") do |button|
      aggregate_failures do
        expect(button).to have_text("Click me!")
        expect(button).to have_selector("svg") do |svg|
          expect(svg).to have_html_attribute("data-source").with_value("heroicons/optimized/24/outline/plus.svg")
        end
      end
    end
  end

  it "renders a button with only an icon" do
    render_inline described_class.new(icon: "plus")

    expect(page).to have_button(class: "icon-button") do |button|
      expect(button).to have_selector("svg") do |svg|
        expect(svg).to have_html_attribute("data-source").with_value("heroicons/optimized/24/outline/plus.svg")
      end
    end
  end

  it "renders a button with only an icon but with aria label and tooltip" do
    render_inline described_class.new("Click me!", icon: "plus", icon_only: true)

    expect(page).to have_button(class: "icon-button") do |button|
      aggregate_failures do
        expect(button).to have_selector(".tooltip", text: "Click me!")
        expect(button).to have_selector("svg") do |svg|
          aggregate_failures do
            expect(svg).to have_html_attribute("data-source").with_value("heroicons/optimized/24/outline/plus.svg")
            expect(svg).to have_selector("title", text: "Click me!")
          end
        end
      end
    end
  end

  it "renders a button with a method" do
    render_inline described_class.new("Click me!", "/communes", method: :patch)

    expect(page).to have_selector("form") do |form|
      aggregate_failures do
        expect(form).to have_html_attribute("method").with_value("post")
        expect(form).to have_html_attribute("action").with_value("/communes")

        expect(form).to have_selector("input[type='hidden'][name='_method'][value='patch']", visible: :hidden)
        expect(form).to have_button("Click me!")
      end
    end
  end

  it "renders a button with method and params" do
    render_inline described_class.new("Click me!", "/communes", method: :patch, params: { ids: "all" })

    expect(page).to have_selector("form") do |form|
      aggregate_failures do
        expect(form).to have_html_attribute("method").with_value("post")
        expect(form).to have_html_attribute("action").with_value("/communes")

        expect(form).to have_selector("input[type='hidden'][name='_method'][value='patch']", visible: :hidden)
        expect(form).to have_selector("input[type='hidden'][name='ids'][value='all']", visible: :hidden)
        expect(form).to have_button("Click me!")
      end
    end
  end
end
