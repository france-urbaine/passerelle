# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Reports::NewComponent, type: :component do
  it "renders a form to create a new report" do
    render_inline described_class.new(Report.new)

    expect(page).to have_selector(".modal form") do |form|
      expect(form).to have_html_attribute("action").with_value("/signalements")
      expect(form).to have_field("Type de formulaire")
    end
  end
end
