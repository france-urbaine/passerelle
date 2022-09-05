# frozen_string_literal: true

require "rails_helper"

RSpec.describe DdfipsController, type: :routing do
  it { expect(get:    "/guichets").to     route_to("services#index") }
  it { expect(post:   "/guichets").to     route_to("services#create") }
  it { expect(patch:  "/guichets").not_to be_routable }
  it { expect(delete: "/guichets").to     route_to("services#destroy_all") }

  it { expect(get:    "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to     route_to("services#show", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(post:   "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7").not_to be_routable }
  it { expect(patch:  "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to     route_to("services#update", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(delete: "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to     route_to("services#destroy", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }

  it { expect(get:    "/guichets/new").to                                         route_to("services#new") }
  it { expect(get:    "/guichets/remove").to                                      route_to("services#remove_all") }
  it { expect(get:    "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/edit").to   route_to("services#edit", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(get:    "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/remove").to route_to("services#remove", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }

  it { expect(patch:  "/guichets/undiscard").to                                      route_to("services#undiscard_all") }
  it { expect(patch:  "/guichets/9c6c00c4-0784-4ef8-8978-b1e0246882a7/undiscard").to route_to("services#undiscard", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
end
