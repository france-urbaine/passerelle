# frozen_string_literal: true

require "rails_helper"

RSpec.describe DdfipsController, type: :routing do
  it { expect(get:    "/ddfips").to     route_to("ddfips#index") }
  it { expect(post:   "/ddfips").to     route_to("ddfips#create") }
  it { expect(patch:  "/ddfips").not_to be_routable }
  it { expect(delete: "/ddfips").not_to be_routable }

  it { expect(get:    "/ddfips/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to     route_to("ddfips#show", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(post:   "/ddfips/9c6c00c4-0784-4ef8-8978-b1e0246882a7").not_to be_routable }
  it { expect(patch:  "/ddfips/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to     route_to("ddfips#update", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(delete: "/ddfips/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to     route_to("ddfips#destroy", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }

  it { expect(get:    "/ddfips/new").to                                       route_to("ddfips#new") }
  it { expect(get:    "/ddfips/9c6c00c4-0784-4ef8-8978-b1e0246882a7/edit").to route_to("ddfips#edit", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
end
