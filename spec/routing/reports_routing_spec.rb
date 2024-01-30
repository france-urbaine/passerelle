# frozen_string_literal: true

require "rails_helper"

RSpec.describe ReportsController do
  it { expect(get:    "/signalements").to route_to("reports#index") }
  it { expect(post:   "/signalements").to route_to("reports#create") }
  it { expect(patch:  "/signalements").to be_unroutable }
  it { expect(delete: "/signalements").to route_to("reports#destroy_all") }

  it { expect(get:    "/signalements/new").to       route_to("reports#new") }
  it { expect(get:    "/signalements/edit").to      be_unroutable }
  it { expect(get:    "/signalements/remove").to    route_to("reports#remove_all") }
  it { expect(get:    "/signalements/undiscard").to be_unroutable }
  it { expect(patch:  "/signalements/undiscard").to route_to("reports#undiscard_all") }

  it { expect(get:    "/signalements/9c6c00c4").to route_to("reports#show", id: "9c6c00c4") }
  it { expect(post:   "/signalements/9c6c00c4").to be_unroutable }
  it { expect(patch:  "/signalements/9c6c00c4").to route_to("reports#update", id: "9c6c00c4") }
  it { expect(delete: "/signalements/9c6c00c4").to route_to("reports#destroy", id: "9c6c00c4") }

  it { expect(get:    "/signalements/9c6c00c4/edit").to      be_unroutable }
  it { expect(get:    "/signalements/9c6c00c4/remove").to    route_to("reports#remove", id: "9c6c00c4") }
  it { expect(get:    "/signalements/9c6c00c4/undiscard").to be_unroutable }
  it { expect(patch:  "/signalements/9c6c00c4/undiscard").to route_to("reports#undiscard", id: "9c6c00c4") }

  it { expect(get:    "/signalements/9c6c00c4/edit/situation_majic").to route_to("reports#edit", id: "9c6c00c4", form: "situation_majic") }
  it { expect(get:    "/signalements/9c6c00c4/edit/unknown").to         route_to("reports#edit", id: "9c6c00c4", form: "unknown") }
end
