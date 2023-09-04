# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::OauthApplications::FormComponent, type: :component do
  it "renders a form in a modal to create a new oauth_application" do
    render_inline described_class.new(OauthApplication.new, namespace: :organization)

    expect(page).to have_selector(".modal form") do |form|
      aggregate_failures do
        expect(form).to have_html_attribute("action").with_value("/organisation/oauth_applications")

        expect(form).to have_field("Nom de l'application")
        expect(form).to have_field("URI de redirection")
        expect(form).to have_field("Scopes")
      end
    end
  end

  it "renders a form in a modal to update an existing oauth_application" do
    publisher = build_stubbed(:publisher)
    oauth_application = build_stubbed(:oauth_application, owner: publisher)

    render_inline described_class.new(oauth_application, namespace: :organization)

    expect(page).to have_selector(".modal form") do |form|
      aggregate_failures do
        expect(form).to have_html_attribute("action").with_value("/organisation/oauth_applications/#{oauth_application.id}")

        expect(form).to have_field("Nom de l'application")
        expect(form).to have_field("URI de redirection")
        expect(form).to have_field("Scopes")
      end
    end
  end
end
