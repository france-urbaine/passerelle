# frozen_string_literal: true

require "rails_helper"

RSpec.describe Organization::Users::ResetsController do
  let(:user_id) { SecureRandom.uuid }
  let(:id)      { SecureRandom.uuid }

  it { expect(get:    "/organisation/utilisateurs/#{user_id}/reset").to be_unroutable }
  it { expect(post:   "/organisation/utilisateurs/#{user_id}/reset").to route_to("organization/users/resets#create", user_id:) }
  it { expect(patch:  "/organisation/utilisateurs/#{user_id}/reset").to be_unroutable }
  it { expect(delete: "/organisation/utilisateurs/#{user_id}/reset").to be_unroutable }

  it { expect(get:    "/organisation/utilisateurs/#{user_id}/reset/new").to       route_to("organization/users/resets#new", user_id:) }
  it { expect(get:    "/organisation/utilisateurs/#{user_id}/reset/edit").to      be_unroutable }
  it { expect(get:    "/organisation/utilisateurs/#{user_id}/reset/remove").to    be_unroutable }
  it { expect(get:    "/organisation/utilisateurs/#{user_id}/reset/undiscard").to be_unroutable }
  it { expect(patch:  "/organisation/utilisateurs/#{user_id}/reset/undiscard").to be_unroutable }

  it { expect(get:    "/organisation/utilisateurs/#{user_id}/reset/#{id}").to be_unroutable }
  it { expect(post:   "/organisation/utilisateurs/#{user_id}/reset/#{id}").to be_unroutable }
  it { expect(patch:  "/organisation/utilisateurs/#{user_id}/reset/#{id}").to be_unroutable }
  it { expect(delete: "/organisation/utilisateurs/#{user_id}/reset/#{id}").to be_unroutable }

  it { expect(get:    "/organisation/utilisateurs/#{user_id}/reset/#{id}/edit").to      be_unroutable }
  it { expect(get:    "/organisation/utilisateurs/#{user_id}/reset/#{id}/remove").to    be_unroutable }
  it { expect(get:    "/organisation/utilisateurs/#{user_id}/reset/#{id}/undiscard").to be_unroutable }
  it { expect(patch:  "/organisation/utilisateurs/#{user_id}/reset/#{id}/undiscard").to be_unroutable }
end
