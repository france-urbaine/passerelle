# frozen_string_literal: true

require "rails_helper"

RSpec.describe EpcisController do
  it { expect(get:    "/epcis").to route_to("epcis#index") }
  it { expect(post:   "/epcis").to be_unroutable }
  it { expect(patch:  "/epcis").to be_unroutable }
  it { expect(delete: "/epcis").to be_unroutable }

  it { expect(get:    "/epcis/new").to       be_unroutable }
  it { expect(get:    "/epcis/edit").to      be_unroutable }
  it { expect(get:    "/epcis/remove").to    be_unroutable }
  it { expect(get:    "/epcis/undiscard").to be_unroutable }
  it { expect(patch:  "/epcis/undiscard").to be_unroutable }

  it { expect(get:    "/epcis/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to route_to("epcis#show", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(post:   "/epcis/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to be_unroutable }
  it { expect(patch:  "/epcis/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to route_to("epcis#update", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(delete: "/epcis/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to be_unroutable }

  it { expect(get:    "/epcis/9c6c00c4-0784-4ef8-8978-b1e0246882a7/edit").to      route_to("epcis#edit", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(get:    "/epcis/9c6c00c4-0784-4ef8-8978-b1e0246882a7/remove").to    be_unroutable }
  it { expect(get:    "/epcis/9c6c00c4-0784-4ef8-8978-b1e0246882a7/undiscard").to be_unroutable }
  it { expect(patch:  "/epcis/9c6c00c4-0784-4ef8-8978-b1e0246882a7/undiscard").to be_unroutable }
end
