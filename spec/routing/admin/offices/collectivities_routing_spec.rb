# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::Offices::CollectivitiesController do
  it { expect(get:    "/admin/guichets/9c6c00c4/collectivites").to route_to("admin/offices/collectivities#index", office_id: "9c6c00c4") }
  it { expect(post:   "/admin/guichets/9c6c00c4/collectivites").to be_unroutable }
  it { expect(patch:  "/admin/guichets/9c6c00c4/collectivites").to be_unroutable }
  it { expect(delete: "/admin/guichets/9c6c00c4/collectivites").to be_unroutable }

  it { expect(get:    "/admin/guichets/9c6c00c4/collectivites/new").to       be_unroutable }
  it { expect(get:    "/admin/guichets/9c6c00c4/collectivites/edit").to      be_unroutable }
  it { expect(get:    "/admin/guichets/9c6c00c4/collectivites/remove").to    be_unroutable }
  it { expect(get:    "/admin/guichets/9c6c00c4/collectivites/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/guichets/9c6c00c4/collectivites/undiscard").to be_unroutable }

  it { expect(get:    "/admin/guichets/9c6c00c4/collectivites/b12170f4").to be_unroutable }
  it { expect(post:   "/admin/guichets/9c6c00c4/collectivites/b12170f4").to be_unroutable }
  it { expect(patch:  "/admin/guichets/9c6c00c4/collectivites/b12170f4").to be_unroutable }
  it { expect(delete: "/admin/guichets/9c6c00c4/collectivites/b12170f4").to be_unroutable }

  it { expect(get:    "/admin/guichets/9c6c00c4/collectivites/b12170f4/edit").to      be_unroutable }
  it { expect(get:    "/admin/guichets/9c6c00c4/collectivites/b12170f4/remove").to    be_unroutable }
  it { expect(get:    "/admin/guichets/9c6c00c4/collectivites/b12170f4/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/guichets/9c6c00c4/collectivites/b12170f4/undiscard").to be_unroutable }
end
