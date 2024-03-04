# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Dashboard::Component do
  let_it_be(:reports) { create_list(:report, 4) }

  it "renders the dashboard to a collectivity user" do
    sign_in_as(:collectivity)

    render_inline described_class.new(Report.strict_loading)

    expect(page).to have_selector(".chart-number", count: 4)
    expect(page).to have_selector(".datatable", count: 3)
  end

  it "renders the dashboard to a DDFIP admin" do
    sign_in_as(:ddfip, :organization_admin)

    render_inline described_class.new(Report.strict_loading)

    expect(page).to have_selector(".chart-number", count: 5)
    expect(page).to have_selector(".datatable", count: 3)
  end

  it "renders the dashboard to a DDFIP user" do
    sign_in_as(:ddfip)

    render_inline described_class.new(Report.strict_loading)

    expect(page).to have_selector(".chart-number", count: 2)
    expect(page).to have_selector(".datatable", count: 1)
  end

  it "renders the dashboard to a DGFIP user" do
    sign_in_as(:dgfip)

    render_inline described_class.new(Report.strict_loading)

    expect(page).to have_selector(".chart-number", count: 4)
    expect(page).to have_selector(".datatable", count: 1)
  end

  it "renders the dashboard to a publisher" do
    sign_in_as(:publisher)

    render_inline described_class.new(Report.strict_loading)

    expect(page).to have_selector(".chart-number", count: 3)
    expect(page).to have_selector(".datatable", count: 1)
  end
end
