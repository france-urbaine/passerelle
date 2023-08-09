# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Users::ShowOfficesShortListComponent, type: :component do
  before { sign_in_as(:super_admin) }

  let(:ddfip) { build_stubbed(:ddfip) }
  let(:offices) do
    [
      build_stubbed(:office, ddfip: ddfip, name: "Office #A"),
      build_stubbed(:office, ddfip: ddfip, name: "Office #B"),
      build_stubbed(:office, ddfip: ddfip, name: "Office #C"),
      build_stubbed(:office, name: "Office #D"),
      build_stubbed(:office, ddfip: ddfip, name: "Office #E")
    ]
  end

  it "shows the single office of an user" do
    user = build_stubbed(:user, organization: ddfip, offices: offices[4..])
    render_inline described_class.new(user, namespace: :admin)

    expect(page).to have_link(count: 1)
    expect(page).to have_link(offices[4].name, href: "/admin/guichets/#{offices[4].id}")
  end

  it "shows both offices of an user" do
    user = build_stubbed(:user, organization: ddfip, offices: offices[1..2])
    render_inline described_class.new(user, namespace: :admin)

    expect(page).to have_link(count: 2)
    expect(page).to have_link(offices[1].name, href: "/admin/guichets/#{offices[1].id}")
    expect(page).to have_link(offices[2].name, href: "/admin/guichets/#{offices[2].id}")
  end

  it "shows first offices of an user and truncate the others" do
    user = build_stubbed(:user, organization: ddfip, offices: offices)
    render_inline described_class.new(user, namespace: :admin)

    expect(page).to have_link(count: 1)
    expect(page).to have_link(offices[0].name, href: "/admin/guichets/#{offices[0].id}")
    expect(page).to have_text("#{offices[0].name} & 3 autres")
  end
end
