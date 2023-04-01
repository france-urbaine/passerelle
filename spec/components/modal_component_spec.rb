# frozen_string_literal: true

require "rails_helper"

RSpec.describe ModalComponent, type: :component do
  it "renders a basic modal" do
    render_inline described_class.new do
      tag.p "Hello World"
    end

    expect(page).to have_selector(".modal[role='dialog'][aria-modal='true']")
    expect(page).to have_selector(".modal > .modal__container > .modal__content") do |node|
      expect(node).to have_selector("p", text: "Hello World")
    end
  end

  it "renders a modal with header and body" do
    render_inline described_class.new do |modal|
      modal.with_header do
        "Dialog title"
      end

      modal.with_body do
        tag.p "Hello World"
      end
    end

    expect(page).to have_selector(".modal > .modal__container > .modal__header") do |node|
      expect(node).to have_selector("h1", text: "Dialog title")
    end

    expect(page).to have_selector(".modal > .modal__container > .modal__content") do |node|
      expect(node).to have_selector("p", text: "Hello World")
    end
  end

  it "renders modal header from an argument" do
    render_inline described_class.new do |modal|
      modal.with_header("Dialog title")
      modal.with_body do
        tag.p "Hello World"
      end
    end

    expect(page).to have_selector(".modal > .modal__container > .modal__header") do |node|
      expect(node).to have_selector("h1", text: "Dialog title")
    end
  end

  it "renders modal body from an argument" do
    render_inline described_class.new do |modal|
      modal.with_body("Hello World")
    end

    expect(page).to have_selector(".modal > .modal__container > .modal__content") do |node|
      expect(node).to have_text("Hello World")
    end
  end

  it "renders a modal with actions" do
    render_inline described_class.new do |modal|
      modal.with_body do
        tag.p "Hello World"
      end

      modal.with_action("Action 1", primary: true)
      modal.with_action("Action 2", href: "/some/path")

      modal.with_close_action("Close")
      modal.with_other_action("Action 2")
    end

    expect(page).to have_selector(".modal > .modal__container > .modal__actions") do |node|
      expect(node).to have_button("Action 1", class: "button--primary")
      expect(node).to have_link("Action 2", class: "button", href: "/some/path")

      expect(node).to have_button("Close")
      expect(node).to have_button("Action 2")
    end
  end

  it "sets redirection to close buttons" do
    render_inline described_class.new(redirection_path: "/home/root") do |modal|
      modal.with_body do
        tag.p "Hello World"
      end

      modal.with_close_action("Close")
    end

    expect(page).to have_selector(".modal > .modal__container > .modal__content") do |node|
      expect(node).to have_link(class: "icon-button", href: "/home/root")
    end

    expect(page).to have_selector(".modal > .modal__container > .modal__actions") do |node|
      expect(node).to have_link("Close", class: "button", href: "/home/root")
    end
  end

  it "renders a modal with a form" do
    record = Commune.new
    render_inline described_class.new do |modal|
      modal.with_header do
        "Dialog title"
      end

      modal.with_form(model: record) do
        tag.input(type: "text", name: "name")
      end

      modal.with_submit_action("Save")
      modal.with_close_action("Dismiss")
    end

    expect(page).to have_selector(".modal > .modal__container > turbo-frame > form[action='/communes']") do |form|
      expect(form).to have_selector(".modal__header > h1", text: "Dialog title")

      expect(form).to have_selector(".modal__content > input[name='name']")

      expect(form).to have_selector(".modal__actions") do |actions|
        expect(actions).to have_button("Save", type: "submit")
        expect(actions).to have_button("Dismiss", type: "button")
      end
    end
  end
end
