# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reports::ApprovalsController do
  let(:report_id) { SecureRandom.uuid }

  it { expect(get:    "/signalements/approve").to route_to("reports/approvals#edit_all") }
  it { expect(post:   "/signalements/approve").to be_unroutable }
  it { expect(patch:  "/signalements/approve").to route_to("reports/approvals#update_all") }
  it { expect(delete: "/signalements/approve").to be_unroutable }

  it { expect(get:    "/signalements/approve/new").to       be_unroutable }
  it { expect(get:    "/signalements/approve/edit").to      be_unroutable }
  it { expect(get:    "/signalements/approve/remove").to    be_unroutable }
  it { expect(get:    "/signalements/approve/undiscard").to be_unroutable }
  it { expect(patch:  "/signalements/approve/undiscard").to be_unroutable }

  it { expect(get:    "/signalements/approve/#{report_id}").to route_to("reports/approvals#edit", report_id:) }
  it { expect(post:   "/signalements/approve/#{report_id}").to be_unroutable }
  it { expect(patch:  "/signalements/approve/#{report_id}").to route_to("reports/approvals#update", report_id:) }
  it { expect(delete: "/signalements/approve/#{report_id}").to route_to("reports/approvals#destroy", report_id:) }

  it { expect(get:    "/signalements/approve/#{report_id}/edit").to      be_unroutable }
  it { expect(get:    "/signalements/approve/#{report_id}/remove").to    route_to("reports/approvals#remove", report_id:) }
  it { expect(get:    "/signalements/approve/#{report_id}/undiscard").to be_unroutable }
  it { expect(patch:  "/signalements/approve/#{report_id}/undiscard").to be_unroutable }
end
