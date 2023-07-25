# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Offices::EditUsersComponent, type: :component do
  it "renders a form in a modal to edit office users" do
    office = create(:office)
    users  = create_list(:user, 3, organization: office.ddfip)

    render_inline described_class.new(office, scope: :admin)

    expect(page).to have_selector(".modal form") do |form|
      aggregate_failures do
        expect(form).to have_html_attribute("action").with_value("/admin/guichets/#{office.id}/utilisateurs")

        expect(form).to have_field(type: "checkbox", count: 3)
        expect(form).to have_unchecked_field(users[0].name)
        expect(form).to have_unchecked_field(users[1].name)
        expect(form).to have_unchecked_field(users[2].name)
      end
    end
  end
end
