# frozen_string_literal: true

require "rails_helper"

RSpec.describe PublishersController, type: :routing do
  it { expect(get:    "/editeurs").to     route_to("publishers#index") }
  it { expect(post:   "/editeurs").to     route_to("publishers#create") }
  it { expect(patch:  "/editeurs").not_to be_routable }
  it { expect(delete: "/editeurs").not_to be_routable }

  it { expect(get:    "/editeurs/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to     route_to("publishers#show", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(post:   "/editeurs/9c6c00c4-0784-4ef8-8978-b1e0246882a7").not_to be_routable }
  it { expect(patch:  "/editeurs/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to     route_to("publishers#update", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(delete: "/editeurs/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to     route_to("publishers#destroy", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }

  it { expect(get:    "/editeurs/new").to                                       route_to("publishers#new") }
  it { expect(get:    "/editeurs/9c6c00c4-0784-4ef8-8978-b1e0246882a7/edit").to route_to("publishers#edit", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
end
