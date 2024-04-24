# frozen_string_literal: true

require "rails_helper"

RSpec.describe UI::Tabs::Component do
  it "renders multiple tabs" do
    render_inline described_class.new do |tabs|
      tabs.with_tab("Tab #1") { "Content of tab #1" }
      tabs.with_tab("Tab #2") { "Content of tab #2" }
      tabs.with_tab("Tab #3") { "Content of tab #3" }
    end

    expect(page).to have_selector(".tabs") do |node|
      expect(node).to have_selector(".tabs__tab", count: 3)
      expect(node).to have_selector(".tabs__tab", text: "Tab #1")
      expect(node).to have_selector(".tabs__tab", text: "Tab #2")
      expect(node).to have_selector(".tabs__tab", text: "Tab #3")

      expect(node).to have_selector(".tabs__panel", count: 3, visible: :all)
      expect(node).to have_selector(".tabs__panel", text: "Content of tab #1", visible: :visible)
      expect(node).to have_selector(".tabs__panel", text: "Content of tab #2", visible: :hidden)
      expect(node).to have_selector(".tabs__panel", text: "Content of tab #3", visible: :hidden)
    end
  end

  it "links tabs to panels for proper ARIA" do
    render_inline described_class.new do |tabs|
      tabs.with_tab("Tab #1") { "Content of tab #1" }
      tabs.with_tab("Tab #2") { "Content of tab #2" }
    end

    expect(page).to have_selector(".tabs__tab", text: "Tab #1") do |tab|
      expect(tab).to have_html_attribute("id").to match(/^tab-.{6}$/)
      expect(tab).to have_html_attribute("role").with_value("tab")
      expect(tab).to have_html_attribute("aria-controls").with_value("panel_#{tab['id']}")
      expect(tab).to have_html_attribute("aria-selected").boolean

      expect(page).to have_selector(".tabs__panel", text: "Content of tab #1") do |panel|
        expect(panel).to have_html_attribute("role").with_value("tabpanel")
        expect(panel).to have_html_attribute("aria-labelledby").with_value(tab["id"])
        expect(panel).to have_html_attribute("id").with_value(tab["aria-controls"])
      end
    end
  end

  it "accepts custom tabs IDs" do
    render_inline described_class.new do |tabs|
      tabs.with_tab("Tab #1", id: "tab1") { "Content of tab #1" }
      tabs.with_tab("Tab #2", id: "tab2") { "Content of tab #2" }
      tabs.with_tab("Tab #3")             { "Content of tab #3" }
    end

    expect(page).to have_selector(".tabs__tab", text: "Tab #1") do |tab|
      expect(tab).to have_html_attribute("id").with_value("tab1")
      expect(tab).to have_html_attribute("aria-controls").with_value("panel_tab1")
    end

    expect(page).to have_selector(".tabs__tab", text: "Tab #2") do |tab|
      expect(tab).to have_html_attribute("id").with_value("tab2")
      expect(tab).to have_html_attribute("aria-controls").with_value("panel_tab2")
    end

    expect(page).to have_selector(".tabs__tab", text: "Tab #3") do |tab|
      expect(tab).to have_html_attribute("id").to match(/^tab-.{6}$/)
      expect(tab).to have_html_attribute("aria-controls").to match(/^panel_tab-.{6}$/)
    end

    expect(page).to have_selector(".tabs__panel", text: "Content of tab #1") do |panel|
      expect(panel).to have_html_attribute("id").with_value("panel_tab1")
      expect(panel).to have_html_attribute("aria-labelledby").with_value("tab1")
    end

    expect(page).to have_selector(".tabs__panel", text: "Content of tab #2", visible: :hidden) do |panel|
      expect(panel).to have_html_attribute("id").with_value("panel_tab2")
      expect(panel).to have_html_attribute("aria-labelledby").with_value("tab2")
    end
  end
end
