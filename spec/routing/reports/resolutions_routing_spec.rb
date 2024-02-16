# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reports::ResolutionsController do
  let(:report_id) { SecureRandom.uuid }

  it { expect(get:    "/signalements/resolve").to route_to("reports/resolutions#edit_all") }
  it { expect(post:   "/signalements/resolve").to be_unroutable }
  it { expect(patch:  "/signalements/resolve").to route_to("reports/resolutions#update_all") }
  it { expect(delete: "/signalements/resolve").to be_unroutable }

  it { expect(get:    "/signalements/resolve/new").to       be_unroutable }
  it { expect(get:    "/signalements/resolve/edit").to      be_unroutable }
  it { expect(get:    "/signalements/resolve/remove").to    be_unroutable }
  it { expect(get:    "/signalements/resolve/undiscard").to be_unroutable }
  it { expect(patch:  "/signalements/resolve/undiscard").to be_unroutable }

  it { expect(get:    "/signalements/resolve/#{report_id}").to route_to("reports/resolutions#edit", report_id:) }
  it { expect(post:   "/signalements/resolve/#{report_id}").to be_unroutable }
  it { expect(patch:  "/signalements/resolve/#{report_id}").to route_to("reports/resolutions#update", report_id:) }
  it { expect(delete: "/signalements/resolve/#{report_id}").to route_to("reports/resolutions#destroy", report_id:) }

  it { expect(get:    "/signalements/resolve/#{report_id}/edit").to      be_unroutable }
  it { expect(get:    "/signalements/resolve/#{report_id}/remove").to    route_to("reports/resolutions#remove", report_id:) }
  it { expect(get:    "/signalements/resolve/#{report_id}/undiscard").to be_unroutable }
  it { expect(patch:  "/signalements/resolve/#{report_id}/undiscard").to be_unroutable }
end
