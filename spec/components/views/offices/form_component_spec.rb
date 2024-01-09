# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Offices::FormComponent, type: :component do
  it "renders a form in a modal to create a new office" do
    render_inline described_class.new(Office.new, namespace: :admin)

    expect(page).to have_selector(".modal form") do |form|
      expect(form).to have_html_attribute("action").with_value("/admin/guichets")

      expect(form).to have_field("DDFIP")
      expect(form).to have_field("Nom du guichet")
      expect(form).to have_unchecked_field("Évaluation des locaux d'habitation")
      expect(form).to have_unchecked_field("Évaluation des locaux professionnels")
    end
  end

  it "renders a form in a modal to create a new office belonging to a given DDFIP" do
    ddfip = build_stubbed(:ddfip)
    render_inline described_class.new(Office.new, namespace: :admin, ddfip: ddfip)

    expect(page).to have_selector(".modal form") do |form|
      expect(form).to have_html_attribute("action").with_value("/admin/ddfips/#{ddfip.id}/guichets")

      expect(form).to have_no_field("DDFIP")
      expect(form).to have_field("Nom du guichet")
      expect(form).to have_unchecked_field("Évaluation des locaux d'habitation")
      expect(form).to have_unchecked_field("Évaluation des locaux professionnels")
    end
  end

  it "renders a form in a modal to create a new office belonging to the current organization" do
    render_inline described_class.new(Office.new, namespace: :organization)

    expect(page).to have_selector(".modal form") do |form|
      expect(form).to have_html_attribute("action").with_value("/organisation/guichets")

      expect(form).to have_no_field("DDFIP")
      expect(form).to have_field("Nom du guichet")
      expect(form).to have_unchecked_field("Évaluation des locaux d'habitation")
      expect(form).to have_unchecked_field("Évaluation des locaux professionnels")
    end
  end

  it "renders a form in a modal to update an existing office" do
    ddfip  = build_stubbed(:ddfip)
    office = build_stubbed(:office, :evaluation_local_professionnel, ddfip: ddfip)
    render_inline described_class.new(office, namespace: :admin)

    expect(page).to have_selector(".modal form") do |form|
      expect(form).to have_html_attribute("action").with_value("/admin/guichets/#{office.id}")

      expect(form).to have_field("DDFIP",          with: ddfip.name)
      expect(form).to have_field("Nom du guichet", with: office.name)
      expect(form).to have_unchecked_field("Évaluation des locaux d'habitation")
      expect(form).to have_checked_field("Évaluation des locaux professionnels")
    end
  end

  it "renders a form in a modal to update an existing office belonging to the current organization" do
    office = build_stubbed(:office, :evaluation_local_professionnel)

    render_inline described_class.new(office, namespace: :organization)

    expect(page).to have_selector(".modal form") do |form|
      expect(form).to have_html_attribute("action").with_value("/organisation/guichets/#{office.id}")

      expect(form).to have_no_field("DDFIP")
      expect(form).to have_field("Nom du guichet", with: office.name)
      expect(form).to have_unchecked_field("Évaluation des locaux d'habitation")
      expect(form).to have_checked_field("Évaluation des locaux professionnels")
    end
  end
end
