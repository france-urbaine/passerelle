# frozen_string_literal: true

require "rails_helper"

RSpec.describe PasswordField::Component, type: :component do
  it "renders a password field with password visibiliy button" do
    render_inline described_class.new(:user, :password)

    expect(page).to have_selector(".password-field") do |node|
      expect(node).to have_html_attribute("data-controller").with_value("password-visibility")

      expect(node).to have_field("user[password]") do |field|
        expect(field).to have_html_attribute("data-password-visibility-target").with_value("input")
      end

      expect(node).to have_button(class: "icon-button password-field__visibility-button") do |button|
        expect(button).to have_html_attribute("data-action").with_value("click->password-visibility#toggle")

        expect(button).to have_selector("span", count: 2)
        expect(button).to have_selector("span", class: "hidden", count: 1)
      end
    end
  end

  it "renders a password field with with password visibiliy button and password strength verification" do
    render_inline described_class.new(:user, :password, strength_test: true)

    expect(page).to have_selector(".password-field") do |node|
      expect(node).to have_html_attribute("data-controller").with_value("password-visibility strength-test")

      expect(node).to have_field("user[password]") do |field|
        expect(field).to have_html_attribute("data-password-visibility-target").with_value("input")
        expect(field).to have_html_attribute("data-action").with_value(" strength-test#check")
      end

      expect(node).to have_button(class: "icon-button password-field__visibility-button") do |button|
        expect(button).to have_html_attribute("data-action").with_value("click->password-visibility#toggle")

        expect(button).to have_selector("span", count: 2)
        expect(button).to have_selector("span", class: "hidden", count: 1)
      end

      expect(node).to have_selector("turbo-frame#password-strength-test-result")
    end
  end
end
