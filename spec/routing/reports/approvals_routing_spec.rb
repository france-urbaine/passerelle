# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reports::ApprovalsController do
  it { expect(get:    "/signalements/9c6c00c4/approve").to route_to("reports/approvals#edit", report_id: "9c6c00c4") }
  it { expect(post:   "/signalements/9c6c00c4/approve").to be_unroutable }
  it { expect(patch:  "/signalements/9c6c00c4/approve").to route_to("reports/approvals#update", report_id: "9c6c00c4") }
  it { expect(delete: "/signalements/9c6c00c4/approve").to route_to("reports/approvals#destroy", report_id: "9c6c00c4") }

  it { expect(get:    "/signalements/9c6c00c4/approve/new").to       be_unroutable }
  it { expect(get:    "/signalements/9c6c00c4/approve/edit").to      be_unroutable }
  it { expect(get:    "/signalements/9c6c00c4/approve/remove").to    route_to("reports/approvals#remove", report_id: "9c6c00c4") }
  it { expect(get:    "/signalements/9c6c00c4/approve/undiscard").to be_unroutable }
  it { expect(patch:  "/signalements/9c6c00c4/approve/undiscard").to be_unroutable }

  it { expect(get:    "/signalements/9c6c00c4/approve/b12170f4").to be_unroutable }
  it { expect(post:   "/signalements/9c6c00c4/approve/b12170f4").to be_unroutable }
  it { expect(patch:  "/signalements/9c6c00c4/approve/b12170f4").to be_unroutable }
  it { expect(delete: "/signalements/9c6c00c4/approve/b12170f4").to be_unroutable }

  it { expect(get:    "/signalements/9c6c00c4/approve/b12170f4/edit").to      be_unroutable }
  it { expect(get:    "/signalements/9c6c00c4/approve/b12170f4/remove").to    be_unroutable }
  it { expect(get:    "/signalements/9c6c00c4/approve/b12170f4/undiscard").to be_unroutable }
  it { expect(patch:  "/signalements/9c6c00c4/approve/b12170f4/undiscard").to be_unroutable }
end
