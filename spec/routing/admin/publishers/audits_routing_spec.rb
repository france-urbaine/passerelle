# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::Publishers::AuditsController do
  it { expect(get:    "/admin/editeurs/9c6c00c4/audits").to route_to("admin/publishers/audits#index", publisher_id: "9c6c00c4") }
  it { expect(post:   "/admin/editeurs/9c6c00c4/audits").to be_unroutable }
  it { expect(patch:  "/admin/editeurs/9c6c00c4/audits").to be_unroutable }
  it { expect(delete: "/admin/editeurs/9c6c00c4/audits").to be_unroutable }

  it { expect(get:    "/admin/editeurs/9c6c00c4/audits/new").to       be_unroutable }
  it { expect(get:    "/admin/editeurs/9c6c00c4/audits/edit").to      be_unroutable }
  it { expect(get:    "/admin/editeurs/9c6c00c4/audits/remove").to    be_unroutable }
  it { expect(get:    "/admin/editeurs/9c6c00c4/audits/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/editeurs/9c6c00c4/audits/undiscard").to be_unroutable }

  it { expect(get:    "/admin/editeurs/9c6c00c4/audits/b12170f4").to be_unroutable }
  it { expect(post:   "/admin/editeurs/9c6c00c4/audits/b12170f4").to be_unroutable }
  it { expect(patch:  "/admin/editeurs/9c6c00c4/audits/b12170f4").to be_unroutable }
  it { expect(delete: "/admin/editeurs/9c6c00c4/audits/b12170f4").to be_unroutable }

  it { expect(get:    "/admin/editeurs/9c6c00c4/audits/b12170f4/edit").to      be_unroutable }
  it { expect(get:    "/admin/editeurs/9c6c00c4/audits/b12170f4/remove").to    be_unroutable }
  it { expect(get:    "/admin/editeurs/9c6c00c4/audits/b12170f4/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/editeurs/9c6c00c4/audits/b12170f4/undiscard").to be_unroutable }
end
