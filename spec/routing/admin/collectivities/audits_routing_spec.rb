# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::Collectivities::AuditsController do
  let(:collectivity_id) { SecureRandom.uuid }
  let(:id)              { SecureRandom.uuid }

  it { expect(get:    "/admin/collectivites/#{collectivity_id}/audits").to route_to("admin/collectivities/audits#index", collectivity_id:) }
  it { expect(post:   "/admin/collectivites/#{collectivity_id}/audits").to be_unroutable }
  it { expect(patch:  "/admin/collectivites/#{collectivity_id}/audits").to be_unroutable }
  it { expect(delete: "/admin/collectivites/#{collectivity_id}/audits").to be_unroutable }

  it { expect(get:    "/admin/collectivites/#{collectivity_id}/audits/new").to       be_unroutable }
  it { expect(get:    "/admin/collectivites/#{collectivity_id}/audits/edit").to      be_unroutable }
  it { expect(get:    "/admin/collectivites/#{collectivity_id}/audits/remove").to    be_unroutable }
  it { expect(get:    "/admin/collectivites/#{collectivity_id}/audits/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/collectivites/#{collectivity_id}/audits/undiscard").to be_unroutable }

  it { expect(get:    "/admin/collectivites/#{collectivity_id}/audits/#{id}").to be_unroutable }
  it { expect(post:   "/admin/collectivites/#{collectivity_id}/audits/#{id}").to be_unroutable }
  it { expect(patch:  "/admin/collectivites/#{collectivity_id}/audits/#{id}").to be_unroutable }
  it { expect(delete: "/admin/collectivites/#{collectivity_id}/audits/#{id}").to be_unroutable }

  it { expect(get:    "/admin/collectivites/#{collectivity_id}/audits/#{id}/edit").to      be_unroutable }
  it { expect(get:    "/admin/collectivites/#{collectivity_id}/audits/#{id}/remove").to    be_unroutable }
  it { expect(get:    "/admin/collectivites/#{collectivity_id}/audits/#{id}/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/collectivites/#{collectivity_id}/audits/#{id}/undiscard").to be_unroutable }
end
