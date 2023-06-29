# frozen_string_literal: true

require "rails_helper"

RSpec.describe Modal::Component, type: :component do
  it "renders a basic modal" do
    render_inline described_class.new do
      tag.p "Hello World"
    end

    expect(page).to have_selector(".modal[role='dialog'][aria-modal='true']")
    expect(page).to have_selector(".modal > .modal__content > .modal__body") do |node|
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

    aggregate_failures do
      expect(page).to have_selector(".modal > .modal__content > .modal__header") do |node|
        expect(node).to have_selector("h1", text: "Dialog title")
      end

      expect(page).to have_selector(".modal > .modal__content > .modal__body") do |node|
        expect(node).to have_selector("p", text: "Hello World")
      end
    end
  end

  it "renders modal header from an argument" do
    render_inline described_class.new do |modal|
      modal.with_header("Dialog title")
      modal.with_body do
        tag.p "Hello World"
      end
    end

    expect(page).to have_selector(".modal > .modal__content > .modal__header") do |node|
      expect(node).to have_selector("h1", text: "Dialog title")
    end
  end

  it "renders modal body from an argument" do
    render_inline described_class.new do |modal|
      modal.with_body("Hello World")
    end

    expect(page).to have_selector(".modal > .modal__content > .modal__body") do |node|
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

    expect(page).to have_selector(".modal > .modal__content > .modal__actions") do |node|
      aggregate_failures do
        expect(node).to have_button("Action 1", class: "button--primary")
        expect(node).to have_link("Action 2", class: "button", href: "/some/path")

        expect(node).to have_button("Close")
        expect(node).to have_button("Action 2")
      end
    end
  end

  it "sets redirection to close buttons" do
    render_inline described_class.new(redirection_path: "/home/root") do |modal|
      modal.with_body do
        tag.p "Hello World"
      end

      modal.with_close_action("Close")
    end

    aggregate_failures do
      expect(page).to have_selector(".modal > .modal__content > .modal__body") do |node|
        expect(node).to have_link(class: "icon-button", href: "/home/root")
      end

      expect(page).to have_selector(".modal > .modal__content > .modal__actions") do |node|
        expect(node).to have_link("Close", class: "button", href: "/home/root")
      end
    end
  end

  it "renders a modal with a form" do
    record = Commune.new
    render_inline described_class.new do |modal|
      modal.with_header do
        "Dialog title"
      end

      modal.with_form(model: record, url: "/form/path") do |form|
        form.block(:name) do
          form.text_field(:name)
        end
      end

      modal.with_submit_action("Save")
      modal.with_close_action("Dismiss")
    end

    expect(page).to have_selector(".modal > .modal__content > turbo-frame > form[action='/form/path']") do |form|
      aggregate_failures do
        expect(form).to have_selector(".modal__header > h1.modal__title", text: "Dialog title")
        expect(form).to have_selector(".modal__body > .form-block > input[name='commune[name]']")
        expect(form).to have_selector(".modal__actions") do |actions|
          aggregate_failures do
            expect(actions).to have_button("Save", type: "submit")
            expect(actions).to have_button("Dismiss", type: "button")
          end
        end
      end
    end
  end
end
