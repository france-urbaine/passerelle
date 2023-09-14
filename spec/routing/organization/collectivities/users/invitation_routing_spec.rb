# frozen_string_literal: true

require "rails_helper"

RSpec.describe Organization::Collectivities::Users::InvitationsController do
  it { expect(get:    "/organisation/collectivites/9c6c00c4/utilisateurs/b12170f4/invitation").to be_unroutable }
  it { expect(post:   "/organisation/collectivites/9c6c00c4/utilisateurs/b12170f4/invitation").to route_to("organization/collectivities/users/invitations#create", collectivity_id: "9c6c00c4", user_id: "b12170f4") }
  it { expect(patch:  "/organisation/collectivites/9c6c00c4/utilisateurs/b12170f4/invitation").to be_unroutable }
  it { expect(delete: "/organisation/collectivites/9c6c00c4/utilisateurs/b12170f4/invitation").to be_unroutable }

  it { expect(get:    "/organisation/collectivites/9c6c00c4/utilisateurs/b12170f4/invitation/new").to       route_to("organization/collectivities/users/invitations#new", collectivity_id: "9c6c00c4", user_id: "b12170f4") }
  it { expect(get:    "/organisation/collectivites/9c6c00c4/utilisateurs/b12170f4/invitation/edit").to      be_unroutable }
  it { expect(get:    "/organisation/collectivites/9c6c00c4/utilisateurs/b12170f4/invitation/remove").to    be_unroutable }
  it { expect(get:    "/organisation/collectivites/9c6c00c4/utilisateurs/b12170f4/invitation/undiscard").to be_unroutable }
  it { expect(patch:  "/organisation/collectivites/9c6c00c4/utilisateurs/b12170f4/invitation/undiscard").to be_unroutable }

  it { expect(get:    "/organisation/collectivites/9c6c00c4/utilisateurs/b12170f4/invitation/b12170f4").to be_unroutable }
  it { expect(post:   "/organisation/collectivites/9c6c00c4/utilisateurs/b12170f4/invitation/b12170f4").to be_unroutable }
  it { expect(patch:  "/organisation/collectivites/9c6c00c4/utilisateurs/b12170f4/invitation/b12170f4").to be_unroutable }
  it { expect(delete: "/organisation/collectivites/9c6c00c4/utilisateurs/b12170f4/invitation/b12170f4").to be_unroutable }

  it { expect(get:    "/organisation/collectivites/9c6c00c4/utilisateurs/b12170f4/invitation/b12170f4/edit").to      be_unroutable }
  it { expect(get:    "/organisation/collectivites/9c6c00c4/utilisateurs/b12170f4/invitation/b12170f4/remove").to    be_unroutable }
  it { expect(get:    "/organisation/collectivites/9c6c00c4/utilisateurs/b12170f4/invitation/b12170f4/undiscard").to be_unroutable }
  it { expect(patch:  "/organisation/collectivites/9c6c00c4/utilisateurs/b12170f4/invitation/b12170f4/undiscard").to be_unroutable }
end
