# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::Offices::CollectivitiesController do
  let(:office_id) { SecureRandom.uuid }
  let(:id)        { SecureRandom.uuid }

  it { expect(get:    "/admin/guichets/#{office_id}/collectivites").to route_to("admin/offices/collectivities#index", office_id:) }
  it { expect(post:   "/admin/guichets/#{office_id}/collectivites").to be_unroutable }
  it { expect(patch:  "/admin/guichets/#{office_id}/collectivites").to be_unroutable }
  it { expect(delete: "/admin/guichets/#{office_id}/collectivites").to be_unroutable }

  it { expect(get:    "/admin/guichets/#{office_id}/collectivites/new").to       be_unroutable }
  it { expect(get:    "/admin/guichets/#{office_id}/collectivites/edit").to      be_unroutable }
  it { expect(get:    "/admin/guichets/#{office_id}/collectivites/remove").to    be_unroutable }
  it { expect(get:    "/admin/guichets/#{office_id}/collectivites/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/guichets/#{office_id}/collectivites/undiscard").to be_unroutable }

  it { expect(get:    "/admin/guichets/#{office_id}/collectivites/#{id}").to be_unroutable }
  it { expect(post:   "/admin/guichets/#{office_id}/collectivites/#{id}").to be_unroutable }
  it { expect(patch:  "/admin/guichets/#{office_id}/collectivites/#{id}").to be_unroutable }
  it { expect(delete: "/admin/guichets/#{office_id}/collectivites/#{id}").to be_unroutable }

  it { expect(get:    "/admin/guichets/#{office_id}/collectivites/#{id}/edit").to      be_unroutable }
  it { expect(get:    "/admin/guichets/#{office_id}/collectivites/#{id}/remove").to    be_unroutable }
  it { expect(get:    "/admin/guichets/#{office_id}/collectivites/#{id}/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/guichets/#{office_id}/collectivites/#{id}/undiscard").to be_unroutable }
end
