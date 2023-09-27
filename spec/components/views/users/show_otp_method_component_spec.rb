# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Users::ShowOtpMethodComponent, type: :component do
  it "renders an icon when user use 2FA method" do
    user = build_stubbed(:user)
    render_inline described_class.new(user)

    expect(page).to have_selector("svg") do |svg|
      expect(svg).to have_selector("title", text: "Via une application tierce")
    end
  end

  it "renders an icon when user use email method" do
    user = build_stubbed(:user, otp_method: "email")
    render_inline described_class.new(user)

    expect(page).to have_selector("svg") do |svg|
      expect(svg).to have_selector("title", text: "Via email")
    end
  end

  it "renders an empty string when user is not yet confirmed" do
    user = build_stubbed(:user, :unconfirmed)
    doc  = render_inline described_class.new(user)

    expect(doc.children.text).to eq(" ")
  end
end
