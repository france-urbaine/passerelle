# frozen_string_literal: true

require "rails_helper"

RSpec.describe Publishers::UsersController do
  it { expect(get:    "/editeurs/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs").to route_to("publishers/users#index", publisher_id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(post:   "/editeurs/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs").to route_to("publishers/users#create", publisher_id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(patch:  "/editeurs/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs").to be_unroutable }
  it { expect(delete: "/editeurs/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs").to route_to("publishers/users#destroy_all", publisher_id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }

  it { expect(get:    "/editeurs/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs/new").to       route_to("publishers/users#new", publisher_id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(get:    "/editeurs/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs/edit").to      be_unroutable }
  it { expect(get:    "/editeurs/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs/remove").to    route_to("publishers/users#remove_all", publisher_id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(get:    "/editeurs/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs/undiscard").to be_unroutable }
  it { expect(patch:  "/editeurs/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs/undiscard").to route_to("publishers/users#undiscard_all", publisher_id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }

  it { expect(get:    "/editeurs/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
  it { expect(post:   "/editeurs/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
  it { expect(patch:  "/editeurs/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
  it { expect(delete: "/editeurs/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }

  it { expect(get:    "/editeurs/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs/b12170f4-0827-48f2-9e25-e1154c354bb6/edit").to      be_unroutable }
  it { expect(get:    "/editeurs/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs/b12170f4-0827-48f2-9e25-e1154c354bb6/remove").to    be_unroutable }
  it { expect(get:    "/editeurs/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs/b12170f4-0827-48f2-9e25-e1154c354bb6/undiscard").to be_unroutable }
  it { expect(patch:  "/editeurs/9c6c00c4-0784-4ef8-8978-b1e0246882a7/utilisateurs/b12170f4-0827-48f2-9e25-e1154c354bb6/undiscard").to be_unroutable }
end
