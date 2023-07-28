# frozen_string_literal: true

require "rails_helper"

RSpec.describe Organization::Offices::CommunesController do
  it { expect(get:    "/organisation/guichets/9c6c00c4/communes").to route_to("organization/offices/communes#index", office_id: "9c6c00c4") }
  it { expect(post:   "/organisation/guichets/9c6c00c4/communes").to be_unroutable }
  it { expect(patch:  "/organisation/guichets/9c6c00c4/communes").to route_to("organization/offices/communes#update_all", office_id: "9c6c00c4") }
  it { expect(delete: "/organisation/guichets/9c6c00c4/communes").to route_to("organization/offices/communes#destroy_all", office_id: "9c6c00c4") }

  it { expect(get:    "/organisation/guichets/9c6c00c4/communes/new").to       be_unroutable }
  it { expect(get:    "/organisation/guichets/9c6c00c4/communes/edit").to      route_to("organization/offices/communes#edit_all", office_id: "9c6c00c4") }
  it { expect(get:    "/organisation/guichets/9c6c00c4/communes/remove").to    route_to("organization/offices/communes#remove_all", office_id: "9c6c00c4") }
  it { expect(get:    "/organisation/guichets/9c6c00c4/communes/undiscard").to be_unroutable }
  it { expect(patch:  "/organisation/guichets/9c6c00c4/communes/undiscard").to be_unroutable }

  it { expect(get:    "/organisation/guichets/9c6c00c4/communes/b12170f4").to be_unroutable }
  it { expect(post:   "/organisation/guichets/9c6c00c4/communes/b12170f4").to be_unroutable }
  it { expect(patch:  "/organisation/guichets/9c6c00c4/communes/b12170f4").to be_unroutable }
  it { expect(delete: "/organisation/guichets/9c6c00c4/communes/b12170f4").to route_to("organization/offices/communes#destroy", office_id: "9c6c00c4", id: "b12170f4") }

  it { expect(get:    "/organisation/guichets/9c6c00c4/communes/b12170f4/edit").to      be_unroutable }
  it { expect(get:    "/organisation/guichets/9c6c00c4/communes/b12170f4/remove").to    route_to("organization/offices/communes#remove", office_id: "9c6c00c4", id: "b12170f4") }
  it { expect(get:    "/organisation/guichets/9c6c00c4/communes/b12170f4/undiscard").to be_unroutable }
  it { expect(patch:  "/organisation/guichets/9c6c00c4/communes/b12170f4/undiscard").to be_unroutable }
end
