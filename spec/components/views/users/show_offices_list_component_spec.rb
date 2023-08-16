# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Users::ShowOfficesListComponent, type: :component do
  before { sign_in_as(:super_admin) }

  it "shows user offices" do
    ddfip   = build_stubbed(:ddfip)
    offices = [
      build_stubbed(:office, ddfip: ddfip, name: "Office #A"),
      build_stubbed(:office, ddfip: ddfip, name: "Office #B"),
      build_stubbed(:office, ddfip: ddfip, name: "Office #C"),
      build_stubbed(:office, name: "Office #D"),
      build_stubbed(:office, ddfip: ddfip, name: "Office #E")
    ]

    user = build_stubbed(:user, organization: ddfip, offices: offices[0..3])
    render_inline described_class.new(user, namespace: :admin)

    expect(page).to have_link(count: 3)
    expect(page).to have_link(offices[0].name, href: "/admin/guichets/#{offices[0].id}")
    expect(page).to have_link(offices[1].name, href: "/admin/guichets/#{offices[1].id}")
    expect(page).to have_link(offices[2].name, href: "/admin/guichets/#{offices[2].id}")
  end
end
