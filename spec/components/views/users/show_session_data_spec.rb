# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Users::ShowSessionData, type: :component do
  it "shows session data of a confirmed user" do
    user = build_stubbed(:user)
    render_inline described_class.new(user)

    aggregate_failures do
      expect(page).to have_text("Création du compte")
      expect(page).to have_text("Confirmation du compte")
    end
  end

  it "shows session data of an unconfirmed user" do
    user = build_stubbed(:user, :unconfirmed)
    render_inline described_class.new(user)

    aggregate_failures do
      expect(page).to have_text("Création du compte")
      expect(page).to have_text("Expiration de l'invitation")
      expect(page).not_to have_text("Confirmation du compte")
    end
  end
end
