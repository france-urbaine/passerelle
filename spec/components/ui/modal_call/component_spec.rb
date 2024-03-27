# frozen_string_literal: true

require "rails_helper"

RSpec.describe UI::ModalCall::Component do
  it "renders a button to open a modal" do
    render_inline described_class.new do |call|
      call.with_button("Click here")
      call.with_modal do
        tag.p "Hello World"
      end
    end

    expect(page).to have_selector("div[data-controller='modal-call']")
  end
end
