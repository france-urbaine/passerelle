# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::Users::OfficesController do
  let(:user_id) { SecureRandom.uuid }
  let(:id)      { SecureRandom.uuid }

  it { expect(get:    "/admin/utilisateurs/guichets").to route_to("admin/users/offices#index") }
  it { expect(post:   "/admin/utilisateurs/guichets").to be_unroutable }
  it { expect(patch:  "/admin/utilisateurs/guichets").to be_unroutable }
  it { expect(delete: "/admin/utilisateurs/guichets").to be_unroutable }

  it { expect(get:    "/admin/utilisateurs/guichets/new").to       be_unroutable }
  it { expect(get:    "/admin/utilisateurs/guichets/edit").to      be_unroutable }
  it { expect(get:    "/admin/utilisateurs/guichets/remove").to    be_unroutable }
  it { expect(get:    "/admin/utilisateurs/guichets/undiscard").to be_unroutable }

  it { expect(get:    "/admin/utilisateurs/guichets/#{id}").to be_unroutable }
  it { expect(post:   "/admin/utilisateurs/guichets/#{id}").to be_unroutable }
  it { expect(patch:  "/admin/utilisateurs/guichets/#{id}").to be_unroutable }
  it { expect(delete: "/admin/utilisateurs/guichets/#{id}").to be_unroutable }

  it { expect(get:    "/admin/utilisateurs/#{user_id}/guichets").to be_unroutable }
  it { expect(post:   "/admin/utilisateurs/#{user_id}/guichets").to be_unroutable }
  it { expect(patch:  "/admin/utilisateurs/#{user_id}/guichets").to be_unroutable }
  it { expect(delete: "/admin/utilisateurs/#{user_id}/guichets").to be_unroutable }

  it { expect(get:    "/admin/utilisateurs/#{user_id}/guichets/new").to       be_unroutable }
  it { expect(get:    "/admin/utilisateurs/#{user_id}/guichets/edit").to      be_unroutable }
  it { expect(get:    "/admin/utilisateurs/#{user_id}/guichets/remove").to    be_unroutable }
  it { expect(get:    "/admin/utilisateurs/#{user_id}/guichets/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/utilisateurs/#{user_id}/guichets/undiscard").to be_unroutable }

  it { expect(get:    "/admin/utilisateurs/#{user_id}/guichets/#{id}").to be_unroutable }
  it { expect(post:   "/admin/utilisateurs/#{user_id}/guichets/#{id}").to be_unroutable }
  it { expect(patch:  "/admin/utilisateurs/#{user_id}/guichets/#{id}").to be_unroutable }
  it { expect(delete: "/admin/utilisateurs/#{user_id}/guichets/#{id}").to be_unroutable }

  it { expect(get:    "/admin/utilisateurs/#{user_id}/guichets/#{id}/edit").to      be_unroutable }
  it { expect(get:    "/admin/utilisateurs/#{user_id}/guichets/#{id}/remove").to    be_unroutable }
  it { expect(get:    "/admin/utilisateurs/#{user_id}/guichets/#{id}/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/utilisateurs/#{user_id}/guichets/#{id}/undiscard").to be_unroutable }
end
