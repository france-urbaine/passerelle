# frozen_string_literal: true

require "rails_helper"

RSpec.describe CommunesController do
  it { expect(get:    "/communes").to route_to("communes#index") }
  it { expect(post:   "/communes").to be_unroutable }
  it { expect(patch:  "/communes").to be_unroutable }
  it { expect(delete: "/communes").to be_unroutable }

  it { expect(get:    "/communes/new").to       be_unroutable }
  it { expect(get:    "/communes/edit").to      be_unroutable }
  it { expect(get:    "/communes/remove").to    be_unroutable }
  it { expect(get:    "/communes/undiscard").to be_unroutable }
  it { expect(patch:  "/communes/undiscard").to be_unroutable }

  it { expect(get:    "/communes/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to route_to("communes#show", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(post:   "/communes/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to be_unroutable }
  it { expect(patch:  "/communes/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to route_to("communes#update", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(delete: "/communes/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to be_unroutable }

  it { expect(get:    "/communes/9c6c00c4-0784-4ef8-8978-b1e0246882a7/edit").to      route_to("communes#edit", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(get:    "/communes/9c6c00c4-0784-4ef8-8978-b1e0246882a7/remove").to    be_unroutable }
  it { expect(get:    "/communes/9c6c00c4-0784-4ef8-8978-b1e0246882a7/undiscard").to be_unroutable }
  it { expect(patch:  "/communes/9c6c00c4-0784-4ef8-8978-b1e0246882a7/undiscard").to be_unroutable }
end
