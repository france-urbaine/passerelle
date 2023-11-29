# frozen_string_literal: true

require "rails_helper"

RSpec.describe Organization::Collectivities::Users::ResetsController do
  it { expect(get:    "/organisation/collectivites/9c6c00c4/utilisateurs/b12170f4/reset").to be_unroutable }
  it { expect(post:   "/organisation/collectivites/9c6c00c4/utilisateurs/b12170f4/reset").to route_to("organization/collectivities/users/resets#create", collectivity_id: "9c6c00c4", user_id: "b12170f4") }
  it { expect(patch:  "/organisation/collectivites/9c6c00c4/utilisateurs/b12170f4/reset").to be_unroutable }
  it { expect(delete: "/organisation/collectivites/9c6c00c4/utilisateurs/b12170f4/reset").to be_unroutable }

  it { expect(get:    "/organisation/collectivites/9c6c00c4/utilisateurs/b12170f4/reset/new").to       route_to("organization/collectivities/users/resets#new", collectivity_id: "9c6c00c4", user_id: "b12170f4") }
  it { expect(get:    "/organisation/collectivites/9c6c00c4/utilisateurs/b12170f4/reset/edit").to      be_unroutable }
  it { expect(get:    "/organisation/collectivites/9c6c00c4/utilisateurs/b12170f4/reset/remove").to    be_unroutable }
  it { expect(get:    "/organisation/collectivites/9c6c00c4/utilisateurs/b12170f4/reset/undiscard").to be_unroutable }
  it { expect(patch:  "/organisation/collectivites/9c6c00c4/utilisateurs/b12170f4/reset/undiscard").to be_unroutable }

  it { expect(get:    "/organisation/collectivites/9c6c00c4/utilisateurs/b12170f4/reset/b12170f4").to be_unroutable }
  it { expect(post:   "/organisation/collectivites/9c6c00c4/utilisateurs/b12170f4/reset/b12170f4").to be_unroutable }
  it { expect(patch:  "/organisation/collectivites/9c6c00c4/utilisateurs/b12170f4/reset/b12170f4").to be_unroutable }
  it { expect(delete: "/organisation/collectivites/9c6c00c4/utilisateurs/b12170f4/reset/b12170f4").to be_unroutable }

  it { expect(get:    "/organisation/collectivites/9c6c00c4/utilisateurs/b12170f4/reset/b12170f4/edit").to      be_unroutable }
  it { expect(get:    "/organisation/collectivites/9c6c00c4/utilisateurs/b12170f4/reset/b12170f4/remove").to    be_unroutable }
  it { expect(get:    "/organisation/collectivites/9c6c00c4/utilisateurs/b12170f4/reset/b12170f4/undiscard").to be_unroutable }
  it { expect(patch:  "/organisation/collectivites/9c6c00c4/utilisateurs/b12170f4/reset/b12170f4/undiscard").to be_unroutable }
end
