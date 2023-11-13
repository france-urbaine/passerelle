# frozen_string_literal: true

require "rails_helper"

RSpec.describe UI::Form::HiddenFieldComponent, type: :component do
  # Disable Capybara/SpecificMatcher to match exact HTML output
  # rubocop:disable Capybara/SpecificMatcher
  #
  it "renders an hidden field with a String value" do
    render_inline described_class.new(:hello, "World")

    expect(page).to have_selector("input[type='hidden']", visible: :hidden, count: 1) do |input|
      expect(input).to have_html_attribute("name").with_value("hello")
      expect(input).to have_html_attribute("value").with_value("World")
    end
  end

  it "renders an hidden field with an Array value" do
    render_inline described_class.new(:hello, %w[1 2 3])

    expect(page).to have_selector("input[type='hidden']", visible: :hidden, count: 3)
    expect(page).to have_selector("input[type='hidden'][name='hello[]'][value='1']", visible: :hidden)
    expect(page).to have_selector("input[type='hidden'][name='hello[]'][value='2']", visible: :hidden)
    expect(page).to have_selector("input[type='hidden'][name='hello[]'][value='3']", visible: :hidden)
  end

  it "renders an hidden field with a Hash value" do
    render_inline described_class.new(:hello, { foo: 2, bar: 3 })

    expect(page).to have_selector("input[type='hidden']", visible: :hidden, count: 2)
    expect(page).to have_selector("input[type='hidden'][name='hello[foo]'][value='2']", visible: :hidden)
    expect(page).to have_selector("input[type='hidden'][name='hello[bar]'][value='3']", visible: :hidden)
  end

  it "renders nothing when value is nil" do
    render_inline described_class.new(:hello, nil)

    expect(page).not_to have_selector("input[type='hidden']", visible: :hidden)
  end
  #
  # rubocop:enable Capybara/SpecificMatcher
end
