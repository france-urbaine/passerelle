# frozen_string_literal: true

require "rails_helper"

RSpec.describe DialogComponent, type: :component do
  subject(:component) { described_class.new }

  before do
    render_inline(component) do
      %(<div class="dialog__content">Hello World!</div>).html_safe
    end
  end

  it { expect(page).to have_selector(%(.dialog[role="dialog"][aria-modal="true"])) }
  it { expect(page).to have_selector(%(.dialog__content), text: "Hello World!") }
end
