# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::Users::ResetsController do
  it { expect(get:    "/admin/utilisateurs/9c6c00c4/reset").to be_unroutable }
  it { expect(post:   "/admin/utilisateurs/9c6c00c4/reset").to route_to("admin/users/resets#create", user_id: "9c6c00c4") }
  it { expect(patch:  "/admin/utilisateurs/9c6c00c4/reset").to be_unroutable }
  it { expect(delete: "/admin/utilisateurs/9c6c00c4/reset").to be_unroutable }

  it { expect(get:    "/admin/utilisateurs/9c6c00c4/reset/new").to       route_to("admin/users/resets#new", user_id: "9c6c00c4") }
  it { expect(get:    "/admin/utilisateurs/9c6c00c4/reset/edit").to      be_unroutable }
  it { expect(get:    "/admin/utilisateurs/9c6c00c4/reset/remove").to    be_unroutable }
  it { expect(get:    "/admin/utilisateurs/9c6c00c4/reset/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/utilisateurs/9c6c00c4/reset/undiscard").to be_unroutable }

  it { expect(get:    "/admin/utilisateurs/9c6c00c4/reset/b12170f4").to be_unroutable }
  it { expect(post:   "/admin/utilisateurs/9c6c00c4/reset/b12170f4").to be_unroutable }
  it { expect(patch:  "/admin/utilisateurs/9c6c00c4/reset/b12170f4").to be_unroutable }
  it { expect(delete: "/admin/utilisateurs/9c6c00c4/reset/b12170f4").to be_unroutable }

  it { expect(get:    "/admin/utilisateurs/9c6c00c4/reset/b12170f4/edit").to      be_unroutable }
  it { expect(get:    "/admin/utilisateurs/9c6c00c4/reset/b12170f4/remove").to    be_unroutable }
  it { expect(get:    "/admin/utilisateurs/9c6c00c4/reset/b12170f4/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/utilisateurs/9c6c00c4/reset/b12170f4/undiscard").to be_unroutable }
end
