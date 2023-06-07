# frozen_string_literal: true

require "rails_helper"

RSpec.describe PackagesController do
  it { expect(get:    "/paquets").to route_to("packages#index") }
  it { expect(post:   "/paquets").to be_unroutable }
  it { expect(patch:  "/paquets").to be_unroutable }
  it { expect(delete: "/paquets").to be_unroutable }

  it { expect(get:    "/paquets/new").to       be_unroutable }
  it { expect(get:    "/paquets/edit").to      be_unroutable }
  it { expect(get:    "/paquets/remove").to    be_unroutable }
  it { expect(get:    "/paquets/undiscard").to be_unroutable }
  it { expect(patch:  "/paquets/undiscard").to be_unroutable }

  it { expect(get:    "/paquets/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to route_to("packages#show", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(post:   "/paquets/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to be_unroutable }
  it { expect(patch:  "/paquets/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to be_unroutable }
  it { expect(delete: "/paquets/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to be_unroutable }
end
