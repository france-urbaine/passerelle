# frozen_string_literal: true

require "rails_helper"

RSpec.describe UI::TabsComponent, type: :component do
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
end
