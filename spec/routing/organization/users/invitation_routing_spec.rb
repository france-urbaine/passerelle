# frozen_string_literal: true

require "rails_helper"

RSpec.describe Organization::Users::InvitationsController do
  it { expect(get:    "/organisation/utilisateurs/9c6c00c4/invitation").to be_unroutable }
  it { expect(post:   "/organisation/utilisateurs/9c6c00c4/invitation").to route_to("organization/users/invitations#create", user_id: "9c6c00c4") }
  it { expect(patch:  "/organisation/utilisateurs/9c6c00c4/invitation").to be_unroutable }
  it { expect(delete: "/organisation/utilisateurs/9c6c00c4/invitation").to be_unroutable }

  it { expect(get:    "/organisation/utilisateurs/9c6c00c4/invitation/new").to       route_to("organization/users/invitations#new", user_id: "9c6c00c4") }
  it { expect(get:    "/organisation/utilisateurs/9c6c00c4/invitation/edit").to      be_unroutable }
  it { expect(get:    "/organisation/utilisateurs/9c6c00c4/invitation/remove").to    be_unroutable }
  it { expect(get:    "/organisation/utilisateurs/9c6c00c4/invitation/undiscard").to be_unroutable }
  it { expect(patch:  "/organisation/utilisateurs/9c6c00c4/invitation/undiscard").to be_unroutable }

  it { expect(get:    "/organisation/utilisateurs/9c6c00c4/invitation/b12170f4").to be_unroutable }
  it { expect(post:   "/organisation/utilisateurs/9c6c00c4/invitation/b12170f4").to be_unroutable }
  it { expect(patch:  "/organisation/utilisateurs/9c6c00c4/invitation/b12170f4").to be_unroutable }
  it { expect(delete: "/organisation/utilisateurs/9c6c00c4/invitation/b12170f4").to be_unroutable }

  it { expect(get:    "/organisation/utilisateurs/9c6c00c4/invitation/b12170f4/edit").to      be_unroutable }
  it { expect(get:    "/organisation/utilisateurs/9c6c00c4/invitation/b12170f4/remove").to    be_unroutable }
  it { expect(get:    "/organisation/utilisateurs/9c6c00c4/invitation/b12170f4/undiscard").to be_unroutable }
  it { expect(patch:  "/organisation/utilisateurs/9c6c00c4/invitation/b12170f4/undiscard").to be_unroutable }
end
