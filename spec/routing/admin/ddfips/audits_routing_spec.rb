# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::DDFIPs::AuditsController do
  let(:ddfip_id) { SecureRandom.uuid }
  let(:id)       { SecureRandom.uuid }

  it { expect(get:    "/admin/ddfips/#{ddfip_id}/audits").to route_to("admin/ddfips/audits#index", ddfip_id:) }
  it { expect(post:   "/admin/ddfips/#{ddfip_id}/audits").to be_unroutable }
  it { expect(patch:  "/admin/ddfips/#{ddfip_id}/audits").to be_unroutable }
  it { expect(delete: "/admin/ddfips/#{ddfip_id}/audits").to be_unroutable }

  it { expect(get:    "/admin/ddfips/#{ddfip_id}/audits/new").to       be_unroutable }
  it { expect(get:    "/admin/ddfips/#{ddfip_id}/audits/edit").to      be_unroutable }
  it { expect(get:    "/admin/ddfips/#{ddfip_id}/audits/remove").to    be_unroutable }
  it { expect(get:    "/admin/ddfips/#{ddfip_id}/audits/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/ddfips/#{ddfip_id}/audits/undiscard").to be_unroutable }

  it { expect(get:    "/admin/ddfips/#{ddfip_id}/audits/#{id}").to be_unroutable }
  it { expect(post:   "/admin/ddfips/#{ddfip_id}/audits/#{id}").to be_unroutable }
  it { expect(patch:  "/admin/ddfips/#{ddfip_id}/audits/#{id}").to be_unroutable }
  it { expect(delete: "/admin/ddfips/#{ddfip_id}/audits/#{id}").to be_unroutable }

  it { expect(get:    "/admin/ddfips/#{ddfip_id}/audits/#{id}/edit").to      be_unroutable }
  it { expect(get:    "/admin/ddfips/#{ddfip_id}/audits/#{id}/remove").to    be_unroutable }
  it { expect(get:    "/admin/ddfips/#{ddfip_id}/audits/#{id}/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/ddfips/#{ddfip_id}/audits/#{id}/undiscard").to be_unroutable }
end
