# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::DDFIPs::AuditsController do
  it { expect(get:    "/admin/ddfips/9c6c00c4/audits").to route_to("admin/ddfips/audits#index", ddfip_id: "9c6c00c4") }
  it { expect(post:   "/admin/ddfips/9c6c00c4/audits").to be_unroutable }
  it { expect(patch:  "/admin/ddfips/9c6c00c4/audits").to be_unroutable }
  it { expect(delete: "/admin/ddfips/9c6c00c4/audits").to be_unroutable }

  it { expect(get:    "/admin/ddfips/9c6c00c4/audits/new").to       be_unroutable }
  it { expect(get:    "/admin/ddfips/9c6c00c4/audits/edit").to      be_unroutable }
  it { expect(get:    "/admin/ddfips/9c6c00c4/audits/remove").to    be_unroutable }
  it { expect(get:    "/admin/ddfips/9c6c00c4/audits/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/ddfips/9c6c00c4/audits/undiscard").to be_unroutable }

  it { expect(get:    "/admin/ddfips/9c6c00c4/audits/b12170f4").to be_unroutable }
  it { expect(post:   "/admin/ddfips/9c6c00c4/audits/b12170f4").to be_unroutable }
  it { expect(patch:  "/admin/ddfips/9c6c00c4/audits/b12170f4").to be_unroutable }
  it { expect(delete: "/admin/ddfips/9c6c00c4/audits/b12170f4").to be_unroutable }

  it { expect(get:    "/admin/ddfips/9c6c00c4/audits/b12170f4/edit").to      be_unroutable }
  it { expect(get:    "/admin/ddfips/9c6c00c4/audits/b12170f4/remove").to    be_unroutable }
  it { expect(get:    "/admin/ddfips/9c6c00c4/audits/b12170f4/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/ddfips/9c6c00c4/audits/b12170f4/undiscard").to be_unroutable }
end
