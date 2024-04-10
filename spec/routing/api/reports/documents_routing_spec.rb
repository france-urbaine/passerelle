# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::Reports::DocumentsController do
  let(:report_id) { SecureRandom.uuid }
  let(:id)        { SecureRandom.uuid }

  it { expect(get:    "http://api.example.com/signalements/#{report_id}/documents").to be_unroutable }
  it { expect(post:   "http://api.example.com/signalements/#{report_id}/documents").to route_to("api/reports/documents#create", report_id:) }
  it { expect(patch:  "http://api.example.com/signalements/#{report_id}/documents").to be_unroutable }
  it { expect(delete: "http://api.example.com/signalements/#{report_id}/documents").to be_unroutable }

  it { expect(get:    "http://api.example.com/signalements/#{report_id}/documents/new").to       be_unroutable }
  it { expect(get:    "http://api.example.com/signalements/#{report_id}/documents/edit").to      be_unroutable }
  it { expect(get:    "http://api.example.com/signalements/#{report_id}/documents/remove").to    be_unroutable }
  it { expect(get:    "http://api.example.com/signalements/#{report_id}/documents/undiscard").to be_unroutable }
  it { expect(patch:  "http://api.example.com/signalements/#{report_id}/documents/undiscard").to be_unroutable }

  it { expect(get:    "http://api.example.com/signalements/#{report_id}/documents/#{id}").to be_unroutable }
  it { expect(post:   "http://api.example.com/signalements/#{report_id}/documents/#{id}").to be_unroutable }
  it { expect(patch:  "http://api.example.com/signalements/#{report_id}/documents/#{id}").to be_unroutable }
  it { expect(delete: "http://api.example.com/signalements/#{report_id}/documents/#{id}").to be_unroutable }

  it { expect(get:    "http://api.example.com/signalements/#{report_id}/documents/#{id}/edit").to      be_unroutable }
  it { expect(get:    "http://api.example.com/signalements/#{report_id}/documents/#{id}/remove").to    be_unroutable }
  it { expect(get:    "http://api.example.com/signalements/#{report_id}/documents/#{id}/undiscard").to be_unroutable }
  it { expect(patch:  "http://api.example.com/signalements/#{report_id}/documents/#{id}/undiscard").to be_unroutable }

  it { expect(get:    "http://api.example.com/signalements/#{report_id}/documents/#{id}/file.pdf").to  be_unroutable }
  it { expect(get:    "http://api.example.com/signalements/#{report_id}/documents/#{id}/image.png").to be_unroutable }
end
