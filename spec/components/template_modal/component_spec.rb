# frozen_string_literal: true

require "rails_helper"

RSpec.describe TemplateModal::Component, type: :component do
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

    aggregate_failures do
      within "turbo-frame#modal > .modal > .modal__content > .modal__body" do |node|
        expect(node).to have_link(class: "icon-button", href: "/home/root")
      end

      within "turbo-frame#modal > .modal > .modal__content > .modal__actions" do |node|
        expect(node).to have_link("Close", class: "button", href: "/home/root")
      end
    end
  end
end
