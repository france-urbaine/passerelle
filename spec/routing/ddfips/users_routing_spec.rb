# frozen_string_literal: true

require "rails_helper"

RSpec.describe DDFIPs::UsersController do
  it { expect(get:    "/ddfips/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs").to route_to("ddfips/users#index", ddfip_id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(post:   "/ddfips/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs").to route_to("ddfips/users#create", ddfip_id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(patch:  "/ddfips/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs").to be_unroutable }
  it { expect(delete: "/ddfips/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs").to route_to("ddfips/users#destroy_all", ddfip_id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }

  it { expect(get:    "/ddfips/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs/new").to       route_to("ddfips/users#new", ddfip_id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(get:    "/ddfips/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs/edit").to      be_unroutable }
  it { expect(get:    "/ddfips/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs/remove").to    route_to("ddfips/users#remove_all", ddfip_id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(get:    "/ddfips/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs/undiscard").to be_unroutable }
  it { expect(patch:  "/ddfips/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs/undiscard").to route_to("ddfips/users#undiscard_all", ddfip_id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }

  it { expect(get:    "/ddfips/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
  it { expect(post:   "/ddfips/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
  it { expect(patch:  "/ddfips/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
  it { expect(delete: "/ddfips/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }

  it { expect(get:    "/ddfips/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs/b12170f4-0827-48f2-9e25-e1154c354bb6/edit").to      be_unroutable }
  it { expect(get:    "/ddfips/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs/b12170f4-0827-48f2-9e25-e1154c354bb6/remove").to    be_unroutable }
  it { expect(get:    "/ddfips/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs/b12170f4-0827-48f2-9e25-e1154c354bb6/undiscard").to be_unroutable }
  it { expect(patch:  "/ddfips/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs/b12170f4-0827-48f2-9e25-e1154c354bb6/undiscard").to be_unroutable }
end
