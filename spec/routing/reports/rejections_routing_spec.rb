# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reports::RejectionsController do
  it { expect(get:    "/signalements/9c6c00c4/reject").to route_to("reports/rejections#edit", report_id: "9c6c00c4") }
  it { expect(post:   "/signalements/9c6c00c4/reject").to be_unroutable }
  it { expect(patch:  "/signalements/9c6c00c4/reject").to route_to("reports/rejections#update", report_id: "9c6c00c4") }
  it { expect(delete: "/signalements/9c6c00c4/reject").to route_to("reports/rejections#destroy", report_id: "9c6c00c4") }

  it { expect(get:    "/signalements/9c6c00c4/reject/new").to       be_unroutable }
  it { expect(get:    "/signalements/9c6c00c4/reject/edit").to      be_unroutable }
  it { expect(get:    "/signalements/9c6c00c4/reject/remove").to    route_to("reports/rejections#remove", report_id: "9c6c00c4") }
  it { expect(get:    "/signalements/9c6c00c4/reject/undiscard").to be_unroutable }
  it { expect(patch:  "/signalements/9c6c00c4/reject/undiscard").to be_unroutable }

  it { expect(get:    "/signalements/9c6c00c4/reject/b12170f4").to be_unroutable }
  it { expect(post:   "/signalements/9c6c00c4/reject/b12170f4").to be_unroutable }
  it { expect(patch:  "/signalements/9c6c00c4/reject/b12170f4").to be_unroutable }
  it { expect(delete: "/signalements/9c6c00c4/reject/b12170f4").to be_unroutable }

  it { expect(get:    "/signalements/9c6c00c4/reject/b12170f4/edit").to      be_unroutable }
  it { expect(get:    "/signalements/9c6c00c4/reject/b12170f4/remove").to    be_unroutable }
  it { expect(get:    "/signalements/9c6c00c4/reject/b12170f4/undiscard").to be_unroutable }
  it { expect(patch:  "/signalements/9c6c00c4/reject/b12170f4/undiscard").to be_unroutable }
end
