# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::Collectivities::OfficesController do
  it { expect(get:    "/admin/collectivites/9c6c00c4/guichets").to route_to("admin/collectivities/offices#index", collectivity_id: "9c6c00c4") }
  it { expect(post:   "/admin/collectivites/9c6c00c4/guichets").to be_unroutable }
  it { expect(patch:  "/admin/collectivites/9c6c00c4/guichets").to be_unroutable }
  it { expect(delete: "/admin/collectivites/9c6c00c4/guichets").to be_unroutable }

  it { expect(get:    "/admin/collectivites/9c6c00c4/guichets/new").to       be_unroutable }
  it { expect(get:    "/admin/collectivites/9c6c00c4/guichets/edit").to      be_unroutable }
  it { expect(get:    "/admin/collectivites/9c6c00c4/guichets/remove").to    be_unroutable }
  it { expect(get:    "/admin/collectivites/9c6c00c4/guichets/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/collectivites/9c6c00c4/guichets/undiscard").to be_unroutable }

  it { expect(get:    "/admin/collectivites/9c6c00c4/guichets/b12170f4").to be_unroutable }
  it { expect(post:   "/admin/collectivites/9c6c00c4/guichets/b12170f4").to be_unroutable }
  it { expect(patch:  "/admin/collectivites/9c6c00c4/guichets/b12170f4").to be_unroutable }
  it { expect(delete: "/admin/collectivites/9c6c00c4/guichets/b12170f4").to be_unroutable }

  it { expect(get:    "/admin/collectivites/9c6c00c4/guichets/b12170f4/edit").to      be_unroutable }
  it { expect(get:    "/admin/collectivites/9c6c00c4/guichets/b12170f4/remove").to    be_unroutable }
  it { expect(get:    "/admin/collectivites/9c6c00c4/guichets/b12170f4/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/collectivites/9c6c00c4/guichets/b12170f4/undiscard").to be_unroutable }
end
