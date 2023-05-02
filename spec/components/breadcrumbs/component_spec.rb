# frozen_string_literal: true

require "rails_helper"

RSpec.describe Breadcrumbs::Component, type: :component do
  it "renders breacrumbs" do
    render_inline described_class.new do |breadcrumbs|
      breadcrumbs.with_path "Path 1"
      breadcrumbs.with_path "Path 2", "/foo"
      breadcrumbs.with_path "Path 3"
    end

    expect(page).to have_selector(".header-bar > .breadcrumbs") do |node|
      aggregate_failures do
        expect(node).to have_selector(".breadcrumbs__path:nth-child(1) > a.icon-button", text: "Retour à la page d'accueil")

        expect(node).to have_selector(".breadcrumbs__separator:nth-child(2)", text: "/")
        expect(node).to have_selector(".breadcrumbs__path:nth-child(3)", text: "Path 1")

        expect(node).to have_selector(".breadcrumbs__separator:nth-child(4)", text: "/")
        expect(node).to have_selector(".breadcrumbs__path:nth-child(5) > a[href='/foo']", text: "Path 2")

        expect(node).to have_selector(".breadcrumbs__separator:nth-child(6)", text: "/")
        expect(node).to have_selector(".breadcrumbs__path:nth-child(7) > h1", text: "Path 3")
      end
    end
  end

  it "renders breacrumbs using href option" do
    render_inline described_class.new do |breadcrumbs|
      breadcrumbs.with_path "Path 1"
      breadcrumbs.with_path "Path 2", href: "/foo"
      breadcrumbs.with_path "Path 3"
    end

    expect(page).to have_selector(".header-bar > .breadcrumbs") do |node|
      aggregate_failures do
        expect(node).to have_selector(".breadcrumbs__path:nth-child(1) > a.icon-button", text: "Retour à la page d'accueil")

        expect(node).to have_selector(".breadcrumbs__separator:nth-child(2)", text: "/")
        expect(node).to have_selector(".breadcrumbs__path:nth-child(3)", text: "Path 1")

        expect(node).to have_selector(".breadcrumbs__separator:nth-child(4)", text: "/")
        expect(node).to have_selector(".breadcrumbs__path:nth-child(5) > a[href='/foo']", text: "Path 2")

        expect(node).to have_selector(".breadcrumbs__separator:nth-child(6)", text: "/")
        expect(node).to have_selector(".breadcrumbs__path:nth-child(7) > h1", text: "Path 3")
      end
    end
  end

  it "renders actions" do
    render_inline described_class.new do |breadcrumbs|
      breadcrumbs.with_action "Update"
    end

    expect(page).to have_selector(".header-bar > .header-bar__actions") do |node|
      expect(node).to have_selector(".header-bar__action > button", text: "Update")
    end
  end

  it "renders a primary action" do
    render_inline described_class.new do |breadcrumbs|
      breadcrumbs.with_action "Update", primary: true
    end

    expect(page).to have_selector(".header-bar > .header-bar__actions") do |node|
      expect(node).to have_selector(".header-bar__action > button.button--primary", text: "Update")
    end
  end

  it "renders an action with an icon" do
    render_inline described_class.new do |breadcrumbs|
      breadcrumbs.with_action "Update", icon: "plus"
    end

    expect(page).to have_selector(".header-bar > .header-bar__actions") do |node|
      expect(node).to have_selector(".header-bar__action > button > svg")
    end
  end

  it "renders an action with a link" do
    render_inline described_class.new do |breadcrumbs|
      breadcrumbs.with_action "Update", "/foo"
    end

    expect(page).to have_selector(".header-bar > .header-bar__actions") do |node|
      expect(node).to have_selector(".header-bar__action > a[href='/foo']", text: "Update")
    end
  end

  it "renders an action with a link using href option" do
    render_inline described_class.new do |breadcrumbs|
      breadcrumbs.with_action "Update", href: "/foo"
    end

    expect(page).to have_selector(".header-bar > .header-bar__actions") do |node|
      expect(node).to have_selector(".header-bar__action > a[href='/foo']", text: "Update")
    end
  end

  it "renders an action to open a link in a modal" do
    render_inline described_class.new do |breadcrumbs|
      breadcrumbs.with_action "Update", href: "/foo", modal: true
    end

    expect(page).to have_selector(".header-bar > .header-bar__actions") do |node|
      expect(node).to have_selector(".header-bar__action > a[data-turbo-frame='modal']", text: "Update")
    end
  end
end
