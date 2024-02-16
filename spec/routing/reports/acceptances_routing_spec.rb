# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reports::AcceptancesController do
  let(:report_id) { SecureRandom.uuid }

  it { expect(get:    "/signalements/accept").to route_to("reports/acceptances#edit_all") }
  it { expect(post:   "/signalements/accept").to be_unroutable }
  it { expect(patch:  "/signalements/accept").to route_to("reports/acceptances#update_all") }
  it { expect(delete: "/signalements/accept").to be_unroutable }

  it { expect(get:    "/signalements/accept/new").to       be_unroutable }
  it { expect(get:    "/signalements/accept/edit").to      be_unroutable }
  it { expect(get:    "/signalements/accept/remove").to    be_unroutable }
  it { expect(get:    "/signalements/accept/undiscard").to be_unroutable }
  it { expect(patch:  "/signalements/accept/undiscard").to be_unroutable }

  it { expect(get:    "/signalements/accept/#{report_id}").to route_to("reports/acceptances#edit", report_id:) }
  it { expect(post:   "/signalements/accept/#{report_id}").to be_unroutable }
  it { expect(patch:  "/signalements/accept/#{report_id}").to route_to("reports/acceptances#update", report_id:) }
  it { expect(delete: "/signalements/accept/#{report_id}").to route_to("reports/acceptances#destroy", report_id:) }

  it { expect(get:    "/signalements/accept/#{report_id}/edit").to      be_unroutable }
  it { expect(get:    "/signalements/accept/#{report_id}/remove").to    route_to("reports/acceptances#remove", report_id:) }
  it { expect(get:    "/signalements/accept/#{report_id}/undiscard").to be_unroutable }
  it { expect(patch:  "/signalements/accept/#{report_id}/undiscard").to be_unroutable }
end
