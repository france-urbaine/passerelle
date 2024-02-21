# frozen_string_literal: true

require "system_helper"

RSpec.describe "Reports" do
  fixtures :regions, :departements, :epcis, :communes
  fixtures :collectivities, :publishers, :ddfips, :users
  fixtures :packages, :reports

  before do
    sign_in(users(:christelle))
  end

  it "searches for reports with simple string criterion" do
    visit reports_path(search: "2024-01-0001-00001")

    expect(page).to have_selector(:table_row, { "Référence" => "2024-01-0001-00001" })
    expect(page).to have_no_selector(:table_row, { "Référence" => "2024-01-0001-00002" })
  end

  it "searches for reports with hash-like string criteria" do
    visit reports_path(search: "package:2024-01-0001")

    expect(page).to have_selector(:table_row, { "Référence" => "2024-01-0001-00001" })
    expect(page).to have_selector(:table_row, { "Référence" => "2024-01-0001-00002" })
  end

  it "searches for reports with mulitple hash-like string criteria" do
    visit reports_path(search: "commune:bayonne form_type:(local pro)")

    expect(page).to have_no_selector(:table_row, { "Référence" => "2024-01-0001-00001" })
    expect(page).to have_selector(:table_row, { "Référence" => "2024-01-0001-00002" })
  end

  it "searches for ddfips with hash-like string criteria and simple string criterion" do
    visit reports_path(search: "address:(18 mai) bayonne")

    expect(page).to have_selector(:table_row, { "Référence" => "2024-01-0001-00001" })
    expect(page).to have_no_selector(:table_row, { "Référence" => "2024-01-0001-00002" })
  end

end
