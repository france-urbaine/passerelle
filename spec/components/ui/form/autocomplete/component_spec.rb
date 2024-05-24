# frozen_string_literal: true

require "rails_helper"

RSpec.describe UI::Form::Autocomplete::Component do
  it "renders autocompletion fields" do
    render_inline described_class.new(:collectivity, :publisher, url: "/publishers")

    expect(page).to have_selector(".form-block.autocomplete") do |block|
      expect(block).to have_html_attribute("data-controller").with_value("autocomplete")
      expect(block).to have_html_attribute("data-autocomplete-url-value").with_value("/publishers")
      expect(block).to have_html_attribute("data-autocomplete-selected-class").with_value("datalist__option--active")

      expect(block).to have_field(type: :search) do |input|
        expect(input).to have_html_attribute("name").with_value("collectivity[publisher]")
        expect(input).to have_html_attribute("data-autocomplete-target").with_value("input")
      end

      expect(block).to have_field(type: :hidden) do |input|
        expect(input).to have_html_attribute("name").with_value("collectivity[publisher_id]")
        expect(input).to have_html_attribute("data-autocomplete-target").with_value("hidden")
      end
    end
  end

  it "renders autocompletion with placeholder" do
    render_inline described_class.new(:collectivity, :publisher, url: "/publishers", placeholder: "Start typing to find publishers...")

    expect(page).to have_selector(".form-block.autocomplete") do |block|
      expect(block).to have_field(type: :search) do |input|
        expect(input).to have_html_attribute("placeholder").with_value("Start typing to find publishers...")
      end
    end
  end

  it "renders autocompletion with options" do
    render_inline described_class.new(:collectivity, :publisher, url: "/publishers", min_length: 3, delay: 5000)

    expect(page).to have_selector(".form-block.autocomplete") do |block|
      expect(block).to have_html_attribute("data-controller").with_value("autocomplete")
      expect(block).to have_html_attribute("data-autocomplete-url-value").with_value("/publishers")
      expect(block).to have_html_attribute("data-autocomplete-selected-class").with_value("datalist__option--active")
      expect(block).to have_html_attribute("data-autocomplete-min-length-value").with_value("3")
      expect(block).to have_html_attribute("data-autocomplete-delay-value").with_value("5000")
    end
  end

  it "renders autocompletion with form object" do
    publisher    = build_stubbed(:publisher)
    collectivity = build_stubbed(:collectivity, publisher:)

    render_inline described_class.new(:collectivity, :publisher, url: "/publishers", object: collectivity)

    expect(page).to have_selector(".form-block.autocomplete") do |block|
      expect(block).to have_field(type: :search) do |input|
        expect(input).to have_html_attribute("name").with_value("collectivity[publisher]")
        expect(input).to have_html_attribute("value").with_value(publisher.name)
      end

      expect(block).to have_field(type: :hidden) do |input|
        expect(input).to have_html_attribute("name").with_value("collectivity[publisher_id]")
        expect(input).to have_html_attribute("value").with_value(publisher.id)
      end
    end
  end

  it "renders autocompletion with label (not translated)" do
    render_inline described_class.new(:collectivity, :publisher, url: "/publishers") do |autocomplete| # rubocop:disable Style/SymbolProc
      autocomplete.with_label
    end

    expect(page).to have_selector(".form-block.autocomplete") do |block|
      expect(block).to have_selector("label", text: "Publisher")
    end
  end

  it "renders autocompletion with custom label" do
    render_inline described_class.new(:collectivity, :publisher, url: "/publishers") do |autocomplete|
      autocomplete.with_label "Find a publisher :"
    end

    expect(page).to have_selector(".form-block.autocomplete") do |block|
      expect(block).to have_selector("label", text: "Find a publisher :")
    end
  end

  it "renders autocompletion with translated label from object" do
    collectivity = Collectivity.new

    render_inline described_class.new(:collectivity, :publisher, url: "/publishers", object: collectivity) do |autocomplete| # rubocop:disable Style/SymbolProc
      autocomplete.with_label
    end

    expect(page).to have_selector(".form-block.autocomplete") do |block|
      expect(block).to have_selector("label", text: "Éditeur")
    end
  end

  it "renders custom content" do
    render_inline described_class.new(:collectivity, :publisher, url: "/publishers") do
      tag.p("Start typing in the input below :", class: "custom-text")
    end

    expect(page).to have_selector(".form-block.autocomplete") do |block|
      expect(block).to have_selector("p.custom-text", text: "Start typing in the input below :")
    end
  end

  it "renders autocompletion with custom search input" do
    render_inline described_class.new(:commune, :departement, url: "/departements") do |autocomplete|
      autocomplete.with_search_field value: "Département des Hautes-Pyréneés", data: { whatever: "foo" }
    end

    expect(page).to have_selector(".form-block.autocomplete") do |block|
      expect(block).to have_field(type: :search) do |input|
        expect(input).to have_html_attribute("name").with_value("commune[departement]")
        expect(input).to have_html_attribute("value").with_value("Département des Hautes-Pyréneés")
        expect(input).to have_html_attribute("data-autocomplete-target").with_value("input")
        expect(input).to have_html_attribute("data-whatever").with_value("foo")
      end
    end
  end

  it "renders autocompletion with custom hidden input" do
    render_inline described_class.new(:commune, :departement, url: "/departements") do |autocomplete|
      autocomplete.with_hidden_field :code_departement, value: "33", data: { whatever: "foo" }
    end

    expect(page).to have_selector(".form-block.autocomplete") do |block|
      expect(block).to have_field(type: :hidden) do |input|
        expect(input).to have_html_attribute("name").with_value("commune[code_departement]")
        expect(input).to have_html_attribute("value").with_value("33")
        expect(input).to have_html_attribute("data-autocomplete-target").with_value("hidden")
        expect(input).to have_html_attribute("data-whatever").with_value("foo")
      end
    end
  end

  it "sets proper value from object to custom hidden input" do
    departement = build_stubbed(:departement, code_departement: "65")
    commune     = build_stubbed(:commune, departement:)

    render_inline described_class.new(:commune, :departement, url: "/departements", object: commune) do |autocomplete|
      autocomplete.with_hidden_field :code_departement
    end

    expect(page).to have_selector(".form-block.autocomplete") do |block|
      expect(block).to have_field(type: :hidden) do |input|
        expect(input).to have_html_attribute("name").with_value("commune[code_departement]")
        expect(input).to have_html_attribute("value").with_value("65")
      end
    end
  end

  it "renders autocompletion with custom name to hidden input" do
    render_inline described_class.new(:commune, :departement, url: "/departements") do |autocomplete|
      autocomplete.with_hidden_field value: "33", name: "code_departement"
    end

    expect(page).to have_selector(".form-block.autocomplete") do |block|
      expect(block).to have_field(type: :hidden) do |input|
        expect(input).to have_html_attribute("name").with_value("code_departement")
        expect(input).to have_html_attribute("value").with_value("33")
      end
    end
  end

  it "accepts method outside object in custom hidden field" do
    render_inline described_class.new(:commune, :departement, url: "/departements") do |autocomplete|
      autocomplete.with_hidden_field :departement_data, value: { code: "33" }
    end

    expect(page).to have_selector(".form-block.autocomplete") do |block|
      expect(block).to have_field(type: :hidden) do |input|
        expect(input).to have_html_attribute("name").with_value("commune[departement_data]")
      end
    end
  end

  it "jsonifies custom hidden value" do
    render_inline described_class.new(:commune, :departement, url: "/departements") do |autocomplete|
      autocomplete.with_hidden_field value: { type: "departement", code: "33" }
    end

    expect(page).to have_selector(".form-block.autocomplete") do |block|
      expect(block).to have_field(type: :hidden) do |input|
        expect(input).to have_html_attribute("value").with_value(
          { type: "departement", code: "33" }.to_json
        )
      end
    end
  end

  it "displays custom errors (like Form::Block::Component)" do
    render_inline described_class.new(:commune, :departement, url: "/departements") do |autocomplete|
      autocomplete.with_error do
        "A value is required"
      end
    end

    expect(page).to have_selector(".form-block.autocomplete") do |block|
      expect(block).to have_selector(".form-block__errors", text: "A value is required")
    end
  end

  it "displays an hint (like Form::Block::Component)" do
    render_inline described_class.new(:commune, :departement, url: "/departements") do |autocomplete|
      autocomplete.with_hint do
        "You better have to fill this input"
      end
    end

    expect(page).to have_selector(".form-block") do |block|
      expect(block).to have_selector(".form-block__hint", text: "You better have to fill this input")
    end
  end

  it "renders noscript element to be displayed when JS is disabled" do
    render_inline described_class.new(:collectivity, :publisher, url: "/publishers") do |autocomplete|
      autocomplete.with_noscript do
        tag.p "Hello World"
      end
    end

    expect(page).to have_selector("noscript") do |noscript|
      expect(noscript).to have_html_attribute("id").to match(/^noscript-.{6}$/)
      expect(noscript).to have_selector("p", text: "Hello World")
    end
  end

  it "hides the autocompletion inputs when noscript components are set" do
    render_inline described_class.new(:collectivity, :publisher, url: "/publishers") do |autocomplete|
      autocomplete.with_noscript do
        tag.p "Hello World"
      end
    end

    expect(page).to have_selector(".form-block.autocomplete.hidden")
  end
end
