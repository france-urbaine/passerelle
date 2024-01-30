# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reports::DenialsController do
  it { expect(get:    "/signalements/9c6c00c4/deny").to be_unroutable }
  it { expect(post:   "/signalements/9c6c00c4/deny").to be_unroutable }
  it { expect(patch:  "/signalements/9c6c00c4/deny").to route_to("reports/denials#update", report_id: "9c6c00c4") }
  it { expect(delete: "/signalements/9c6c00c4/deny").to route_to("reports/denials#destroy", report_id: "9c6c00c4") }

  it { expect(get:    "/signalements/9c6c00c4/deny/new").to       be_unroutable }
  it { expect(get:    "/signalements/9c6c00c4/deny/edit").to      route_to("reports/denials#edit", report_id: "9c6c00c4") }
  it { expect(get:    "/signalements/9c6c00c4/deny/remove").to    route_to("reports/denials#remove", report_id: "9c6c00c4") }
  it { expect(get:    "/signalements/9c6c00c4/deny/undiscard").to be_unroutable }
  it { expect(patch:  "/signalements/9c6c00c4/deny/undiscard").to be_unroutable }

  it { expect(get:    "/signalements/9c6c00c4/deny/b12170f4").to be_unroutable }
  it { expect(post:   "/signalements/9c6c00c4/deny/b12170f4").to be_unroutable }
  it { expect(patch:  "/signalements/9c6c00c4/deny/b12170f4").to be_unroutable }
  it { expect(delete: "/signalements/9c6c00c4/deny/b12170f4").to be_unroutable }

  it { expect(get:    "/signalements/9c6c00c4/deny/b12170f4/edit").to      be_unroutable }
  it { expect(get:    "/signalements/9c6c00c4/deny/b12170f4/remove").to    be_unroutable }
  it { expect(get:    "/signalements/9c6c00c4/deny/b12170f4/undiscard").to be_unroutable }
  it { expect(patch:  "/signalements/9c6c00c4/deny/b12170f4/undiscard").to be_unroutable }
end
