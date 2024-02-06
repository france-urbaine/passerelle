# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::DDFIPs::CollectivitiesController do
  let(:ddfip_id) { SecureRandom.uuid }
  let(:id)       { SecureRandom.uuid }

  it { expect(get:    "/admin/ddfips/#{ddfip_id}/collectivites").to route_to("admin/ddfips/collectivities#index", ddfip_id:) }
  it { expect(post:   "/admin/ddfips/#{ddfip_id}/collectivites").to be_unroutable }
  it { expect(patch:  "/admin/ddfips/#{ddfip_id}/collectivites").to be_unroutable }
  it { expect(delete: "/admin/ddfips/#{ddfip_id}/collectivites").to be_unroutable }

  it { expect(get:    "/admin/ddfips/#{ddfip_id}/collectivites/new").to       be_unroutable }
  it { expect(get:    "/admin/ddfips/#{ddfip_id}/collectivites/edit").to      be_unroutable }
  it { expect(get:    "/admin/ddfips/#{ddfip_id}/collectivites/remove").to    be_unroutable }
  it { expect(get:    "/admin/ddfips/#{ddfip_id}/collectivites/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/ddfips/#{ddfip_id}/collectivites/undiscard").to be_unroutable }

  it { expect(get:    "/admin/ddfips/#{ddfip_id}/collectivites/#{id}").to be_unroutable }
  it { expect(post:   "/admin/ddfips/#{ddfip_id}/collectivites/#{id}").to be_unroutable }
  it { expect(patch:  "/admin/ddfips/#{ddfip_id}/collectivites/#{id}").to be_unroutable }
  it { expect(delete: "/admin/ddfips/#{ddfip_id}/collectivites/#{id}").to be_unroutable }

  it { expect(get:    "/admin/ddfips/#{ddfip_id}/collectivites/#{id}/edit").to      be_unroutable }
  it { expect(get:    "/admin/ddfips/#{ddfip_id}/collectivites/#{id}/remove").to    be_unroutable }
  it { expect(get:    "/admin/ddfips/#{ddfip_id}/collectivites/#{id}/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/ddfips/#{ddfip_id}/collectivites/#{id}/undiscard").to be_unroutable }
end
