# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reports::DocumentsController do
  it { expect(get:    "/signalements/9c6c00c4/documents").to be_unroutable }
  it { expect(post:   "/signalements/9c6c00c4/documents").to route_to("reports/documents#create", report_id: "9c6c00c4") }
  it { expect(patch:  "/signalements/9c6c00c4/documents").to be_unroutable }
  it { expect(delete: "/signalements/9c6c00c4/documents").to be_unroutable }

  it { expect(get:    "/signalements/9c6c00c4/documents/new").to       route_to("reports/documents#new", report_id: "9c6c00c4") }
  it { expect(get:    "/signalements/9c6c00c4/documents/edit").to      be_unroutable }
  it { expect(get:    "/signalements/9c6c00c4/documents/remove").to    be_unroutable }
  it { expect(get:    "/signalements/9c6c00c4/documents/undiscard").to be_unroutable }
  it { expect(patch:  "/signalements/9c6c00c4/documents/undiscard").to be_unroutable }

  it { expect(get:    "/signalements/9c6c00c4/documents/b12170f4").to route_to("reports/documents#show", report_id: "9c6c00c4", id: "b12170f4", format: "html") }
  it { expect(post:   "/signalements/9c6c00c4/documents/b12170f4").to be_unroutable }
  it { expect(patch:  "/signalements/9c6c00c4/documents/b12170f4").to be_unroutable }
  it { expect(delete: "/signalements/9c6c00c4/documents/b12170f4").to route_to("reports/documents#destroy", report_id: "9c6c00c4", id: "b12170f4") }

  it { expect(get:    "/signalements/9c6c00c4/documents/b12170f4/edit").to      be_unroutable }
  it { expect(get:    "/signalements/9c6c00c4/documents/b12170f4/remove").to    route_to("reports/documents#remove", report_id: "9c6c00c4", id: "b12170f4") }
  it { expect(get:    "/signalements/9c6c00c4/documents/b12170f4/undiscard").to be_unroutable }
  it { expect(patch:  "/signalements/9c6c00c4/documents/b12170f4/undiscard").to be_unroutable }

  it { expect(get:    "/signalements/9c6c00c4/documents/b12170f4/file.pdf").to  route_to("reports/documents#show", report_id: "9c6c00c4", id: "b12170f4", filename: "file.pdf", format: "html") }
  it { expect(get:    "/signalements/9c6c00c4/documents/b12170f4/image.png").to route_to("reports/documents#show", report_id: "9c6c00c4", id: "b12170f4", filename: "image.png", format: "html") }
end
