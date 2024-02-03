# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::Offices::AuditsController do
  let(:office_id) { SecureRandom.uuid }
  let(:id)        { SecureRandom.uuid }

  it { expect(get:    "/admin/guichets/#{office_id}/audits").to route_to("admin/offices/audits#index", office_id:) }
  it { expect(post:   "/admin/guichets/#{office_id}/audits").to be_unroutable }
  it { expect(patch:  "/admin/guichets/#{office_id}/audits").to be_unroutable }
  it { expect(delete: "/admin/guichets/#{office_id}/audits").to be_unroutable }

  it { expect(get:    "/admin/guichets/#{office_id}/audits/new").to       be_unroutable }
  it { expect(get:    "/admin/guichets/#{office_id}/audits/edit").to      be_unroutable }
  it { expect(get:    "/admin/guichets/#{office_id}/audits/remove").to    be_unroutable }
  it { expect(get:    "/admin/guichets/#{office_id}/audits/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/guichets/#{office_id}/audits/undiscard").to be_unroutable }

  it { expect(get:    "/admin/guichets/#{office_id}/audits/#{id}").to be_unroutable }
  it { expect(post:   "/admin/guichets/#{office_id}/audits/#{id}").to be_unroutable }
  it { expect(patch:  "/admin/guichets/#{office_id}/audits/#{id}").to be_unroutable }
  it { expect(delete: "/admin/guichets/#{office_id}/audits/#{id}").to be_unroutable }

  it { expect(get:    "/admin/guichets/#{office_id}/audits/#{id}/edit").to      be_unroutable }
  it { expect(get:    "/admin/guichets/#{office_id}/audits/#{id}/remove").to    be_unroutable }
  it { expect(get:    "/admin/guichets/#{office_id}/audits/#{id}/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/guichets/#{office_id}/audits/#{id}/undiscard").to be_unroutable }
end
