# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Users::ShowEmailComponent, type: :component do
  it "shows user email with a link" do
    user = build_stubbed(:user)
    render_inline described_class.new(user)

    expect(page).to have_link(user.email)
  end

  it "escapes user email symbols in href (thanks to mail_to)" do
    user = build_stubbed(:user, email: "moulin+c#leste.10@lesch.test")
    render_inline described_class.new(user)

    expect(page).to have_link("moulin+c#leste.10@lesch.test", href: "mailto:moulin%2Bc%23leste.10@lesch.test")
  end

  it "shows the email of an unconfirmed user" do
    user = build_stubbed(:user, confirmed_at: nil)
    render_inline described_class.new(user)

    expect(page).not_to have_link
    expect(page).to have_selector(".text-disabled") do |div|
      expect(div).to have_text(user.email)
      expect(div).to have_text("Cet utilisateur n'a pas encore validé son inscription")
    end
  end

  it "shows the unconfirmed email of a confirmed user" do
    user = build_stubbed(:user, unconfirmed_email: "unconfirmed@example.com")
    render_inline described_class.new(user)

    expect(page).not_to have_link
    expect(page).to have_selector(".text-disabled") do |div|
      expect(div).to have_text("unconfirmed@example.com")
      expect(div).to have_text("La modification de l'adresse mail est en cours et n'a pas été validée par l'utilisateur")
    end
  end
end
