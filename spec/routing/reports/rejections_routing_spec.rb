# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reports::RejectionsController do
  let(:report_id) { SecureRandom.uuid }

  it { expect(get:    "/signalements/reject").to route_to("reports/rejections#edit_all") }
  it { expect(post:   "/signalements/reject").to be_unroutable }
  it { expect(patch:  "/signalements/reject").to route_to("reports/rejections#update_all") }
  it { expect(delete: "/signalements/reject").to be_unroutable }

  it { expect(get:    "/signalements/reject/new").to       be_unroutable }
  it { expect(get:    "/signalements/reject/edit").to      be_unroutable }
  it { expect(get:    "/signalements/reject/remove").to    be_unroutable }
  it { expect(get:    "/signalements/reject/undiscard").to be_unroutable }
  it { expect(patch:  "/signalements/reject/undiscard").to be_unroutable }

  it { expect(get:    "/signalements/reject/#{report_id}").to route_to("reports/rejections#edit", report_id:) }
  it { expect(post:   "/signalements/reject/#{report_id}").to be_unroutable }
  it { expect(patch:  "/signalements/reject/#{report_id}").to route_to("reports/rejections#update", report_id:) }
  it { expect(delete: "/signalements/reject/#{report_id}").to route_to("reports/rejections#destroy", report_id:) }

  it { expect(get:    "/signalements/reject/#{report_id}/edit").to      be_unroutable }
  it { expect(get:    "/signalements/reject/#{report_id}/remove").to    route_to("reports/rejections#remove", report_id:) }
  it { expect(get:    "/signalements/reject/#{report_id}/undiscard").to be_unroutable }
  it { expect(patch:  "/signalements/reject/#{report_id}/undiscard").to be_unroutable }
end
