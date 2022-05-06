# frozen_string_literal: true

require "rails_helper"

RSpec.describe PublishersController, type: :routing do
  it { expect(get:    "/publishers").to     route_to("publishers#index") }
  it { expect(post:   "/publishers").to     route_to("publishers#create") }
  it { expect(patch:  "/publishers").not_to be_routable }
  it { expect(delete: "/publishers").not_to be_routable }

  it { expect(get:    "/publishers/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to     route_to("publishers#show", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(post:   "/publishers/9c6c00c4-0784-4ef8-8978-b1e0246882a7").not_to be_routable }
  it { expect(patch:  "/publishers/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to     route_to("publishers#update", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(delete: "/publishers/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to     route_to("publishers#destroy", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }

  it { expect(get:    "/publishers/new").to                                       route_to("publishers#new") }
  it { expect(get:    "/publishers/9c6c00c4-0784-4ef8-8978-b1e0246882a7/edit").to route_to("publishers#edit", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
end
