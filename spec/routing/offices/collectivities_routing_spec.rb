# frozen_string_literal: true

require "rails_helper"

RSpec.describe Offices::CollectivitiesController do
  it { expect(get:    "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/collectivites").to route_to("offices/collectivities#index", office_id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(post:   "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/collectivites").to be_unroutable }
  it { expect(patch:  "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/collectivites").to be_unroutable }
  it { expect(delete: "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/collectivites").to be_unroutable }

  it { expect(get:    "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/collectivites/new").to       be_unroutable }
  it { expect(get:    "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/collectivites/edit").to      be_unroutable }
  it { expect(get:    "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/collectivites/remove").to    be_unroutable }
  it { expect(get:    "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/collectivites/undiscard").to be_unroutable }
  it { expect(patch:  "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/collectivites/undiscard").to be_unroutable }

  it { expect(get:    "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/collectivites/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
  it { expect(post:   "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/collectivites/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
  it { expect(patch:  "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/collectivites/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
  it { expect(delete: "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/collectivites/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }

  it { expect(get:    "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/collectivites/b12170f4-0827-48f2-9e25-e1154c354bb6/edit").to      be_unroutable }
  it { expect(get:    "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/collectivites/b12170f4-0827-48f2-9e25-e1154c354bb6/remove").to    be_unroutable }
  it { expect(get:    "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/collectivites/b12170f4-0827-48f2-9e25-e1154c354bb6/undiscard").to be_unroutable }
  it { expect(patch:  "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/collectivites/b12170f4-0827-48f2-9e25-e1154c354bb6/undiscard").to be_unroutable }
end
