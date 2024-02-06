# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::Publishers::AuditsController do
  let(:publisher_id) { SecureRandom.uuid }
  let(:id)           { SecureRandom.uuid }

  it { expect(get:    "/admin/editeurs/#{publisher_id}/audits").to route_to("admin/publishers/audits#index", publisher_id:) }
  it { expect(post:   "/admin/editeurs/#{publisher_id}/audits").to be_unroutable }
  it { expect(patch:  "/admin/editeurs/#{publisher_id}/audits").to be_unroutable }
  it { expect(delete: "/admin/editeurs/#{publisher_id}/audits").to be_unroutable }

  it { expect(get:    "/admin/editeurs/#{publisher_id}/audits/new").to       be_unroutable }
  it { expect(get:    "/admin/editeurs/#{publisher_id}/audits/edit").to      be_unroutable }
  it { expect(get:    "/admin/editeurs/#{publisher_id}/audits/remove").to    be_unroutable }
  it { expect(get:    "/admin/editeurs/#{publisher_id}/audits/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/editeurs/#{publisher_id}/audits/undiscard").to be_unroutable }

  it { expect(get:    "/admin/editeurs/#{publisher_id}/audits/#{id}").to be_unroutable }
  it { expect(post:   "/admin/editeurs/#{publisher_id}/audits/#{id}").to be_unroutable }
  it { expect(patch:  "/admin/editeurs/#{publisher_id}/audits/#{id}").to be_unroutable }
  it { expect(delete: "/admin/editeurs/#{publisher_id}/audits/#{id}").to be_unroutable }

  it { expect(get:    "/admin/editeurs/#{publisher_id}/audits/#{id}/edit").to      be_unroutable }
  it { expect(get:    "/admin/editeurs/#{publisher_id}/audits/#{id}/remove").to    be_unroutable }
  it { expect(get:    "/admin/editeurs/#{publisher_id}/audits/#{id}/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/editeurs/#{publisher_id}/audits/#{id}/undiscard").to be_unroutable }
end
