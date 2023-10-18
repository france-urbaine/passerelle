# frozen_string_literal: true

require "rails_helper"

RSpec.describe UI::DropdownComponent, type: :component do
  it "renders a dropdown" do
    render_inline described_class.new do |dropdown|
      dropdown.with_button "Plus d'options"

      dropdown.with_menu_item "Option 1", "/option/1"
      dropdown.with_menu_item "Option 2", "/option/2"
    end

    expect(page).to have_selector(".dropdown") do |dropdown|
      aggregate_failures do
        expect(dropdown).to have_selector(".button", text: "Plus d'options")
        expect(dropdown).to have_selector(".dropdown__menu") do |menu|
          aggregate_failures do
            expect(menu).to have_selector(".button", text: "Option 1")
            expect(menu).to have_selector(".button", text: "Option 2")
          end
        end
      end
    end
  end

  it "renders a dropdown with the menu next to the button" do
    render_inline described_class.new(position: "aside") do |dropdown|
      dropdown.with_button "Plus d'options"
      dropdown.with_menu_item "Option 1", "/option/1"
    end

    expect(page).to have_selector(".dropdown") do |dropdown|
      expect(dropdown).to have_selector(".dropdown__menu.dropdown__menu--aside-right")
    end
  end

  it "renders a dropdown with the menu explicitely below to the button" do
    render_inline described_class.new(position: "below") do |dropdown|
      dropdown.with_button "Plus d'options"
      dropdown.with_menu_item "Option 1", "/option/1"
    end

    expect(page).to have_selector(".dropdown") do |dropdown|
      expect(dropdown).to have_selector(".dropdown__menu.dropdown__menu--below-right")
    end
  end

  it "renders a dropdown with the menu in the left direction" do
    render_inline described_class.new(direction: "left") do |dropdown|
      dropdown.with_button "Plus d'options"
      dropdown.with_menu_item "Option 1", "/option/1"
    end

    expect(page).to have_selector(".dropdown") do |dropdown|
      expect(dropdown).to have_selector(".dropdown__menu.dropdown__menu--below-left")
    end
  end

  it "renders a dropdown with the menu next to the button, in the left direction" do
    render_inline described_class.new(position: "aside", direction: "left") do |dropdown|
      dropdown.with_button "Plus d'options"
      dropdown.with_menu_item "Option 1", "/option/1"
    end

    expect(page).to have_selector(".dropdown") do |dropdown|
      expect(dropdown).to have_selector(".dropdown__menu.dropdown__menu--aside-left")
    end
  end

  it "renders a nested dropdown" do
    render_inline described_class.new do |dropdown|
      dropdown.with_button "Plus d'options"

      dropdown.with_menu_item "Option 1" do |item|
        item.with_menu_item "Option 1.a"
        item.with_menu_item "Option 1.b"
      end

      dropdown.with_menu_item "Option 2" do |item|
        item.with_menu_item "Option 2.a"
        item.with_menu_item "Option 2.b"
        item.with_menu_item "Option 2.c" do |child_item|
          child_item.with_menu_item "Option 2.c (1)"
          child_item.with_menu_item "Option 2.c (2)"
        end
      end
    end

    expect(page).to have_selector(".dropdown") do |dropdown|
      expect(dropdown).to have_selector(".button", text: "Plus d'options")
      expect(dropdown).to have_selector(".dropdown__menu") do |menu|
        aggregate_failures do
          expect(menu).to have_selector(".button", text: "Option 1")
          expect(menu).to have_selector(".button", text: "Option 2")
        end
      end
    end

    expect(page).to have_selector(".dropdown > .dropdown__menu > .dropdown:nth-child(1)") do |dropdown|
      expect(dropdown).to have_selector(".button", text: "Option 1")
      expect(dropdown).to have_selector(".dropdown__menu") do |menu|
        aggregate_failures do
          expect(menu).to have_selector(".button", text: "Option 1.a")
          expect(menu).to have_selector(".button", text: "Option 1.b")
        end
      end
    end

    expect(page).to have_selector(".dropdown > .dropdown__menu > .dropdown:nth-child(2)") do |dropdown|
      expect(dropdown).to have_selector(".button", text: "Option 2")
      expect(dropdown).to have_selector(".dropdown__menu") do |menu|
        aggregate_failures do
          expect(menu).to have_selector(".button", text: "Option 2.a")
          expect(menu).to have_selector(".button", text: "Option 2.b")
        end
      end
    end

    expect(page).to have_selector(".dropdown > .dropdown__menu > .dropdown:nth-child(2) >  .dropdown__menu > .dropdown") do |dropdown|
      expect(dropdown).to have_selector(".button", text: "Option 2.c")
      expect(dropdown).to have_selector(".dropdown__menu") do |menu|
        aggregate_failures do
          expect(menu).to have_selector(".button", text: "Option 2.c (1)")
          expect(menu).to have_selector(".button", text: "Option 2.c (2)")
        end
      end
    end
  end

  it "renders a dropdown with custom menu item" do
    render_inline described_class.new do |dropdown|
      dropdown.with_button "Plus d'options"
      dropdown.with_menu_item "Option 1" do |item|
        item.with_menu_item { "Hello World" }
      end
    end

    expect(page).to have_selector(".dropdown") do |dropdown|
      expect(dropdown).to have_selector(".button", text: "Plus d'options")
      expect(dropdown).to have_selector(".dropdown__menu-item", text: "Hello World")
    end
  end
end
