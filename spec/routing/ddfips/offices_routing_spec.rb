# frozen_string_literal: true

require "rails_helper"

RSpec.describe DDFIPs::OfficesController do
  it { expect(get:    "/ddfips/9c6c00c4-0784-4ef8-8978-b1e0246882a7/guichets").to route_to("ddfips/offices#index", ddfip_id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(post:   "/ddfips/9c6c00c4-0784-4ef8-8978-b1e0246882a7/guichets").to route_to("ddfips/offices#create", ddfip_id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(patch:  "/ddfips/9c6c00c4-0784-4ef8-8978-b1e0246882a7/guichets").to be_unroutable }
  it { expect(delete: "/ddfips/9c6c00c4-0784-4ef8-8978-b1e0246882a7/guichets").to route_to("ddfips/offices#destroy_all", ddfip_id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }

  it { expect(get:    "/ddfips/9c6c00c4-0784-4ef8-8978-b1e0246882a7/guichets/new").to       route_to("ddfips/offices#new", ddfip_id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(get:    "/ddfips/9c6c00c4-0784-4ef8-8978-b1e0246882a7/guichets/edit").to      be_unroutable }
  it { expect(get:    "/ddfips/9c6c00c4-0784-4ef8-8978-b1e0246882a7/guichets/remove").to    route_to("ddfips/offices#remove_all", ddfip_id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(get:    "/ddfips/9c6c00c4-0784-4ef8-8978-b1e0246882a7/guichets/undiscard").to be_unroutable }
  it { expect(patch:  "/ddfips/9c6c00c4-0784-4ef8-8978-b1e0246882a7/guichets/undiscard").to route_to("ddfips/offices#undiscard_all", ddfip_id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }

  it { expect(get:    "/ddfips/9c6c00c4-0784-4ef8-8978-b1e0246882a7/guichets/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
  it { expect(post:   "/ddfips/9c6c00c4-0784-4ef8-8978-b1e0246882a7/guichets/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
  it { expect(patch:  "/ddfips/9c6c00c4-0784-4ef8-8978-b1e0246882a7/guichets/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
  it { expect(delete: "/ddfips/9c6c00c4-0784-4ef8-8978-b1e0246882a7/guichets/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }

  it { expect(get:    "/ddfips/9c6c00c4-0784-4ef8-8978-b1e0246882a7/guichets/b12170f4-0827-48f2-9e25-e1154c354bb6/edit").to      be_unroutable }
  it { expect(get:    "/ddfips/9c6c00c4-0784-4ef8-8978-b1e0246882a7/guichets/b12170f4-0827-48f2-9e25-e1154c354bb6/remove").to    be_unroutable }
  it { expect(get:    "/ddfips/9c6c00c4-0784-4ef8-8978-b1e0246882a7/guichets/b12170f4-0827-48f2-9e25-e1154c354bb6/undiscard").to be_unroutable }
  it { expect(patch:  "/ddfips/9c6c00c4-0784-4ef8-8978-b1e0246882a7/guichets/b12170f4-0827-48f2-9e25-e1154c354bb6/undiscard").to be_unroutable }
end
