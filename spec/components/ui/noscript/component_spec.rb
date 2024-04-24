# frozen_string_literal: true

require "rails_helper"

RSpec.describe UI::Noscript::Component do
  it "wraps content in a noscript tag" do
    render_inline described_class.new do
      tag.p "Hello World"
    end

    expect(page).to have_selector("noscript") do |noscript|
      expect(noscript).to have_html_attribute("id").to match(/^noscript-.{6}$/)
      expect(noscript).to have_selector("p", text: "Hello World")

      expect(page).to have_selector("script", visible: :hidden) do |script|
        id = noscript["id"]

        expect(script).to have_html_attribute("id").with_value("script_#{id}")
        expect(script).to have_text(<<~JS.squish)
          document.getElementById("#{id}").remove();
          document.getElementById("script_#{id}").remove();
        JS
      end
    end
  end

  it "accepts a custom ID" do
    render_inline described_class.new(id: "backup-content") do
      tag.p "Hello World"
    end

    expect(page).to have_selector("noscript") do |noscript|
      expect(noscript).to have_html_attribute("id").with_value("backup-content")
    end

    expect(page).to have_selector("script", visible: :hidden) do |script|
      expect(script).to have_html_attribute("id").with_value("script_backup-content")
      expect(script).to have_text(<<~JS.squish)
        document.getElementById("backup-content").remove();
        document.getElementById("script_backup-content").remove();
      JS
    end
  end
end
