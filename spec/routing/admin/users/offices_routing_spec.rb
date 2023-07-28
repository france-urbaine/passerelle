# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::Users::OfficesController do
  it { expect(get:    "/admin/utilisateurs/guichets").to route_to("admin/users/offices#index") }
  it { expect(post:   "/admin/utilisateurs/guichets").to be_unroutable }
  it { expect(patch:  "/admin/utilisateurs/guichets").to be_unroutable }
  it { expect(delete: "/admin/utilisateurs/guichets").to be_unroutable }

  it { expect(get:    "/admin/utilisateurs/guichets/new").to       be_unroutable }
  it { expect(get:    "/admin/utilisateurs/guichets/edit").to      be_unroutable }
  it { expect(get:    "/admin/utilisateurs/guichets/remove").to    be_unroutable }
  it { expect(get:    "/admin/utilisateurs/guichets/undiscard").to be_unroutable }

  it { expect(get:    "/admin/utilisateurs/guichets/b12170f4").to be_unroutable }
  it { expect(post:   "/admin/utilisateurs/guichets/b12170f4").to be_unroutable }
  it { expect(patch:  "/admin/utilisateurs/guichets/b12170f4").to be_unroutable }
  it { expect(delete: "/admin/utilisateurs/guichets/b12170f4").to be_unroutable }

  it { expect(get:    "/admin/utilisateurs/9c6c00c4/guichets").to be_unroutable }
  it { expect(post:   "/admin/utilisateurs/9c6c00c4/guichets").to be_unroutable }
  it { expect(patch:  "/admin/utilisateurs/9c6c00c4/guichets").to be_unroutable }
  it { expect(delete: "/admin/utilisateurs/9c6c00c4/guichets").to be_unroutable }

  it { expect(get:    "/admin/utilisateurs/9c6c00c4/guichets/new").to       be_unroutable }
  it { expect(get:    "/admin/utilisateurs/9c6c00c4/guichets/edit").to      be_unroutable }
  it { expect(get:    "/admin/utilisateurs/9c6c00c4/guichets/remove").to    be_unroutable }
  it { expect(get:    "/admin/utilisateurs/9c6c00c4/guichets/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/utilisateurs/9c6c00c4/guichets/undiscard").to be_unroutable }

  it { expect(get:    "/admin/utilisateurs/9c6c00c4/guichets/b12170f4").to be_unroutable }
  it { expect(post:   "/admin/utilisateurs/9c6c00c4/guichets/b12170f4").to be_unroutable }
  it { expect(patch:  "/admin/utilisateurs/9c6c00c4/guichets/b12170f4").to be_unroutable }
  it { expect(delete: "/admin/utilisateurs/9c6c00c4/guichets/b12170f4").to be_unroutable }

  it { expect(get:    "/admin/utilisateurs/9c6c00c4/guichets/b12170f4/edit").to      be_unroutable }
  it { expect(get:    "/admin/utilisateurs/9c6c00c4/guichets/b12170f4/remove").to    be_unroutable }
  it { expect(get:    "/admin/utilisateurs/9c6c00c4/guichets/b12170f4/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/utilisateurs/9c6c00c4/guichets/b12170f4/undiscard").to be_unroutable }
end
