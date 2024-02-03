# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::Users::ResetsController do
  let(:user_id) { SecureRandom.uuid }
  let(:id)      { SecureRandom.uuid }

  it { expect(get:    "/admin/utilisateurs/#{user_id}/reset").to be_unroutable }
  it { expect(post:   "/admin/utilisateurs/#{user_id}/reset").to route_to("admin/users/resets#create", user_id:) }
  it { expect(patch:  "/admin/utilisateurs/#{user_id}/reset").to be_unroutable }
  it { expect(delete: "/admin/utilisateurs/#{user_id}/reset").to be_unroutable }

  it { expect(get:    "/admin/utilisateurs/#{user_id}/reset/new").to       route_to("admin/users/resets#new", user_id:) }
  it { expect(get:    "/admin/utilisateurs/#{user_id}/reset/edit").to      be_unroutable }
  it { expect(get:    "/admin/utilisateurs/#{user_id}/reset/remove").to    be_unroutable }
  it { expect(get:    "/admin/utilisateurs/#{user_id}/reset/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/utilisateurs/#{user_id}/reset/undiscard").to be_unroutable }

  it { expect(get:    "/admin/utilisateurs/#{user_id}/reset/#{id}").to be_unroutable }
  it { expect(post:   "/admin/utilisateurs/#{user_id}/reset/#{id}").to be_unroutable }
  it { expect(patch:  "/admin/utilisateurs/#{user_id}/reset/#{id}").to be_unroutable }
  it { expect(delete: "/admin/utilisateurs/#{user_id}/reset/#{id}").to be_unroutable }

  it { expect(get:    "/admin/utilisateurs/#{user_id}/reset/#{id}/edit").to      be_unroutable }
  it { expect(get:    "/admin/utilisateurs/#{user_id}/reset/#{id}/remove").to    be_unroutable }
  it { expect(get:    "/admin/utilisateurs/#{user_id}/reset/#{id}/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/utilisateurs/#{user_id}/reset/#{id}/undiscard").to be_unroutable }
end
