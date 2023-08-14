# frozen_string_literal: true

require "rails_helper"

RSpec.describe PasswordField::Component, type: :component do
  it "renders a password field" do
    render_inline described_class.new(:user, :password)

    expect(page).to have_selector("div[data-controller='password-visibility']") do |node|
      expect(node).to have_field("user[password]")
    end
  end

  it "renders a password field with password strength verification" do
    render_inline described_class.new(:user, :password, strength_test: true)

    expect(page).to have_selector("div[data-controller='strength-test password-visibility']") do |node|
      expect(node).to have_field("user[password]")

      expect(node).to have_selector("input[data-action='strength-test#check']")
      expect(node).to have_selector("turbo-frame#password-strength-test-result")
    end
  end
end
