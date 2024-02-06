# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reports::AssignmentsController do
  let(:report_id) { SecureRandom.uuid }

  it { expect(get:    "/signalements/assign").to route_to("reports/assignments#edit_all") }
  it { expect(post:   "/signalements/assign").to be_unroutable }
  it { expect(patch:  "/signalements/assign").to route_to("reports/assignments#update_all") }
  it { expect(delete: "/signalements/assign").to be_unroutable }

  it { expect(get:    "/signalements/assign/new").to       be_unroutable }
  it { expect(get:    "/signalements/assign/edit").to      be_unroutable }
  it { expect(get:    "/signalements/assign/remove").to    be_unroutable }
  it { expect(get:    "/signalements/assign/undiscard").to be_unroutable }
  it { expect(patch:  "/signalements/assign/undiscard").to be_unroutable }

  it { expect(get:    "/signalements/assign/#{report_id}").to route_to("reports/assignments#edit", report_id:) }
  it { expect(post:   "/signalements/assign/#{report_id}").to be_unroutable }
  it { expect(patch:  "/signalements/assign/#{report_id}").to route_to("reports/assignments#update", report_id:) }
  it { expect(delete: "/signalements/assign/#{report_id}").to route_to("reports/assignments#destroy", report_id:) }

  it { expect(get:    "/signalements/assign/#{report_id}/edit").to      be_unroutable }
  it { expect(get:    "/signalements/assign/#{report_id}/remove").to    route_to("reports/assignments#remove", report_id:) }
  it { expect(get:    "/signalements/assign/#{report_id}/undiscard").to be_unroutable }
  it { expect(patch:  "/signalements/assign/#{report_id}/undiscard").to be_unroutable }
end
