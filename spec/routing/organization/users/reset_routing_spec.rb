# frozen_string_literal: true

require "rails_helper"

RSpec.describe Organization::Users::ResetsController do
  it { expect(get:    "/organisation/utilisateurs/9c6c00c4/reset").to be_unroutable }
  it { expect(post:   "/organisation/utilisateurs/9c6c00c4/reset").to route_to("organization/users/resets#create", user_id: "9c6c00c4") }
  it { expect(patch:  "/organisation/utilisateurs/9c6c00c4/reset").to be_unroutable }
  it { expect(delete: "/organisation/utilisateurs/9c6c00c4/reset").to be_unroutable }

  it { expect(get:    "/organisation/utilisateurs/9c6c00c4/reset/new").to       route_to("organization/users/resets#new", user_id: "9c6c00c4") }
  it { expect(get:    "/organisation/utilisateurs/9c6c00c4/reset/edit").to      be_unroutable }
  it { expect(get:    "/organisation/utilisateurs/9c6c00c4/reset/remove").to    be_unroutable }
  it { expect(get:    "/organisation/utilisateurs/9c6c00c4/reset/undiscard").to be_unroutable }
  it { expect(patch:  "/organisation/utilisateurs/9c6c00c4/reset/undiscard").to be_unroutable }

  it { expect(get:    "/organisation/utilisateurs/9c6c00c4/reset/b12170f4").to be_unroutable }
  it { expect(post:   "/organisation/utilisateurs/9c6c00c4/reset/b12170f4").to be_unroutable }
  it { expect(patch:  "/organisation/utilisateurs/9c6c00c4/reset/b12170f4").to be_unroutable }
  it { expect(delete: "/organisation/utilisateurs/9c6c00c4/reset/b12170f4").to be_unroutable }

  it { expect(get:    "/organisation/utilisateurs/9c6c00c4/reset/b12170f4/edit").to      be_unroutable }
  it { expect(get:    "/organisation/utilisateurs/9c6c00c4/reset/b12170f4/remove").to    be_unroutable }
  it { expect(get:    "/organisation/utilisateurs/9c6c00c4/reset/b12170f4/undiscard").to be_unroutable }
  it { expect(patch:  "/organisation/utilisateurs/9c6c00c4/reset/b12170f4/undiscard").to be_unroutable }
end
