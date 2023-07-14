# frozen_string_literal: true

require "rails_helper"

RSpec.describe Packages::TransmissionsController do
  it { expect(get:    "/paquets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/approval").to route_to("packages/approvals#show", package_id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(post:   "/paquets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/approval").to be_unroutable }
  it { expect(patch:  "/paquets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/approval").to route_to("packages/approvals#update", package_id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(delete: "/paquets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/approval").to route_to("packages/approvals#destroy", package_id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }

  it { expect(get:    "/paquets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/approval/new").to       be_unroutable }
  it { expect(get:    "/paquets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/approval/edit").to      be_unroutable }
  it { expect(get:    "/paquets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/approval/remove").to    be_unroutable }
  it { expect(get:    "/paquets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/approval/undiscard").to be_unroutable }
  it { expect(patch:  "/paquets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/approval/undiscard").to be_unroutable }

  it { expect(get:    "/paquets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/approval/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
  it { expect(post:   "/paquets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/approval/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
  it { expect(patch:  "/paquets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/approval/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
  it { expect(delete: "/paquets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/approval/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }

  it { expect(get:    "/paquets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/approval/b12170f4-0827-48f2-9e25-e1154c354bb6/edit").to      be_unroutable }
  it { expect(get:    "/paquets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/approval/b12170f4-0827-48f2-9e25-e1154c354bb6/remove").to    be_unroutable }
  it { expect(get:    "/paquets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/approval/b12170f4-0827-48f2-9e25-e1154c354bb6/undiscard").to be_unroutable }
  it { expect(patch:  "/paquets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/approval/b12170f4-0827-48f2-9e25-e1154c354bb6/undiscard").to be_unroutable }
end
