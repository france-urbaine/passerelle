# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::Offices::CommunesController do
  it { expect(get:    "/admin/guichets/9c6c00c4/communes").to route_to("admin/offices/communes#index", office_id: "9c6c00c4") }
  it { expect(post:   "/admin/guichets/9c6c00c4/communes").to be_unroutable }
  it { expect(patch:  "/admin/guichets/9c6c00c4/communes").to route_to("admin/offices/communes#update_all", office_id: "9c6c00c4") }
  it { expect(delete: "/admin/guichets/9c6c00c4/communes").to route_to("admin/offices/communes#destroy_all", office_id: "9c6c00c4") }

  it { expect(get:    "/admin/guichets/9c6c00c4/communes/new").to       be_unroutable }
  it { expect(get:    "/admin/guichets/9c6c00c4/communes/edit").to      route_to("admin/offices/communes#edit_all", office_id: "9c6c00c4") }
  it { expect(get:    "/admin/guichets/9c6c00c4/communes/remove").to    route_to("admin/offices/communes#remove_all", office_id: "9c6c00c4") }
  it { expect(get:    "/admin/guichets/9c6c00c4/communes/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/guichets/9c6c00c4/communes/undiscard").to be_unroutable }

  it { expect(get:    "/admin/guichets/9c6c00c4/communes/b12170f4").to be_unroutable }
  it { expect(post:   "/admin/guichets/9c6c00c4/communes/b12170f4").to be_unroutable }
  it { expect(patch:  "/admin/guichets/9c6c00c4/communes/b12170f4").to be_unroutable }
  it { expect(delete: "/admin/guichets/9c6c00c4/communes/b12170f4").to route_to("admin/offices/communes#destroy", office_id: "9c6c00c4", id: "b12170f4") }

  it { expect(get:    "/admin/guichets/9c6c00c4/communes/b12170f4/edit").to      be_unroutable }
  it { expect(get:    "/admin/guichets/9c6c00c4/communes/b12170f4/remove").to    route_to("admin/offices/communes#remove", office_id: "9c6c00c4", id: "b12170f4") }
  it { expect(get:    "/admin/guichets/9c6c00c4/communes/b12170f4/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/guichets/9c6c00c4/communes/b12170f4/undiscard").to be_unroutable }
end
