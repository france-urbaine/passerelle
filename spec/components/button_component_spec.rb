# frozen_string_literal: true

require "rails_helper"

RSpec.describe ButtonComponent, type: :component do
  it "renders a button" do
    render_inline described_class.new("Click me!")

    expect(page).to have_button("Click me!", class: "button")
  end

  it "renders button with label from block" do
    render_inline described_class.new do
      "Click me!"
    end

    expect(page).to have_button("Click me!", class: "button")
  end

  it "renders a link" do
    render_inline described_class.new("Click me!", href: "/communes")

    expect(page).to have_link("Click me!", class: "button", href: "/communes")
  end

  it "renders a link to open in a modal" do
    render_inline described_class.new("Click me!", href: "/communes", modal: true)

    expect(page).to have_selector("a.button[href='/communes'][data-turbo-frame='modal']", text: "Click me!")
  end

  it "renders a primary button" do
    render_inline described_class.new("Click me!", primary: true)

    expect(page).to have_button("Click me!", class: "button--primary")
  end

  it "renders a destructive button" do
    render_inline described_class.new("Click me!", destructive: true)

    expect(page).to have_button("Click me!", class: "button--destructive")
  end

  it "renders a button with an icon" do
    render_inline described_class.new("Click me!", icon: "plus")

    expect(page).to have_button(class: "button") do |node|
      expect(node).to have_selector("svg > path[d='M12 4.5v15m7.5-7.5h-15']")
      expect(node).to have_text("Click me!")
    end
  end

  it "renders a button with only an icon" do
    render_inline described_class.new(icon: "plus")

    expect(page).to have_button(class: "icon-button") do |node|
      expect(node).to have_selector("svg > path[d='M12 4.5v15m7.5-7.5h-15']")
    end
  end

  it "renders a button with only an icon but with aria label and tooltip" do
    render_inline described_class.new("Click me!", icon: "plus", icon_only: true)

    expect(page).to have_button(class: "icon-button") do |node|
      expect(node).to have_selector("svg > path[d='M12 4.5v15m7.5-7.5h-15']")
    end
  end
end
