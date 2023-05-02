# frozen_string_literal: true

require "rails_helper"

RSpec.describe DdfipsController do
  it { expect(get:    "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs").to be_unroutable }
  it { expect(post:   "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs").to be_unroutable }
  it { expect(patch:  "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs").to route_to("office_users#update", office_id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(delete: "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs").to be_unroutable }

  it { expect(get:    "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs/new").to       be_unroutable }
  it { expect(get:    "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs/edit").to      route_to("office_users#edit", office_id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(get:    "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs/remove").to    be_unroutable }
  it { expect(get:    "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs/undiscard").to be_unroutable }
  it { expect(patch:  "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs/undiscard").to be_unroutable }

  it { expect(get:    "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
  it { expect(post:   "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
  it { expect(patch:  "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
  it { expect(delete: "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs/b12170f4-0827-48f2-9e25-e1154c354bb6").to route_to("office_users#destroy", office_id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7", id: "b12170f4-0827-48f2-9e25-e1154c354bb6") }

  it { expect(get:    "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs/b12170f4-0827-48f2-9e25-e1154c354bb6/edit").to      be_unroutable }
  it { expect(get:    "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs/b12170f4-0827-48f2-9e25-e1154c354bb6/remove").to    route_to("office_users#remove", office_id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7", id: "b12170f4-0827-48f2-9e25-e1154c354bb6") }
  it { expect(get:    "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs/b12170f4-0827-48f2-9e25-e1154c354bb6/undiscard").to be_unroutable }
  it { expect(patch:  "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs/b12170f4-0827-48f2-9e25-e1154c354bb6/undiscard").to be_unroutable }
end
