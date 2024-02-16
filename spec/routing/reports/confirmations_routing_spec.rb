# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reports::ConfirmationsController do
  let(:report_id) { SecureRandom.uuid }

  it { expect(get:    "/signalements/confirm").to route_to("reports/confirmations#edit_all") }
  it { expect(post:   "/signalements/confirm").to be_unroutable }
  it { expect(patch:  "/signalements/confirm").to route_to("reports/confirmations#update_all") }
  it { expect(delete: "/signalements/confirm").to be_unroutable }

  it { expect(get:    "/signalements/confirm/new").to       be_unroutable }
  it { expect(get:    "/signalements/confirm/edit").to      be_unroutable }
  it { expect(get:    "/signalements/confirm/remove").to    be_unroutable }
  it { expect(get:    "/signalements/confirm/undiscard").to be_unroutable }
  it { expect(patch:  "/signalements/confirm/undiscard").to be_unroutable }

  it { expect(get:    "/signalements/confirm/#{report_id}").to route_to("reports/confirmations#edit", report_id:) }
  it { expect(post:   "/signalements/confirm/#{report_id}").to be_unroutable }
  it { expect(patch:  "/signalements/confirm/#{report_id}").to route_to("reports/confirmations#update", report_id:) }
  it { expect(delete: "/signalements/confirm/#{report_id}").to route_to("reports/confirmations#destroy", report_id:) }

  it { expect(get:    "/signalements/confirm/#{report_id}/edit").to      be_unroutable }
  it { expect(get:    "/signalements/confirm/#{report_id}/remove").to    route_to("reports/confirmations#remove", report_id:) }
  it { expect(get:    "/signalements/confirm/#{report_id}/undiscard").to be_unroutable }
  it { expect(patch:  "/signalements/confirm/#{report_id}/undiscard").to be_unroutable }
end
