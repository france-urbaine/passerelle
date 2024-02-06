# frozen_string_literal: true

require "rails_helper"

RSpec.describe ReportsController do
  let(:id) { SecureRandom.uuid }

  it { expect(get:    "/signalements").to route_to("reports#index") }
  it { expect(post:   "/signalements").to route_to("reports#create") }
  it { expect(patch:  "/signalements").to be_unroutable }
  it { expect(delete: "/signalements").to route_to("reports#destroy_all") }

  it { expect(get:    "/signalements/new").to       route_to("reports#new") }
  it { expect(get:    "/signalements/edit").to      be_unroutable }
  it { expect(get:    "/signalements/remove").to    route_to("reports#remove_all") }
  it { expect(get:    "/signalements/undiscard").to be_unroutable }
  it { expect(patch:  "/signalements/undiscard").to route_to("reports#undiscard_all") }

  it { expect(get:    "/signalements/#{id}").to route_to("reports#show", id:) }
  it { expect(post:   "/signalements/#{id}").to be_unroutable }
  it { expect(patch:  "/signalements/#{id}").to route_to("reports#update", id:) }
  it { expect(delete: "/signalements/#{id}").to route_to("reports#destroy", id:) }

  it { expect(get:    "/signalements/#{id}/edit").to      be_unroutable }
  it { expect(get:    "/signalements/#{id}/remove").to    route_to("reports#remove", id:) }
  it { expect(get:    "/signalements/#{id}/undiscard").to be_unroutable }
  it { expect(patch:  "/signalements/#{id}/undiscard").to route_to("reports#undiscard", id:) }

  it { expect(get:    "/signalements/#{id}/edit/situation_majic").to route_to("reports#edit", id:, form: "situation_majic") }
  it { expect(get:    "/signalements/#{id}/edit/unknown").to         route_to("reports#edit", id:, form: "unknown") }
end
