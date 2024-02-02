# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reports::AssignmentsController do
  it { expect(get:    "/signalements/9c6c00c4/assign").to route_to("reports/assignments#edit", report_id: "9c6c00c4") }
  it { expect(post:   "/signalements/9c6c00c4/assign").to be_unroutable }
  it { expect(patch:  "/signalements/9c6c00c4/assign").to route_to("reports/assignments#update", report_id: "9c6c00c4") }
  it { expect(delete: "/signalements/9c6c00c4/assign").to route_to("reports/assignments#destroy", report_id: "9c6c00c4") }

  it { expect(get:    "/signalements/9c6c00c4/assign/new").to       be_unroutable }
  it { expect(get:    "/signalements/9c6c00c4/assign/edit").to      be_unroutable }
  it { expect(get:    "/signalements/9c6c00c4/assign/remove").to    route_to("reports/assignments#remove", report_id: "9c6c00c4") }
  it { expect(get:    "/signalements/9c6c00c4/assign/undiscard").to be_unroutable }
  it { expect(patch:  "/signalements/9c6c00c4/assign/undiscard").to be_unroutable }

  it { expect(get:    "/signalements/9c6c00c4/assign/b12170f4").to be_unroutable }
  it { expect(post:   "/signalements/9c6c00c4/assign/b12170f4").to be_unroutable }
  it { expect(patch:  "/signalements/9c6c00c4/assign/b12170f4").to be_unroutable }
  it { expect(delete: "/signalements/9c6c00c4/assign/b12170f4").to be_unroutable }

  it { expect(get:    "/signalements/9c6c00c4/assign/b12170f4/edit").to      be_unroutable }
  it { expect(get:    "/signalements/9c6c00c4/assign/b12170f4/remove").to    be_unroutable }
  it { expect(get:    "/signalements/9c6c00c4/assign/b12170f4/undiscard").to be_unroutable }
  it { expect(patch:  "/signalements/9c6c00c4/assign/b12170f4/undiscard").to be_unroutable }
end
