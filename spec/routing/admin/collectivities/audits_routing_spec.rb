# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::Collectivities::AuditsController do
  it { expect(get:    "/admin/collectivites/9c6c00c4/audits").to route_to("admin/collectivities/audits#index", collectivity_id: "9c6c00c4") }
  it { expect(post:   "/admin/collectivites/9c6c00c4/audits").to be_unroutable }
  it { expect(patch:  "/admin/collectivites/9c6c00c4/audits").to be_unroutable }
  it { expect(delete: "/admin/collectivites/9c6c00c4/audits").to be_unroutable }

  it { expect(get:    "/admin/collectivites/9c6c00c4/audits/new").to       be_unroutable }
  it { expect(get:    "/admin/collectivites/9c6c00c4/audits/edit").to      be_unroutable }
  it { expect(get:    "/admin/collectivites/9c6c00c4/audits/remove").to    be_unroutable }
  it { expect(get:    "/admin/collectivites/9c6c00c4/audits/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/collectivites/9c6c00c4/audits/undiscard").to be_unroutable }

  it { expect(get:    "/admin/collectivites/9c6c00c4/audits/b12170f4").to be_unroutable }
  it { expect(post:   "/admin/collectivites/9c6c00c4/audits/b12170f4").to be_unroutable }
  it { expect(patch:  "/admin/collectivites/9c6c00c4/audits/b12170f4").to be_unroutable }
  it { expect(delete: "/admin/collectivites/9c6c00c4/audits/b12170f4").to be_unroutable }

  it { expect(get:    "/admin/collectivites/9c6c00c4/audits/b12170f4/edit").to      be_unroutable }
  it { expect(get:    "/admin/collectivites/9c6c00c4/audits/b12170f4/remove").to    be_unroutable }
  it { expect(get:    "/admin/collectivites/9c6c00c4/audits/b12170f4/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/collectivites/9c6c00c4/audits/b12170f4/undiscard").to be_unroutable }
end
