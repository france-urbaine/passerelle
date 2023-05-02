# frozen_string_literal: true

require "rails_helper"

RSpec.describe UsersController do
  it { expect(get:    "/utilisateurs").to route_to("users#index") }
  it { expect(post:   "/utilisateurs").to route_to("users#create") }
  it { expect(patch:  "/utilisateurs").to be_unroutable }
  it { expect(delete: "/utilisateurs").to route_to("users#destroy_all") }

  it { expect(get:    "/utilisateurs/new").to       route_to("users#new") }
  it { expect(get:    "/utilisateurs/edit").to      be_unroutable }
  it { expect(get:    "/utilisateurs/remove").to    route_to("users#remove_all") }
  it { expect(get:    "/utilisateurs/undiscard").to be_unroutable }
  it { expect(patch:  "/utilisateurs/undiscard").to route_to("users#undiscard_all") }

  it { expect(get:    "/utilisateurs/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to route_to("users#show", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(post:   "/utilisateurs/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to be_unroutable }
  it { expect(patch:  "/utilisateurs/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to route_to("users#update", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(delete: "/utilisateurs/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to route_to("users#destroy", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }

  it { expect(get:    "/utilisateurs/9c6c00c4-0784-4ef8-8978-b1e0246882a7/edit").to      route_to("users#edit", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(get:    "/utilisateurs/9c6c00c4-0784-4ef8-8978-b1e0246882a7/remove").to    route_to("users#remove", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(get:    "/utilisateurs/9c6c00c4-0784-4ef8-8978-b1e0246882a7/undiscard").to be_unroutable }
  it { expect(patch:  "/utilisateurs/9c6c00c4-0784-4ef8-8978-b1e0246882a7/undiscard").to route_to("users#undiscard", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
end
