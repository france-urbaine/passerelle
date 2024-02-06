# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reports::DenialsController do
  let(:report_id) { SecureRandom.uuid }

  it { expect(get:    "/signalements/deny").to route_to("reports/denials#edit_all") }
  it { expect(post:   "/signalements/deny").to be_unroutable }
  it { expect(patch:  "/signalements/deny").to route_to("reports/denials#update_all") }
  it { expect(delete: "/signalements/deny").to be_unroutable }

  it { expect(get:    "/signalements/deny/new").to       be_unroutable }
  it { expect(get:    "/signalements/deny/edit").to      be_unroutable }
  it { expect(get:    "/signalements/deny/remove").to    be_unroutable }
  it { expect(get:    "/signalements/deny/undiscard").to be_unroutable }
  it { expect(patch:  "/signalements/deny/undiscard").to be_unroutable }

  it { expect(get:    "/signalements/deny/#{report_id}").to route_to("reports/denials#edit", report_id:) }
  it { expect(post:   "/signalements/deny/#{report_id}").to be_unroutable }
  it { expect(patch:  "/signalements/deny/#{report_id}").to route_to("reports/denials#update", report_id:) }
  it { expect(delete: "/signalements/deny/#{report_id}").to route_to("reports/denials#destroy", report_id:) }

  it { expect(get:    "/signalements/deny/#{report_id}/edit").to      be_unroutable }
  it { expect(get:    "/signalements/deny/#{report_id}/remove").to    route_to("reports/denials#remove", report_id:) }
  it { expect(get:    "/signalements/deny/#{report_id}/undiscard").to be_unroutable }
  it { expect(patch:  "/signalements/deny/#{report_id}/undiscard").to be_unroutable }
end
