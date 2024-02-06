# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::Users::AuditsController do
  let(:user_id) { SecureRandom.uuid }
  let(:id)      { SecureRandom.uuid }

  it { expect(get:    "/admin/utilisateurs/#{user_id}/audits").to route_to("admin/users/audits#index", user_id:) }
  it { expect(post:   "/admin/utilisateurs/#{user_id}/audits").to be_unroutable }
  it { expect(patch:  "/admin/utilisateurs/#{user_id}/audits").to be_unroutable }
  it { expect(delete: "/admin/utilisateurs/#{user_id}/audits").to be_unroutable }

  it { expect(get:    "/admin/utilisateurs/#{user_id}/audits/new").to       be_unroutable }
  it { expect(get:    "/admin/utilisateurs/#{user_id}/audits/edit").to      be_unroutable }
  it { expect(get:    "/admin/utilisateurs/#{user_id}/audits/remove").to    be_unroutable }
  it { expect(get:    "/admin/utilisateurs/#{user_id}/audits/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/utilisateurs/#{user_id}/audits/undiscard").to be_unroutable }

  it { expect(get:    "/admin/utilisateurs/#{user_id}/audits/#{id}").to be_unroutable }
  it { expect(post:   "/admin/utilisateurs/#{user_id}/audits/#{id}").to be_unroutable }
  it { expect(patch:  "/admin/utilisateurs/#{user_id}/audits/#{id}").to be_unroutable }
  it { expect(delete: "/admin/utilisateurs/#{user_id}/audits/#{id}").to be_unroutable }

  it { expect(get:    "/admin/utilisateurs/#{user_id}/audits/#{id}/edit").to      be_unroutable }
  it { expect(get:    "/admin/utilisateurs/#{user_id}/audits/#{id}/remove").to    be_unroutable }
  it { expect(get:    "/admin/utilisateurs/#{user_id}/audits/#{id}/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/utilisateurs/#{user_id}/audits/#{id}/undiscard").to be_unroutable }
end
