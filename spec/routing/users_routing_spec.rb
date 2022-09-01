# frozen_string_literal: true

require "rails_helper"

RSpec.describe UsersController, type: :routing do
  it { expect(get:    "/utilisateurs").to     route_to("users#index") }
  it { expect(post:   "/utilisateurs").to     route_to("users#create") }
  it { expect(patch:  "/utilisateurs").not_to be_routable }
  it { expect(delete: "/utilisateurs").not_to be_routable }

  it { expect(get:    "/utilisateurs/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to     route_to("users#show", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(post:   "/utilisateurs/9c6c00c4-0784-4ef8-8978-b1e0246882a7").not_to be_routable }
  it { expect(patch:  "/utilisateurs/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to     route_to("users#update", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(delete: "/utilisateurs/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to     route_to("users#destroy", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }

  it { expect(get:    "/utilisateurs/new").to                                       route_to("users#new") }
  it { expect(get:    "/utilisateurs/9c6c00c4-0784-4ef8-8978-b1e0246882a7/edit").to route_to("users#edit", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
end
