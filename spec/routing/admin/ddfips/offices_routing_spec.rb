# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::DDFIPs::OfficesController do
  let(:ddfip_id) { SecureRandom.uuid }
  let(:id)       { SecureRandom.uuid }

  it { expect(get:    "/admin/ddfips/#{ddfip_id}/guichets").to route_to("admin/ddfips/offices#index", ddfip_id:) }
  it { expect(post:   "/admin/ddfips/#{ddfip_id}/guichets").to route_to("admin/ddfips/offices#create", ddfip_id:) }
  it { expect(patch:  "/admin/ddfips/#{ddfip_id}/guichets").to be_unroutable }
  it { expect(delete: "/admin/ddfips/#{ddfip_id}/guichets").to route_to("admin/ddfips/offices#destroy_all", ddfip_id:) }

  it { expect(get:    "/admin/ddfips/#{ddfip_id}/guichets/new").to       route_to("admin/ddfips/offices#new", ddfip_id:) }
  it { expect(get:    "/admin/ddfips/#{ddfip_id}/guichets/edit").to      be_unroutable }
  it { expect(get:    "/admin/ddfips/#{ddfip_id}/guichets/remove").to    route_to("admin/ddfips/offices#remove_all", ddfip_id:) }
  it { expect(get:    "/admin/ddfips/#{ddfip_id}/guichets/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/ddfips/#{ddfip_id}/guichets/undiscard").to route_to("admin/ddfips/offices#undiscard_all", ddfip_id:) }

  it { expect(get:    "/admin/ddfips/#{ddfip_id}/guichets/#{id}").to be_unroutable }
  it { expect(post:   "/admin/ddfips/#{ddfip_id}/guichets/#{id}").to be_unroutable }
  it { expect(patch:  "/admin/ddfips/#{ddfip_id}/guichets/#{id}").to be_unroutable }
  it { expect(delete: "/admin/ddfips/#{ddfip_id}/guichets/#{id}").to be_unroutable }

  it { expect(get:    "/admin/ddfips/#{ddfip_id}/guichets/#{id}/edit").to      be_unroutable }
  it { expect(get:    "/admin/ddfips/#{ddfip_id}/guichets/#{id}/remove").to    be_unroutable }
  it { expect(get:    "/admin/ddfips/#{ddfip_id}/guichets/#{id}/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/ddfips/#{ddfip_id}/guichets/#{id}/undiscard").to be_unroutable }
end
