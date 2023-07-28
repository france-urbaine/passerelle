# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::Publishers::CollectivitiesController do
  it { expect(get:    "/admin/editeurs/9c6c00c4/collectivites").to route_to("admin/publishers/collectivities#index", publisher_id: "9c6c00c4") }
  it { expect(post:   "/admin/editeurs/9c6c00c4/collectivites").to route_to("admin/publishers/collectivities#create", publisher_id: "9c6c00c4") }
  it { expect(patch:  "/admin/editeurs/9c6c00c4/collectivites").to be_unroutable }
  it { expect(delete: "/admin/editeurs/9c6c00c4/collectivites").to route_to("admin/publishers/collectivities#destroy_all", publisher_id: "9c6c00c4") }

  it { expect(get:    "/admin/editeurs/9c6c00c4/collectivites/new").to       route_to("admin/publishers/collectivities#new", publisher_id: "9c6c00c4") }
  it { expect(get:    "/admin/editeurs/9c6c00c4/collectivites/edit").to      be_unroutable }
  it { expect(get:    "/admin/editeurs/9c6c00c4/collectivites/remove").to    route_to("admin/publishers/collectivities#remove_all", publisher_id: "9c6c00c4") }
  it { expect(get:    "/admin/editeurs/9c6c00c4/collectivites/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/editeurs/9c6c00c4/collectivites/undiscard").to route_to("admin/publishers/collectivities#undiscard_all", publisher_id: "9c6c00c4") }

  it { expect(get:    "/admin/editeurs/9c6c00c4/collectivites/b12170f4").to be_unroutable }
  it { expect(post:   "/admin/editeurs/9c6c00c4/collectivites/b12170f4").to be_unroutable }
  it { expect(patch:  "/admin/editeurs/9c6c00c4/collectivites/b12170f4").to be_unroutable }
  it { expect(delete: "/admin/editeurs/9c6c00c4/collectivites/b12170f4").to be_unroutable }

  it { expect(get:    "/admin/editeurs/9c6c00c4/collectivites/b12170f4/edit").to      be_unroutable }
  it { expect(get:    "/admin/editeurs/9c6c00c4/collectivites/b12170f4/remove").to    be_unroutable }
  it { expect(get:    "/admin/editeurs/9c6c00c4/collectivites/b12170f4/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/editeurs/9c6c00c4/collectivites/b12170f4/undiscard").to be_unroutable }
end
