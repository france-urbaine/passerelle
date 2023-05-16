# frozen_string_literal: true

require "rails_helper"

RSpec.describe TemplateFrame::Component, type: :component do
  it "renders main content frame from a block" do
    render_inline described_class.new do
      tag.p "Hello World"
    end

    expect(page).to have_selector("main.content > turbo-frame") do |node|
      expect(node).to have_selector("p", text: "Hello World")
    end
  end

  it "renders main content with an asynchronous location" do
    render_inline described_class.new(src: "/communes")

    expect(page).to have_selector("main.content > turbo-frame[src='/communes']")
  end

  it "renders modal content" do
    render_inline described_class.new do |frame|
      frame.with_modal do |modal|
        modal.with_header("Dialog header")
        modal.with_body("Hello World")
      end
    end

    expect(page).to have_selector("main.content > turbo-frame:empty")
    expect(page).to have_selector("turbo-frame#modal > .modal > .modal__content > .modal__header", text: "Dialog header")
    expect(page).to have_selector("turbo-frame#modal > .modal > .modal__content > .modal__body", text: "Hello World")
  end

  it "renders modal with an asynchronous location" do
    render_inline described_class.new do |frame|
      frame.with_modal(src: "/communes")
    end

    expect(page).to have_selector("main.content > turbo-frame:empty")
    expect(page).to have_selector("turbo-frame#modal[src='/communes']")
  end

  it "allows to render component without modal wrappers" do
    # This test aims to verify we can use explicit modal component without rendering it twice,
    # but it seems we cannot render another component using ViewComponent::TestHelpers
    #
    #   = template_frame_component do |frame|
    #     - frame.with_modal do
    #       = modal_component do
    #         p Hello World !
    #
    render_inline described_class.new do |frame|
      frame.with_modal do
        tag.p "Hello World"
      end
    end

    expect(page).to have_selector("main.content > turbo-frame:empty")
    expect(page).to have_selector("turbo-frame#modal") do |node|
      expect(node).not_to have_selector(".modal")
      expect(node).to have_selector("p", text: "Hello World")
    end
  end
end
