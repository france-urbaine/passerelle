# frozen_string_literal: true

require "rails_helper"

RSpec.describe Packages::ReportsController do
  it { expect(get:    "/paquets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/signalements").to route_to("packages/reports#index", package_id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(post:   "/paquets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/signalements").to be_unroutable }
  it { expect(patch:  "/paquets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/signalements").to be_unroutable }
  it { expect(delete: "/paquets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/signalements").to route_to("packages/reports#destroy_all", package_id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }

  it { expect(get:    "/paquets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/signalements/new").to       be_unroutable }
  it { expect(get:    "/paquets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/signalements/edit").to      be_unroutable }
  it { expect(get:    "/paquets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/signalements/remove").to    route_to("packages/reports#remove_all", package_id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(get:    "/paquets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/signalements/undiscard").to be_unroutable }
  it { expect(patch:  "/paquets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/signalements/undiscard").to route_to("packages/reports#undiscard_all", package_id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }

  it { expect(get:    "/paquets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/signalements/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
  it { expect(post:   "/paquets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/signalements/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
  it { expect(patch:  "/paquets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/signalements/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
  it { expect(delete: "/paquets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/signalements/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }

  it { expect(get:    "/paquets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/signalements/b12170f4-0827-48f2-9e25-e1154c354bb6/edit").to      be_unroutable }
  it { expect(get:    "/paquets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/signalements/b12170f4-0827-48f2-9e25-e1154c354bb6/remove").to    be_unroutable }
  it { expect(get:    "/paquets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/signalements/b12170f4-0827-48f2-9e25-e1154c354bb6/undiscard").to be_unroutable }
  it { expect(patch:  "/paquets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/signalements/b12170f4-0827-48f2-9e25-e1154c354bb6/undiscard").to be_unroutable }
end
