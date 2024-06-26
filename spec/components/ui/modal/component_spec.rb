# frozen_string_literal: true

require "rails_helper"

RSpec.describe UI::Modal::Component do
  it "renders a basic modal" do
    render_inline described_class.new do
      tag.p "Hello World"
    end

    expect(page).to have_selector(".modal") do |modal|
      expect(modal).to have_html_attribute("role").with_value("dialog")
      expect(modal).to have_html_attribute("aria-modal").boolean
      expect(modal).to have_html_attribute("aria-describedby")

      expect(modal).to have_selector(".modal__content > .modal__body") do |body|
        expect(body).to have_selector("p", text: "Hello World")
        expect(body).to have_html_attribute("id").with_value(modal["aria-describedby"])
      end
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

    expect(page).to have_selector(".modal") do |modal|
      expect(modal).to have_html_attribute("role").with_value("dialog")
      expect(modal).to have_html_attribute("aria-modal").boolean
      expect(modal).to have_html_attribute("aria-labelledby")

      expect(modal).to have_selector(".modal__content > .modal__header h1") do |h1|
        expect(h1).to have_text("Dialog title")
        expect(h1).to have_html_attribute("id").with_value(modal["aria-labelledby"])
      end

      expect(modal).to have_selector(".modal__content > .modal__body") do |body|
        expect(body).to have_selector("p", text: "Hello World")
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

    expect(page).to have_selector(".modal") do |modal|
      expect(modal).to have_selector(".modal__content > .modal__header h1") do |h1|
        expect(h1).to have_text("Dialog title")
        expect(h1).to have_html_attribute("id").with_value(modal["aria-labelledby"])
      end
    end
  end

  it "renders modal body from an argument" do
    render_inline described_class.new do |modal|
      modal.with_body("Hello World")
    end

    expect(page).to have_selector(".modal") do |modal|
      expect(modal).to have_selector(".modal__content > .modal__body") do |body|
        expect(body).to have_text("Hello World")
        expect(body).to have_html_attribute("id").with_value(modal["aria-describedby"])
      end
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
      expect(node).to have_button("Action 1", class: "button--primary")
      expect(node).to have_link("Action 2", class: "button", href: "/some/path")

      expect(node).to have_button("Close")
      expect(node).to have_button("Action 2")
    end
  end

  it "sets redirection to close buttons" do
    render_inline described_class.new(referrer: "/home/root") do |modal|
      modal.with_body do
        tag.p "Hello World"
      end

      modal.with_close_action("Close")
    end

    expect(page).to have_selector(".modal > .modal__content > .modal__body") do |node|
      expect(node).to have_link(class: "icon-button", href: "/home/root")
    end

    expect(page).to have_selector(".modal > .modal__content > .modal__actions") do |node|
      expect(node).to have_link("Close", class: "button", href: "/home/root")
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
      expect(form).to have_selector(".modal__header > h1.modal__title", text: "Dialog title")
      expect(form).to have_selector(".modal__body > .form-block > input[name='commune[name]']")
      expect(form).to have_selector(".modal__actions") do |actions|
        expect(actions).to have_button("Save", type: "submit")
        expect(actions).to have_button("Dismiss", type: "button")
      end
    end
  end

  it "renders a modal with a form and a custom scope" do
    record = Commune.new
    render_inline described_class.new do |modal|
      modal.with_form(model: record, scope: :foo, url: "/form/path") do |form|
        form.block(:name) do
          form.text_field(:name)
        end
      end
    end

    expect(page).to have_selector(".modal > .modal__content > turbo-frame > form[action='/form/path']") do |form|
      expect(form).to have_selector(".modal__body > .form-block > input[name='foo[name]']")
    end
  end

  it "accepts and merges custom attributes" do
    render_inline described_class.new(
      id:    "confirmation-modal",
      class: "confirm",
      aria: { hidden: true, labelledby: "inner-message" },
      data: {
        controller: "other_controller",
        action: "modal:close->other_controller#do_something"
      }
    ) do
      tag.p "Hello World"
    end

    expect(page).to have_selector(".modal") do |modal|
      expect(modal).to have_html_attribute("id").with_value("confirmation-modal")
      expect(modal).to have_html_attribute("class").with_value("modal confirm")
      expect(modal).to have_html_attribute("aria-hidden").boolean
      expect(modal).to have_html_attribute("aria-describedby").with_value("body_confirmation-modal")
      expect(modal).to have_html_attribute("aria-labelledby").with_value("inner-message")
      expect(modal).to have_html_attribute("data-controller").with_value("modal other_controller")
      expect(modal).to have_html_attribute("data-action").with_value("keydown@document->modal#keydown modal:close->other_controller#do_something")
    end
  end
end
