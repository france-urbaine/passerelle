# frozen_string_literal: true

require "rails_helper"

RSpec.describe DdfipsController do
  it { expect(get:    "/guichets").to route_to("offices#index") }
  it { expect(post:   "/guichets").to route_to("offices#create") }
  it { expect(patch:  "/guichets").to be_unroutable }
  it { expect(delete: "/guichets").to route_to("offices#destroy_all") }

  it { expect(get:    "/guichets/new").to       route_to("offices#new") }
  it { expect(get:    "/guichets/edit").to      be_unroutable }
  it { expect(get:    "/guichets/remove").to    route_to("offices#remove_all") }
  it { expect(get:    "/guichets/undiscard").to be_unroutable }
  it { expect(patch:  "/guichets/undiscard").to route_to("offices#undiscard_all") }

  it { expect(get:    "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to route_to("offices#show", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(post:   "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to be_unroutable }
  it { expect(patch:  "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to route_to("offices#update", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(delete: "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to route_to("offices#destroy", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }

  it { expect(get:    "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/edit").to      route_to("offices#edit", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(get:    "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/remove").to    route_to("offices#remove", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(get:    "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/undiscard").to be_unroutable }
  it { expect(patch:  "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/undiscard").to route_to("offices#undiscard", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
end
