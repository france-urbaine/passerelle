# frozen_string_literal: true

require "rails_helper"

RSpec.describe NotificationComponent, type: :component do
  subject(:component) { described_class.new(data) }

  let(:data) { "Hello world !" }

  before do
    render_inline(component)
  end

  it { expect(page).to have_selector(%(.notification[role="alert"][aria-live="polite"])) }
  it { expect(rendered_content).to include(%(<svg class="notification__icon">)) }
  it { expect(rendered_content).to include(%(<div class="notification__title">Hello world !</div>)) }

  context "with a hash argument" do
    let(:data) do
      {
        type:        "error",
        title:       "Une erreur s'est produite.",
        description: "Notre équipe a été notifiée.\nVeuillez rééssayer plus tard !",
        delay:       3000
      }
    end

    it { expect(page).to have_selector(%(.notification[role="alert"][aria-live="polite"])) }
    it { expect(rendered_content).to include(%(<svg class="notification__icon notification__icon--error">)) }
    it { expect(rendered_content).to include(%(<div class="notification__title">Une erreur s&#39;est produite.</div>)) }
    it { expect(rendered_content).to include(%(<p>Notre équipe a été notifiée.\n<br />Veuillez rééssayer plus tard !</p>)) }
  end
end
