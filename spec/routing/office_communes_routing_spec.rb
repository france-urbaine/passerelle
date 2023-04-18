# frozen_string_literal: true

require "rails_helper"

RSpec.describe DdfipsController do
  it { expect(get:    "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/communes").to be_unroutable }
  it { expect(post:   "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/communes").to be_unroutable }
  it { expect(patch:  "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/communes").to route_to("office_communes#update", office_id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(delete: "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/communes").to be_unroutable }

  it { expect(get:    "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/communes/new").to       be_unroutable }
  it { expect(get:    "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/communes/edit").to      route_to("office_communes#edit", office_id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(get:    "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/communes/remove").to    be_unroutable }
  it { expect(get:    "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/communes/undiscard").to be_unroutable }
  it { expect(patch:  "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/communes/undiscard").to be_unroutable }

  it { expect(get:    "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/communes/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
  it { expect(post:   "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/communes/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
  it { expect(patch:  "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/communes/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
  it { expect(delete: "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/communes/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
end
