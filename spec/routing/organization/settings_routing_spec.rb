# frozen_string_literal: true

require "rails_helper"

RSpec.describe Organization::SettingsController do
  it { expect(get:    "/organisation/parametres").to route_to("organization/settings#show") }
  it { expect(post:   "/organisation/parametres").to be_unroutable }
  it { expect(patch:  "/organisation/parametres").to route_to("organization/settings#update") }
  it { expect(delete: "/organisation/parametres").to be_unroutable }

  it { expect(get:    "/organisation/parametres/new").to       be_unroutable }
  it { expect(get:    "/organisation/parametres/edit").to      be_unroutable }
  it { expect(get:    "/organisation/parametres/remove").to    be_unroutable }
  it { expect(get:    "/organisation/parametres/undiscard").to be_unroutable }

  it { expect(get:    "/organisation/parametres/b12170f4").to be_unroutable }
  it { expect(post:   "/organisation/parametres/b12170f4").to be_unroutable }
  it { expect(patch:  "/organisation/parametres/b12170f4").to be_unroutable }
  it { expect(delete: "/organisation/parametres/b12170f4").to be_unroutable }
end
