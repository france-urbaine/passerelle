# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Users::ShowFormTypesListComponent, type: :component do
  it "shows user form types" do
    user = build_stubbed(:user, :form_admin, form_types: %w[creation_local_habitation evaluation_local_habitation])

    render_inline described_class.new(user, namespace: :admin)

    expect(page).to have_selector("li", count: 2)
    expect(page).to have_selector("li", text: "Création d'un local d'habitation")
    expect(page).to have_selector("li", text: "Évaluation d'un local d'habitation")
  end
end
