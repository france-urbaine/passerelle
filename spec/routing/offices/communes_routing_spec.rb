# frozen_string_literal: true

require "rails_helper"

RSpec.describe Offices::CommunesController do
  it { expect(get:    "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/communes").to route_to("offices/communes#index", office_id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(post:   "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/communes").to be_unroutable }
  it { expect(patch:  "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/communes").to route_to("offices/communes#update_all", office_id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(delete: "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/communes").to route_to("offices/communes#destroy_all", office_id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }

  it { expect(get:    "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/communes/new").to       be_unroutable }
  it { expect(get:    "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/communes/edit").to      route_to("offices/communes#edit_all", office_id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(get:    "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/communes/remove").to    route_to("offices/communes#remove_all", office_id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(get:    "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/communes/undiscard").to be_unroutable }
  it { expect(patch:  "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/communes/undiscard").to be_unroutable }

  it { expect(get:    "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/communes/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
  it { expect(post:   "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/communes/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
  it { expect(patch:  "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/communes/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
  it { expect(delete: "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/communes/b12170f4-0827-48f2-9e25-e1154c354bb6").to route_to("offices/communes#destroy", office_id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7", id: "b12170f4-0827-48f2-9e25-e1154c354bb6") }

  it { expect(get:    "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/communes/b12170f4-0827-48f2-9e25-e1154c354bb6/edit").to      be_unroutable }
  it { expect(get:    "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/communes/b12170f4-0827-48f2-9e25-e1154c354bb6/remove").to    route_to("offices/communes#remove", office_id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7", id: "b12170f4-0827-48f2-9e25-e1154c354bb6") }
  it { expect(get:    "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/communes/b12170f4-0827-48f2-9e25-e1154c354bb6/undiscard").to be_unroutable }
  it { expect(patch:  "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/communes/b12170f4-0827-48f2-9e25-e1154c354bb6/undiscard").to be_unroutable }
end
