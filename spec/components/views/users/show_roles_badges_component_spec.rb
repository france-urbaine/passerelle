# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Users::ShowRolesBadgesComponent, type: :component do
  it "renders a badge for each roles" do
    user = build_stubbed(:user, :organization_admin, :super_admin, :supervisor)
    render_inline described_class.new(user)

    expect(page).to have_selector(".badge.badge--red", text: "Admin. de Passerelle")
    expect(page).to have_selector(".badge.badge--orange", text: "Admin. de l'organisation")
    expect(page).to have_selector(".badge.badge--blue", text: "Superviseur de guichet")
  end

  it "renders an empty string when user doesn't have any roles" do
    user = build_stubbed(:user, :collectivity)
    doc  = render_inline described_class.new(user)

    expect(doc.children.text).to eq("")
  end

  it "renders a warning when user has no roles or office and is in a DDFIP" do
    user = build_stubbed(:user, :ddfip)
    render_inline described_class.new(user)

    expect(page).to have_selector("span.text-disabled", text: "Aucun guichet ou rôle assigné")
  end
end
