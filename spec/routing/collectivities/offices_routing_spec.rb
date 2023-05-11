# frozen_string_literal: true

require "rails_helper"

RSpec.describe Collectivities::OfficesController do
  it { expect(get:    "/collectivites/9c6c00c4-0784-4ef8-8978-b1e0246882a7/guichets").to route_to("collectivities/offices#index", collectivity_id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(post:   "/collectivites/9c6c00c4-0784-4ef8-8978-b1e0246882a7/guichets").to be_unroutable }
  it { expect(patch:  "/collectivites/9c6c00c4-0784-4ef8-8978-b1e0246882a7/guichets").to be_unroutable }
  it { expect(delete: "/collectivites/9c6c00c4-0784-4ef8-8978-b1e0246882a7/guichets").to be_unroutable }

  it { expect(get:    "/collectivites/9c6c00c4-0784-4ef8-8978-b1e0246882a7/guichets/new").to       be_unroutable }
  it { expect(get:    "/collectivites/9c6c00c4-0784-4ef8-8978-b1e0246882a7/guichets/edit").to      be_unroutable }
  it { expect(get:    "/collectivites/9c6c00c4-0784-4ef8-8978-b1e0246882a7/guichets/remove").to    be_unroutable }
  it { expect(get:    "/collectivites/9c6c00c4-0784-4ef8-8978-b1e0246882a7/guichets/undiscard").to be_unroutable }
  it { expect(patch:  "/collectivites/9c6c00c4-0784-4ef8-8978-b1e0246882a7/guichets/undiscard").to be_unroutable }

  it { expect(get:    "/collectivites/9c6c00c4-0784-4ef8-8978-b1e0246882a7/guichets/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
  it { expect(post:   "/collectivites/9c6c00c4-0784-4ef8-8978-b1e0246882a7/guichets/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
  it { expect(patch:  "/collectivites/9c6c00c4-0784-4ef8-8978-b1e0246882a7/guichets/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
  it { expect(delete: "/collectivites/9c6c00c4-0784-4ef8-8978-b1e0246882a7/guichets/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }

  it { expect(get:    "/collectivites/9c6c00c4-0784-4ef8-8978-b1e0246882a7/guichets/b12170f4-0827-48f2-9e25-e1154c354bb6/edit").to      be_unroutable }
  it { expect(get:    "/collectivites/9c6c00c4-0784-4ef8-8978-b1e0246882a7/guichets/b12170f4-0827-48f2-9e25-e1154c354bb6/remove").to    be_unroutable }
  it { expect(get:    "/collectivites/9c6c00c4-0784-4ef8-8978-b1e0246882a7/guichets/b12170f4-0827-48f2-9e25-e1154c354bb6/undiscard").to be_unroutable }
  it { expect(patch:  "/collectivites/9c6c00c4-0784-4ef8-8978-b1e0246882a7/guichets/b12170f4-0827-48f2-9e25-e1154c354bb6/undiscard").to be_unroutable }
end
