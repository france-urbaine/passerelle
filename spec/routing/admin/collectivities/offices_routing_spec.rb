# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::Collectivities::OfficesController do
  let(:collectivity_id) { SecureRandom.uuid }
  let(:id)              { SecureRandom.uuid }

  it { expect(get:    "/admin/collectivites/#{collectivity_id}/guichets").to route_to("admin/collectivities/offices#index", collectivity_id:) }
  it { expect(post:   "/admin/collectivites/#{collectivity_id}/guichets").to be_unroutable }
  it { expect(patch:  "/admin/collectivites/#{collectivity_id}/guichets").to be_unroutable }
  it { expect(delete: "/admin/collectivites/#{collectivity_id}/guichets").to be_unroutable }

  it { expect(get:    "/admin/collectivites/#{collectivity_id}/guichets/new").to       be_unroutable }
  it { expect(get:    "/admin/collectivites/#{collectivity_id}/guichets/edit").to      be_unroutable }
  it { expect(get:    "/admin/collectivites/#{collectivity_id}/guichets/remove").to    be_unroutable }
  it { expect(get:    "/admin/collectivites/#{collectivity_id}/guichets/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/collectivites/#{collectivity_id}/guichets/undiscard").to be_unroutable }

  it { expect(get:    "/admin/collectivites/#{collectivity_id}/guichets/#{id}").to be_unroutable }
  it { expect(post:   "/admin/collectivites/#{collectivity_id}/guichets/#{id}").to be_unroutable }
  it { expect(patch:  "/admin/collectivites/#{collectivity_id}/guichets/#{id}").to be_unroutable }
  it { expect(delete: "/admin/collectivites/#{collectivity_id}/guichets/#{id}").to be_unroutable }

  it { expect(get:    "/admin/collectivites/#{collectivity_id}/guichets/#{id}/edit").to      be_unroutable }
  it { expect(get:    "/admin/collectivites/#{collectivity_id}/guichets/#{id}/remove").to    be_unroutable }
  it { expect(get:    "/admin/collectivites/#{collectivity_id}/guichets/#{id}/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/collectivites/#{collectivity_id}/guichets/#{id}/undiscard").to be_unroutable }
end
