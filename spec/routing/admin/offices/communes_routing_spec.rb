# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::Offices::CommunesController do
  let(:office_id) { SecureRandom.uuid }
  let(:id)        { SecureRandom.uuid }

  it { expect(get:    "/admin/guichets/#{office_id}/communes").to route_to("admin/offices/communes#index", office_id:) }
  it { expect(post:   "/admin/guichets/#{office_id}/communes").to be_unroutable }
  it { expect(patch:  "/admin/guichets/#{office_id}/communes").to route_to("admin/offices/communes#update_all", office_id:) }
  it { expect(delete: "/admin/guichets/#{office_id}/communes").to route_to("admin/offices/communes#destroy_all", office_id:) }

  it { expect(get:    "/admin/guichets/#{office_id}/communes/new").to       be_unroutable }
  it { expect(get:    "/admin/guichets/#{office_id}/communes/edit").to      route_to("admin/offices/communes#edit_all", office_id:) }
  it { expect(get:    "/admin/guichets/#{office_id}/communes/remove").to    route_to("admin/offices/communes#remove_all", office_id:) }
  it { expect(get:    "/admin/guichets/#{office_id}/communes/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/guichets/#{office_id}/communes/undiscard").to be_unroutable }

  it { expect(get:    "/admin/guichets/#{office_id}/communes/#{id}").to be_unroutable }
  it { expect(post:   "/admin/guichets/#{office_id}/communes/#{id}").to be_unroutable }
  it { expect(patch:  "/admin/guichets/#{office_id}/communes/#{id}").to be_unroutable }
  it { expect(delete: "/admin/guichets/#{office_id}/communes/#{id}").to route_to("admin/offices/communes#destroy", office_id:, id:) }

  it { expect(get:    "/admin/guichets/#{office_id}/communes/#{id}/edit").to      be_unroutable }
  it { expect(get:    "/admin/guichets/#{office_id}/communes/#{id}/remove").to    route_to("admin/offices/communes#remove", office_id:, id:) }
  it { expect(get:    "/admin/guichets/#{office_id}/communes/#{id}/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/guichets/#{office_id}/communes/#{id}/undiscard").to be_unroutable }
end
