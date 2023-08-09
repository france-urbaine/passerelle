# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Users::ShowOrganizationComponent, type: :component do
  before { sign_in_as(:super_admin) }

  it "shows user organization with a link" do
    ddfip = build_stubbed(:ddfip)
    user  = build_stubbed(:user, organization: ddfip)
    render_inline described_class.new(user)

    expect(page).to have_link(ddfip.name, href: "/admin/ddfips/#{ddfip.id}")
  end

  it "shows discarded user organization" do
    ddfip = build_stubbed(:ddfip, :discarded)
    user  = build_stubbed(:user, organization: ddfip)
    render_inline described_class.new(user)

    expect(page).not_to have_link
    expect(page).to have_selector(".text-disabled") do |div|
      expect(div).to have_text(ddfip.name)
      expect(div).to have_text("(organisation supprimée)")
    end
  end
end
