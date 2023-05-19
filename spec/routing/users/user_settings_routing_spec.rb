# frozen_string_literal: true

require "rails_helper"

RSpec.describe Users::UserSettingsController do
  it { expect(get:    "/compte/parametres").to route_to("users/user_settings#show") }
  it { expect(post:   "/compte/parametres").to be_unroutable }
  it { expect(patch:  "/compte/parametres").to route_to("users/user_settings#update") }
  it { expect(delete: "/compte/parametres").to be_unroutable }

  it { expect(get:    "/compte/parametres/new").to       be_unroutable }
  it { expect(get:    "/compte/parametres/edit").to      be_unroutable }
  it { expect(get:    "/compte/parametres/remove").to    be_unroutable }
  it { expect(get:    "/compte/parametres/undiscard").to be_unroutable }

  it { expect(get:    "/compte/parametres/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
  it { expect(post:   "/compte/parametres/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
  it { expect(patch:  "/compte/parametres/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
  it { expect(delete: "/compte/parametres/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
end
