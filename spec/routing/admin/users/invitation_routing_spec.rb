# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::Users::InvitationsController do
  it { expect(get:    "/admin/utilisateurs/9c6c00c4/invitation").to be_unroutable }
  it { expect(post:   "/admin/utilisateurs/9c6c00c4/invitation").to route_to("admin/users/invitations#create", user_id: "9c6c00c4") }
  it { expect(patch:  "/admin/utilisateurs/9c6c00c4/invitation").to be_unroutable }
  it { expect(delete: "/admin/utilisateurs/9c6c00c4/invitation").to be_unroutable }

  it { expect(get:    "/admin/utilisateurs/9c6c00c4/invitation/new").to       route_to("admin/users/invitations#new", user_id: "9c6c00c4") }
  it { expect(get:    "/admin/utilisateurs/9c6c00c4/invitation/edit").to      be_unroutable }
  it { expect(get:    "/admin/utilisateurs/9c6c00c4/invitation/remove").to    be_unroutable }
  it { expect(get:    "/admin/utilisateurs/9c6c00c4/invitation/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/utilisateurs/9c6c00c4/invitation/undiscard").to be_unroutable }

  it { expect(get:    "/admin/utilisateurs/9c6c00c4/invitation/b12170f4").to be_unroutable }
  it { expect(post:   "/admin/utilisateurs/9c6c00c4/invitation/b12170f4").to be_unroutable }
  it { expect(patch:  "/admin/utilisateurs/9c6c00c4/invitation/b12170f4").to be_unroutable }
  it { expect(delete: "/admin/utilisateurs/9c6c00c4/invitation/b12170f4").to be_unroutable }

  it { expect(get:    "/admin/utilisateurs/9c6c00c4/invitation/b12170f4/edit").to      be_unroutable }
  it { expect(get:    "/admin/utilisateurs/9c6c00c4/invitation/b12170f4/remove").to    be_unroutable }
  it { expect(get:    "/admin/utilisateurs/9c6c00c4/invitation/b12170f4/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/utilisateurs/9c6c00c4/invitation/b12170f4/undiscard").to be_unroutable }
end
