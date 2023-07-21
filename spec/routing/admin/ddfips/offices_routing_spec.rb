# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::DDFIPs::OfficesController do
  it { expect(get:    "/admin/ddfips/9c6c00c4/guichets").to route_to("admin/ddfips/offices#index", ddfip_id: "9c6c00c4") }
  it { expect(post:   "/admin/ddfips/9c6c00c4/guichets").to route_to("admin/ddfips/offices#create", ddfip_id: "9c6c00c4") }
  it { expect(patch:  "/admin/ddfips/9c6c00c4/guichets").to be_unroutable }
  it { expect(delete: "/admin/ddfips/9c6c00c4/guichets").to route_to("admin/ddfips/offices#destroy_all", ddfip_id: "9c6c00c4") }

  it { expect(get:    "/admin/ddfips/9c6c00c4/guichets/new").to       route_to("admin/ddfips/offices#new", ddfip_id: "9c6c00c4") }
  it { expect(get:    "/admin/ddfips/9c6c00c4/guichets/edit").to      be_unroutable }
  it { expect(get:    "/admin/ddfips/9c6c00c4/guichets/remove").to    route_to("admin/ddfips/offices#remove_all", ddfip_id: "9c6c00c4") }
  it { expect(get:    "/admin/ddfips/9c6c00c4/guichets/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/ddfips/9c6c00c4/guichets/undiscard").to route_to("admin/ddfips/offices#undiscard_all", ddfip_id: "9c6c00c4") }

  it { expect(get:    "/admin/ddfips/9c6c00c4/guichets/b12170f4").to be_unroutable }
  it { expect(post:   "/admin/ddfips/9c6c00c4/guichets/b12170f4").to be_unroutable }
  it { expect(patch:  "/admin/ddfips/9c6c00c4/guichets/b12170f4").to be_unroutable }
  it { expect(delete: "/admin/ddfips/9c6c00c4/guichets/b12170f4").to be_unroutable }

  it { expect(get:    "/admin/ddfips/9c6c00c4/guichets/b12170f4/edit").to      be_unroutable }
  it { expect(get:    "/admin/ddfips/9c6c00c4/guichets/b12170f4/remove").to    be_unroutable }
  it { expect(get:    "/admin/ddfips/9c6c00c4/guichets/b12170f4/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/ddfips/9c6c00c4/guichets/b12170f4/undiscard").to be_unroutable }
end
