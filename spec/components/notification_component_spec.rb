# frozen_string_literal: true

require "rails_helper"

RSpec.describe NotificationComponent, type: :component do
  subject(:component) { described_class.new }

  it "renders a notification", :aggregate_failures do
    component = described_class.new("Hello world !")
    render_inline(component)

    expect(page).to have_css(".notification[role='alert'][aria-live='polite']")
    expect(page).to have_css(".notification svg")

    within(".notification[role='alert']") do
      expect(page).to have_css(".notification__title", text: "Hello world !")
    end

    within(".notification svg") do
      expect(page).to have_css("title", text: "Information")
    end
  end

  it "renders a notification with description", :aggregate_failures do
    component = described_class.new({
      title:       "Hello world !",
      description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
    })

    render_inline(component)

    within(".notification[role='alert']") do
      expect(page).to have_css(".notification__title", text: "Hello world !")
      expect(page).to have_css(".notification__message", text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
    end
  end

  it "renders a successful notification", :aggregate_failures do
    component = described_class.new({
      type:  "success",
      title: "Hello world !"
    })

    render_inline(component)

    expect(page).to have_css(".notification svg.notification__icon--success")

    within(".notification svg.notification__icon--success") do
      expect(page).to have_css("title", text: "Succés")
    end
  end

  it "renders an error notification", :aggregate_failures do
    component = described_class.new({
      type:  "error",
      title: "Hello world !"
    })

    render_inline(component)

    expect(page).to have_css(".notification svg.notification__icon--error")

    within(".notification svg.notification__icon--error") do
      expect(page).to have_css("title", text: "Erreur")
    end
  end
end
