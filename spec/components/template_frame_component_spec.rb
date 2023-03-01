# frozen_string_literal: true

require "rails_helper"

RSpec.describe TemplateFrameComponent, type: :component do
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
      frame.with_modal do
        tag.p "Hello World"
      end
    end

    expect(page).to have_selector("main.content > turbo-frame:empty")
    expect(page).to have_selector("turbo-frame#modal > .modal > .modal__container") do |node|
      expect(node).to have_selector("p", text: "Hello World")
    end
  end

  it "renders modal with an asynchronous location" do
    render_inline described_class.new do |frame|
      frame.with_modal(src: "/communes")
    end

    expect(page).to have_selector("main.content > turbo-frame:empty")
    expect(page).to have_selector("turbo-frame#modal[src='/communes']")
  end

  it "avoids to render modal component twice" do
    render_inline described_class.new do |frame|
      frame.with_modal do |modal|
        modal.with_content do
          tag.p "Hello World"
        end
      end
    end

    expect(page).to have_selector("main.content > turbo-frame:empty")
    expect(page).to have_selector("turbo-frame#modal > .modal > .modal__container") do |node|
      expect(node).not_to have_selector(".modal")
      expect(node).to have_selector("p", text: "Hello World")
    end
  end
end
