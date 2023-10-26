# frozen_string_literal: true

require "rails_helper"

RSpec.describe Layout::ModalFrameComponent, type: :component do
  it "renders a modal aside to main content" do
    render_inline described_class.new do |template|
      template.with_modal do |modal|
        modal.with_header("Dialog header")
        modal.with_body("Hello World")
      end
    end

    expect(page).to have_selector("main.content > turbo-frame:empty")
    expect(page).to have_selector("turbo-frame#modal > .modal > .modal__content > .modal__header", text: "Dialog header")
    expect(page).to have_selector("turbo-frame#modal > .modal > .modal__content > .modal__body", text: "Hello World")
  end

  it "renders explicitely the modal" do
    render_inline described_class.new do
      tag.p "Hello World", class: "custom-modal"
    end

    expect(page).to have_selector("main.content > turbo-frame:empty")
    expect(page).to have_selector("turbo-frame#modal > p.custom-modal", text: "Hello World")
  end

  it "render asynchronously a background in main content with referrer URL" do
    render_inline described_class.new(referrer: "/home/root") do |template|
      template.with_modal do |modal|
        modal.with_header("Dialog header")
        modal.with_body("Hello World")
      end
    end

    expect(page).to have_selector("main.content > turbo-frame:empty[src='/home/root']")
    expect(page).to have_selector("turbo-frame#modal > .modal > .modal__content > .modal__header", text: "Dialog header")
    expect(page).to have_selector("turbo-frame#modal > .modal > .modal__content > .modal__body", text: "Hello World")
  end

  it "sets redirection to close buttons" do
    render_inline described_class.new(referrer: "/home/root") do |template|
      template.with_modal do |modal|
        modal.with_header("Dialog header")
        modal.with_body("Hello World")
        modal.with_close_action("Close")
      end
    end

    expect(page).to have_selector("turbo-frame#modal > .modal > .modal__content") do |modal|
      aggregate_failures do
        expect(modal).to have_selector(".modal__header-toolbar > a.modal__close-button") do |link|
          expect(link).to have_html_attribute(:href).with_value("/home/root")
        end

        expect(modal).to have_selector(".modal__actions > a.modal__close-action") do |link|
          expect(link).to have_html_attribute(:href).with_value("/home/root")
        end
      end
    end
  end
end
