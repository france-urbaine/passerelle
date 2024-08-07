# frozen_string_literal: true

require "rails_helper"

RSpec.describe UI::Form::Block::Component do
  it "wraps content in a div tag" do
    render_inline described_class.new(:user, :first_name) do
      tag.input(type: "text", name: "first_name")
    end

    expect(page).to have_selector(".form-block") do |node|
      expect(node).to have_field("first_name")
    end
  end

  it "displays errors and applies an invalid class when attribute is invalid" do
    user = User.new.tap(&:validate)

    render_inline described_class.new(user, :first_name) do
      tag.input(type: "text", name: "first_name")
    end

    expect(page).to have_selector(".form-block.form-block--invalid") do |node|
      expect(node).to have_field("first_name")
      expect(node).to have_selector(".form-block__errors", text: "Un prénom est requis")
    end
  end

  it "displays a custom error" do
    render_inline described_class.new(:user, :first_name) do |block|
      block.with_error do
        "A value is required"
      end

      tag.input(type: "text", name: "first_name")
    end

    expect(page).to have_selector(".form-block") do |node|
      expect(node).to have_field("first_name")
      expect(node).to have_selector(".form-block__errors", text: "A value is required")
    end
  end

  it "displays an hint" do
    render_inline described_class.new(:user, :first_name) do |block|
      block.with_hint do
        "You better have to fill this input"
      end

      tag.input(type: "text", name: "first_name")
    end

    expect(page).to have_selector(".form-block") do |node|
      expect(node).to have_field("first_name")
      expect(node).to have_selector(".form-block__hint", text: "You better have to fill this input")
    end
  end
end
