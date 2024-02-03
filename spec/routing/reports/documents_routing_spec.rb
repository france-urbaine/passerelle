# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reports::DocumentsController do
  let(:report_id) { SecureRandom.uuid }
  let(:id)        { SecureRandom.uuid }

  it { expect(get:    "/signalements/#{report_id}/documents").to be_unroutable }
  it { expect(post:   "/signalements/#{report_id}/documents").to route_to("reports/documents#create", report_id:) }
  it { expect(patch:  "/signalements/#{report_id}/documents").to be_unroutable }
  it { expect(delete: "/signalements/#{report_id}/documents").to be_unroutable }

  it { expect(get:    "/signalements/#{report_id}/documents/new").to       route_to("reports/documents#new", report_id:) }
  it { expect(get:    "/signalements/#{report_id}/documents/edit").to      be_unroutable }
  it { expect(get:    "/signalements/#{report_id}/documents/remove").to    be_unroutable }
  it { expect(get:    "/signalements/#{report_id}/documents/undiscard").to be_unroutable }
  it { expect(patch:  "/signalements/#{report_id}/documents/undiscard").to be_unroutable }

  it { expect(get:    "/signalements/#{report_id}/documents/#{id}").to route_to("reports/documents#show", report_id:, id:, format: "html") }
  it { expect(post:   "/signalements/#{report_id}/documents/#{id}").to be_unroutable }
  it { expect(patch:  "/signalements/#{report_id}/documents/#{id}").to be_unroutable }
  it { expect(delete: "/signalements/#{report_id}/documents/#{id}").to route_to("reports/documents#destroy", report_id:, id:) }

  it { expect(get:    "/signalements/#{report_id}/documents/#{id}/edit").to      be_unroutable }
  it { expect(get:    "/signalements/#{report_id}/documents/#{id}/remove").to    route_to("reports/documents#remove", report_id:, id:) }
  it { expect(get:    "/signalements/#{report_id}/documents/#{id}/undiscard").to be_unroutable }
  it { expect(patch:  "/signalements/#{report_id}/documents/#{id}/undiscard").to be_unroutable }

  it { expect(get:    "/signalements/#{report_id}/documents/#{id}/file.pdf").to  route_to("reports/documents#show", report_id:, id:, filename: "file.pdf", format: "html") }
  it { expect(get:    "/signalements/#{report_id}/documents/#{id}/image.png").to route_to("reports/documents#show", report_id:, id:, filename: "image.png", format: "html") }
end
